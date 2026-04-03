const std = @import("std");
const fluxsort = @import("fluxsort");
const support = fluxsort.unstable_test_support;
const reference = @import("reference.zig");

pub const Config = support.config.Config;
pub const Stats = support.stats.Stats;
pub const TaggedI32 = support.TaggedI32;

pub fn expectStatsBalanced(stats: Stats, allow_zero_transport_visits: bool) !void {
    if (allow_zero_transport_visits) {
        try std.testing.expect(stats.transport_blocks_visited >= 0);
    } else {
        try std.testing.expect(stats.transport_blocks_visited > 0);
    }

    try std.testing.expectEqual(
        stats.transport_blocks_visited,
        stats.transport_blocks_accepted + stats.transport_blocks_rejected,
    );
    try std.testing.expectEqual(stats.cleanup_rounds, stats.cleanup_even_passes);
    try std.testing.expectEqual(stats.cleanup_rounds, stats.cleanup_odd_passes);
}

pub fn expectExactSortCase(comptime T: type, original: []const T, cfg: Config) !void {
    const allocator = std.testing.allocator;
    const actual = try allocator.alloc(T, original.len);
    defer allocator.free(actual);

    std.mem.copyForwards(T, actual, original);
    var stats = Stats{};
    support.sortWithStats(T, actual, cfg, &stats);

    try reference.expectSortedAndMatchingReference(T, original, actual);
    try expectStatsBalanced(stats, original.len <= 1);

    if (original.len > 1) {
        const blocks_per_round = @divFloor(original.len + cfg.block_size - 1, cfg.block_size);
        try std.testing.expect(stats.transport_blocks_visited >= blocks_per_round);
        try std.testing.expect(stats.cleanup_rounds > 0);
    }
}

pub fn expectLimitedSortCase(comptime T: type, original: []const T, cfg: Config) !void {
    const allocator = std.testing.allocator;
    const actual = try allocator.alloc(T, original.len);
    defer allocator.free(actual);

    std.mem.copyForwards(T, actual, original);
    var stats = Stats{};
    support.sortWithStats(T, actual, cfg, &stats);

    try reference.expectSameMultiset(T, original, actual);
    try std.testing.expectEqual(fluxsort.isSorted(T, actual), support.util.isSorted(T, actual));
    try expectStatsBalanced(stats, original.len <= 1);

    if (cfg.cleanup_pass_limit) |limit| {
        try std.testing.expect(stats.cleanup_rounds <= limit);
        if (limit == 0) {
            try std.testing.expectEqual(@as(usize, 0), stats.cleanup_rounds);
            try std.testing.expectEqual(@as(usize, 0), stats.cleanup_swaps);
        }
    }

    if (fluxsort.isSorted(T, actual)) {
        try reference.expectSortedAndMatchingReference(T, original, actual);
    }
}

pub fn expectTaggedStableCase(keys: []const i32, cfg: Config) !void {
    const allocator = std.testing.allocator;
    const actual = try allocator.alloc(TaggedI32, keys.len);
    defer allocator.free(actual);
    const expected = try allocator.alloc(TaggedI32, keys.len);
    defer allocator.free(expected);

    support.makeTaggedI32FromKeys(keys, actual);
    support.makeTaggedI32FromKeys(keys, expected);

    var stats = Stats{};
    support.sortTaggedI32WithStats(actual, cfg, &stats);
    support.stableReferenceSortTaggedI32(expected);

    for (expected, actual) |lhs, rhs| {
        try std.testing.expectEqual(lhs.key_value, rhs.key_value);
        try std.testing.expectEqual(lhs.tag, rhs.tag);
    }

    try expectStatsBalanced(stats, keys.len <= 1);
}
