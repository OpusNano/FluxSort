const std = @import("std");
const Config = @import("config.zig").Config;
const energy = @import("energy.zig");
const key = @import("key.zig");
const pressure = @import("pressure.zig");
const Stats = @import("stats.zig").Stats;
const util = @import("../internal/util.zig");

pub const BlockResult = struct {
    accepted: bool,
    before_energy: u64,
    after_energy: u64,
};

fn useMovedDeltaPath(block_len: usize, moved_count: usize) bool {
    if (moved_count <= 1) return true;
    const total_pairs = block_len * (block_len - 1) / 2;
    const affected_pairs = moved_count * (block_len - moved_count) + moved_count * (moved_count - 1) / 2;
    return affected_pairs * 2 < total_pairs;
}

fn useGroupedExactPath(block_len: usize, distinct_count: usize) bool {
    return distinct_count <= 8 and distinct_count * 4 <= block_len;
}

fn cheapDistinctCount(comptime T: type, keys: []const key.KeyType(T)) usize {
    const table_len = Config.max_block_size * 2;
    var used: [table_len]bool = [_]bool{false} ** table_len;
    var table: [table_len]key.KeyType(T) = undefined;
    var count: usize = 0;

    for (keys) |value| {
        var hash: usize = @intCast(value ^ (value >> @min(@bitSizeOf(key.KeyType(T)) / 2, 16)));
        hash %= table_len;
        while (used[hash]) : (hash = (hash + 1) % table_len) {
            if (table[hash] == value) break;
        }
        if (!used[hash]) {
            used[hash] = true;
            table[hash] = value;
            count += 1;
        }
    }

    return count;
}

fn isPermutation(mapping: []const usize) bool {
    var seen: [Config.max_block_size]bool = [_]bool{false} ** Config.max_block_size;
    for (mapping) |value| {
        if (value >= mapping.len) return false;
        if (seen[value]) return false;
        seen[value] = true;
    }
    for (seen[0..mapping.len]) |flag| {
        if (!flag) return false;
    }
    return true;
}

pub fn resolveTargets(desired: []const usize, source_to_final: []usize) void {
    std.debug.assert(source_to_final.len >= desired.len);

    var order: [Config.max_block_size]usize = undefined;
    for (desired, 0..) |_, i| order[i] = i;

    var i: usize = 1;
    while (i < desired.len) : (i += 1) {
        const current = order[i];
        var j = i;
        while (j > 0) {
            const prev = order[j - 1];
            const current_target = desired[current];
            const prev_target = desired[prev];
            if (prev_target < current_target) break;
            if (prev_target == current_target and prev < current) break;
            order[j] = prev;
            j -= 1;
        }
        order[j] = current;
    }

    for (order[0..desired.len], 0..) |source_index, final_index| {
        source_to_final[source_index] = final_index;
    }
}

