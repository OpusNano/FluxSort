const std = @import("std");
const adicflux = @import("adicflux");
const Config = adicflux.testing.config.Config;
const energy = adicflux.testing.energy;

test "pair energy is zero for ordered and equal pairs" {
    const cfg = Config{};
    try std.testing.expectEqual(@as(u64, 0), energy.pairEnergy(i32, -3, 9, cfg));
    try std.testing.expectEqual(@as(u64, 0), energy.pairEnergy(i32, 4, 4, cfg));
}

test "block energy matches hand checked example" {
    const cfg = Config{ .valuation_cap = 4 };
    const xs = [_]u8{ 3, 2, 1 };

    const e32 = energy.pairWeight(u8, 3, 2, cfg);
    const e31 = energy.pairWeight(u8, 3, 1, cfg);
    const e21 = energy.pairWeight(u8, 2, 1, cfg);
    try std.testing.expectEqual(e32 + e31 + e21, energy.blockEnergy(u8, xs[0..], cfg));
}
