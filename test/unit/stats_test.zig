const std = @import("std");
const adicflux = @import("adicflux");
const support = adicflux.unstable_test_support;

const Config = support.config.Config;
const Stats = support.stats.Stats;

test "sortWithStats records transport and cleanup activity" {
    const cfg = Config{
        .block_size = 8,
        .neighborhood = 2,
        .max_displacement = 2,
        .transport_rounds = 2,
    };

    var xs = [_]i32{ 9, 1, 8, 2, 7, 3, 6, 4, 5, 0 };
    var stats = Stats{};
    support.sortWithStats(i32, xs[0..], cfg, &stats);

    try std.testing.expect(stats.transport_blocks_visited > 0);
    try std.testing.expect(stats.transport_blocks_accepted + stats.transport_blocks_rejected == stats.transport_blocks_visited);
    try std.testing.expect(stats.cleanup_rounds > 0);
    try std.testing.expect(stats.cleanup_even_passes == stats.cleanup_rounds);
    try std.testing.expect(stats.cleanup_odd_passes == stats.cleanup_rounds);
}