pub fn tryTransportBlock(comptime T: type, block: []T, cfg: Config, stats: ?*Stats) BlockResult {
    std.debug.assert(block.len <= Config.max_block_size);
    if (stats) |s| s.transport_blocks_visited += 1;

    if (block.len <= 1 or util.isSorted(T, block)) {
        if (stats) |s| s.transport_blocks_rejected += 1;
        return .{ .accepted = false, .before_energy = 0, .after_energy = 0 };
    }

    var keys: [Config.max_block_size]key.KeyType(T) = undefined;
    for (block, 0..) |value, i| keys[i] = key.biasedKey(T, value);

    var pressures: [Config.max_block_size]i32 = undefined;
    var proposals: [Config.max_block_size]i8 = undefined;
    var desired: [Config.max_block_size]usize = undefined;
    var source_to_final: [Config.max_block_size]usize = undefined;
    var moved_indices: [Config.max_block_size]usize = undefined;
    var group_ids: [Config.max_block_size]u8 = undefined;
    var final_group_ids: [Config.max_block_size]u8 = undefined;
    var distinct_keys: [Config.max_block_size]key.KeyType(T) = undefined;
    var group_counts: [Config.max_block_size]usize = undefined;
    var weight_matrix: [Config.max_block_size * Config.max_block_size]u16 = undefined;

    const estimated_distinct = cheapDistinctCount(T, keys[0..block.len]);
    const grouped_path = useGroupedExactPath(block.len, estimated_distinct);
    const distinct_count = if (grouped_path)
        energy.buildGroupedState(T, keys[0..block.len], distinct_keys[0..block.len], group_ids[0..block.len], group_counts[0..block.len])
    else
        0;

    const before_energy = if (grouped_path)
        blk: {
            if (stats) |s| s.grouped_exact_blocks += 1;
            energy.buildGroupWeightMatrix(T, distinct_keys[0..distinct_count], cfg, weight_matrix[0 .. distinct_count * distinct_count]);
            break :blk pressure.computeFromGroupIdsWithEnergy(
                group_ids[0..block.len],
                distinct_count,
                cfg.neighborhood,
                weight_matrix[0 .. distinct_count * distinct_count],
                pressures[0..block.len],
            );
        }
    else
        pressure.computeFromKeysWithEnergy(T, keys[0..block.len], cfg, pressures[0..block.len]);
    if (before_energy == 0) {
        if (stats) |s| s.transport_blocks_rejected += 1;
        return .{ .accepted = false, .before_energy = before_energy, .after_energy = before_energy };
    }

    pressure.proposalsFromPressure(pressures[0..block.len], cfg, proposals[0..block.len]);

    var changed = false;
    for (block, 0..) |_, i| {
        const displacement: isize = @intCast(proposals[i]);
        const unclamped: isize = @as(isize, @intCast(i)) + displacement;
        const upper: isize = @intCast(block.len - 1);
        const clamped = std.math.clamp(unclamped, @as(isize, 0), upper);
        desired[i] = @intCast(clamped);
        changed = changed or desired[i] != i;
    }

    if (!changed) {
        if (stats) |s| s.transport_blocks_rejected += 1;
        return .{ .accepted = false, .before_energy = before_energy, .after_energy = before_energy };
    }

    resolveTargets(desired[0..block.len], source_to_final[0..block.len]);
    std.debug.assert(isPermutation(source_to_final[0..block.len]));

    var moved_count: usize = 0;
    for (source_to_final[0..block.len], 0..) |final_index, source_index| {
        if (final_index != source_index) {
            moved_indices[moved_count] = source_index;
            moved_count += 1;
        }
    }

    if (moved_count == 0) {
        if (stats) |s| s.transport_blocks_rejected += 1;
        return .{ .accepted = false, .before_energy = before_energy, .after_energy = before_energy };
    }

    const after_energy = if (grouped_path)
        blk: {
            for (group_ids[0..block.len], 0..) |group, source_index| {
                final_group_ids[source_to_final[source_index]] = group;
            }
            break :blk energy.blockEnergyFromGroupIds(final_group_ids[0..block.len], distinct_count, weight_matrix[0 .. distinct_count * distinct_count]);
        }
    else if (useMovedDeltaPath(block.len, moved_count)) blk: {
        if (stats) |s| s.moved_delta_blocks += 1;
        break :blk energy.energyAfterPermutationFromMovedKeys(
            T,
            keys[0..block.len],
            source_to_final[0..block.len],
            moved_indices[0..moved_count],
            before_energy,
            cfg,
        );
    } else blk: {
        if (stats) |s| s.full_delta_blocks += 1;
        break :blk energy.energyAfterPermutationFromKeys(
            T,
            keys[0..block.len],
            source_to_final[0..block.len],
            before_energy,
            cfg,
        );
    };
    if (after_energy >= before_energy) {
        if (stats) |s| s.transport_blocks_rejected += 1;
        return .{ .accepted = false, .before_energy = before_energy, .after_energy = before_energy };
    }

    var candidate: [Config.max_block_size]T = undefined;
    for (block, 0..) |value, source_index| {
        candidate[source_to_final[source_index]] = value;
    }
    std.mem.copyForwards(T, block, candidate[0..block.len]);
    if (stats) |s| s.transport_blocks_accepted += 1;
    return .{ .accepted = true, .before_energy = before_energy, .after_energy = after_energy };
}
