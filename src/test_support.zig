const std = @import("std");

pub const config = @import("core/config.zig");
pub const key = @import("core/key.zig");
pub const energy = @import("core/energy.zig");
pub const pressure = @import("core/pressure.zig");
pub const transport = @import("core/transport.zig");
pub const cleanup = @import("core/cleanup.zig");
pub const stats = @import("core/stats.zig");
pub const util = @import("internal/util.zig");

const Config = config.Config;
const Stats = stats.Stats;

pub const TaggedI32 = struct {
    key_value: i32,
    tag: usize,
};

fn compareTagged(left: TaggedI32, right: TaggedI32) std.math.Order {
    return key.compare(i32, left.key_value, right.key_value);
}

fn pairWeightTagged(left: TaggedI32, right: TaggedI32, cfg: Config) u64 {
    return 1 + key.closenessBonus(i32, left.key_value, right.key_value, cfg);
}

fn blockEnergyTagged(block: []const TaggedI32, cfg: Config) u64 {
    var total: u64 = 0;
    for (block, 0..) |left, i| {
        var j = i + 1;
        while (j < block.len) : (j += 1) {
            if (compareTagged(left, block[j]) == .gt) {
                total += pairWeightTagged(left, block[j], cfg);
            }
        }
    }
    return total;
}

fn computeTaggedPressure(block: []const TaggedI32, cfg: Config, pressures_out: []i32) void {
    @memset(pressures_out[0..block.len], 0);
    if (block.len <= 1) return;

    for (block, 0..) |left, i| {
        const end = @min(block.len, i + cfg.neighborhood + 1);
        var j = i + 1;
        while (j < end) : (j += 1) {
            const right = block[j];
            switch (compareTagged(left, right)) {
                .gt => {
                    const w: i32 = @intCast(pairWeightTagged(left, right, cfg));
                    pressures_out[i] += w;
                    pressures_out[j] -= w;
                },
                .lt => {
                    pressures_out[i] -= 1;
                    pressures_out[j] += 1;
                },
                .eq => {},
            }
        }
    }
}

fn tryTransportTagged(block: []TaggedI32, cfg: Config, out_stats: ?*Stats) bool {
    std.debug.assert(block.len <= Config.max_block_size);
    if (out_stats) |s| s.transport_blocks_visited += 1;

    const before_energy = blockEnergyTagged(block, cfg);
    if (block.len <= 1 or before_energy == 0) {
        if (out_stats) |s| s.transport_blocks_rejected += 1;
        return false;
    }

    var original: [Config.max_block_size]TaggedI32 = undefined;
    std.mem.copyForwards(TaggedI32, original[0..block.len], block);

    var pressures_out: [Config.max_block_size]i32 = undefined;
    var proposals: [Config.max_block_size]i8 = undefined;
    var desired: [Config.max_block_size]usize = undefined;
    var source_to_final: [Config.max_block_size]usize = undefined;
    var candidate: [Config.max_block_size]TaggedI32 = undefined;

    computeTaggedPressure(block, cfg, pressures_out[0..block.len]);
    pressure.proposalsFromPressure(pressures_out[0..block.len], cfg, proposals[0..block.len]);

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
        if (out_stats) |s| s.transport_blocks_rejected += 1;
        return false;
    }

    transport.resolveTargets(desired[0..block.len], source_to_final[0..block.len]);
    for (block, 0..) |value, source_index| {
        candidate[source_to_final[source_index]] = value;
    }

    const after_energy = blockEnergyTagged(candidate[0..block.len], cfg);
    if (after_energy >= before_energy) {
        for (block, original[0..block.len]) |lhs, rhs| {
            std.debug.assert(lhs.key_value == rhs.key_value);
            std.debug.assert(lhs.tag == rhs.tag);
        }
        if (out_stats) |s| s.transport_blocks_rejected += 1;
        return false;
    }

    std.mem.copyForwards(TaggedI32, block, candidate[0..block.len]);
    if (out_stats) |s| s.transport_blocks_accepted += 1;
    return true;
}

fn oddEvenPassTagged(xs: []TaggedI32, parity: usize, out_stats: ?*Stats) bool {
    var swapped = false;
    if (out_stats) |s| {
        if (parity == 0) {
            s.cleanup_even_passes += 1;
        } else {
            s.cleanup_odd_passes += 1;
        }
    }

    var i = parity;
    while (i + 1 < xs.len) : (i += 2) {
        if (compareTagged(xs[i], xs[i + 1]) == .gt) {
            const tmp = xs[i];
            xs[i] = xs[i + 1];
            xs[i + 1] = tmp;
            swapped = true;
            if (out_stats) |s| s.cleanup_swaps += 1;
        }
    }
    return swapped;
}

pub fn exactCleanupTaggedI32(xs: []TaggedI32, pass_limit: ?usize, out_stats: ?*Stats) void {
    if (xs.len <= 1) return;

    var pass: usize = 0;
    while (true) : (pass += 1) {
        if (pass_limit) |limit| {
            if (pass >= limit) break;
        }

        if (out_stats) |s| s.cleanup_rounds += 1;

        const swapped_even = oddEvenPassTagged(xs, 0, out_stats);
        const swapped_odd = oddEvenPassTagged(xs, 1, out_stats);
        if (!swapped_even and !swapped_odd) break;
    }
}

pub fn sortTaggedI32WithStats(xs: []TaggedI32, cfg: Config, out_stats: *Stats) void {
    cfg.validate() catch |err| @panic(@errorName(err));
    if (xs.len <= 1) return;

    var round: usize = 0;
    while (round < cfg.transport_rounds) : (round += 1) {
        var any_accepted = false;
        var start: usize = 0;

        while (start < xs.len) : (start += cfg.block_size) {
            const end = @min(start + cfg.block_size, xs.len);
            const accepted = tryTransportTagged(xs[start..end], cfg, out_stats);
            any_accepted = any_accepted or accepted;
        }

        if (!any_accepted) break;
    }

    exactCleanupTaggedI32(xs, cfg.cleanup_pass_limit, out_stats);
}

pub fn stableReferenceSortTaggedI32(xs: []TaggedI32) void {
    var i: usize = 1;
    while (i < xs.len) : (i += 1) {
        var j = i;
        while (j > 0) : (j -= 1) {
            const left = xs[j - 1];
            const right = xs[j];
            const order = compareTagged(left, right);
            if (order == .gt or (order == .eq and left.tag > right.tag)) {
                xs[j - 1] = right;
                xs[j] = left;
            } else break;
        }
    }
}

pub fn makeTaggedI32FromKeys(keys: []const i32, out: []TaggedI32) void {
    std.debug.assert(out.len >= keys.len);
    for (keys, 0..) |value, i| {
        out[i] = .{ .key_value = value, .tag = i };
    }
}

pub fn sortWithStats(comptime T: type, xs: []T, cfg: Config, out_stats: *Stats) void {
    util.assertIntegerType(T);
    cfg.validate() catch |err| @panic(@errorName(err));

    if (xs.len <= 1) return;

    var round: usize = 0;
    while (round < cfg.transport_rounds) : (round += 1) {
        var any_accepted = false;
        var start: usize = 0;

        while (start < xs.len) : (start += cfg.block_size) {
            const end = @min(start + cfg.block_size, xs.len);
            const result = transport.tryTransportBlock(T, xs[start..end], cfg, out_stats);
            any_accepted = any_accepted or result.accepted;
        }

        if (!any_accepted) break;
    }

    cleanup.exactCleanup(T, xs, cfg.cleanup_pass_limit, out_stats);
}
