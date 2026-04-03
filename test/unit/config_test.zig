const std = @import("std");
const fluxsort = @import("fluxsort");
const support = fluxsort.unstable_test_support;

const Config = support.config.Config;

test "config validation rejects invalid values" {
    try std.testing.expectError(Config.Error.BlockSizeZero, (Config{ .block_size = 0 }).validate());
    try std.testing.expectError(Config.Error.BlockSizeTooLarge, (Config{ .block_size = Config.max_block_size + 1 }).validate());
    try std.testing.expectError(Config.Error.NeighborhoodZero, (Config{ .neighborhood = 0 }).validate());
    try std.testing.expectError(Config.Error.MaxDisplacementZero, (Config{ .max_displacement = 0 }).validate());
    try std.testing.expectError(Config.Error.MaxDisplacementTooLarge, (Config{ .max_displacement = std.math.maxInt(i8) + 1 }).validate());
    try std.testing.expectError(Config.Error.TransportRoundsZero, (Config{ .transport_rounds = 0 }).validate());
}

test "cleanup pass limit is honored by sortWithConfig" {
    const limited_cfg = Config{
        .block_size = 2,
        .neighborhood = 1,
        .max_displacement = 1,
        .transport_rounds = 1,
        .cleanup_pass_limit = 0,
    };
    const exact_cfg = Config{
        .block_size = 2,
        .neighborhood = 1,
        .max_displacement = 1,
        .transport_rounds = 1,
        .cleanup_pass_limit = null,
    };

    var limited = [_]i32{ 8, 7, 6, 5, 4, 3, 2, 1 };
    var exact = limited;

    fluxsort.sortWithConfig(i32, limited[0..], limited_cfg);
    fluxsort.sortWithConfig(i32, exact[0..], exact_cfg);

    try std.testing.expect(!fluxsort.isSorted(i32, limited[0..]));
    try std.testing.expect(fluxsort.isSorted(i32, exact[0..]));
}
