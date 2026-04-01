const std = @import("std");
const Config = @import("config.zig").Config;
const energy = @import("energy.zig");
const pressure = @import("pressure.zig");
const Stats = @import("stats.zig").Stats;

pub const BlockResult = struct {
    accepted: bool,
    before_energy: u64,
    after_energy: u64,
};

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

fn equalSlices(comptime T: type, lhs: []const T, rhs: []const T) bool {
    return std.mem.eql(T, lhs, rhs);
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

    const before_energy = energy.blockEnergy(T, block, cfg);
    if (block.len <= 1 or before_energy == 0) {
        if (stats) |s| s.transport_blocks_rejected += 1;
        return .{ .accepted = false, .before_energy = before_energy, .after_energy = before_energy };
    }

    var original: [Config.max_block_size]T = undefined;
    std.mem.copyForwards(T, original[0..block.len], block);

    var pressures: [Config.max_block_size]i32 = undefined;
    var proposals: [Config.max_block_size]i8 = undefined;
    var desired: [Config.max_block_size]usize = undefined;
    var source_to_final: [Config.max_block_size]usize = undefined;
    var candidate: [Config.max_block_size]T = undefined;

    pressure.compute(T, block, cfg, pressures[0..block.len]);
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
    for (block, 0..) |value, source_index| {
        candidate[source_to_final[source_index]] = value;
    }

    const after_energy = energy.blockEnergy(T, candidate[0..block.len], cfg);
    if (after_energy >= before_energy) {
        std.debug.assert(equalSlices(T, block, original[0..block.len]));
        if (stats) |s| s.transport_blocks_rejected += 1;
        return .{ .accepted = false, .before_energy = before_energy, .after_energy = before_energy };
    }

    std.mem.copyForwards(T, block, candidate[0..block.len]);
    if (stats) |s| s.transport_blocks_accepted += 1;
    return .{ .accepted = true, .before_energy = before_energy, .after_energy = after_energy };
}
