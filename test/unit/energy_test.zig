const std = @import("std");
const fluxsort = @import("fluxsort");
const support = fluxsort.unstable_test_support;
const Config = support.config.Config;
const energy = support.energy;
const key = support.key;

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

test "permutation delta energy matches exact recomputation" {
    const cfg = Config{ .valuation_cap = 8 };
    const xs = [_]i32{ 5, 1, 4, 2 };
    const perm = [_]usize{ 2, 0, 3, 1 };
    var permuted = [_]i32{ 0, 0, 0, 0 };
    var keys = [_]key.KeyType(i32){ 0, 0, 0, 0 };

    for (xs, 0..) |value, i| {
        permuted[perm[i]] = value;
        keys[i] = key.biasedKey(i32, value);
    }

    const before = energy.blockEnergy(i32, xs[0..], cfg);
    const after_exact = energy.blockEnergy(i32, permuted[0..], cfg);
    const after_delta = energy.energyAfterPermutationFromKeys(i32, keys[0..], perm[0..], before, cfg);

    try std.testing.expectEqual(after_exact, after_delta);
}

test "moved-only permutation delta energy matches exact recomputation" {
    const cfg = Config{ .valuation_cap = 8 };
    const xs = [_]i32{ 0, 1, 3, 2, 4, 5 };
    const perm = [_]usize{ 0, 1, 3, 2, 4, 5 };
    var permuted = [_]i32{ 0, 0, 0, 0, 0, 0 };
    var keys = [_]key.KeyType(i32){ 0, 0, 0, 0, 0, 0 };
    const moved = [_]usize{ 2, 3 };

    for (xs, 0..) |value, i| {
        permuted[perm[i]] = value;
        keys[i] = key.biasedKey(i32, value);
    }

    const before = energy.blockEnergy(i32, xs[0..], cfg);
    const after_exact = energy.blockEnergy(i32, permuted[0..], cfg);
    const after_delta = energy.energyAfterPermutationFromMovedKeys(i32, keys[0..], perm[0..], moved[0..], before, cfg);

    try std.testing.expectEqual(after_exact, after_delta);
}

test "grouped energy matches exact recomputation on duplicate-heavy block" {
    const cfg = Config{ .valuation_cap = 8 };
    const xs = [_]i32{ 2, 2, 1, 1, 0, 0, 2, 1 };
    var keys = [_]key.KeyType(i32){ 0, 0, 0, 0, 0, 0, 0, 0 };
    var distinct_keys = [_]key.KeyType(i32){0} ** 8;
    var group_ids = [_]u8{0} ** 8;
    var group_counts = [_]usize{0} ** 8;
    var weights = [_]u16{0} ** (8 * 8);

    for (xs, 0..) |value, i| keys[i] = key.biasedKey(i32, value);
    const distinct_count = energy.buildGroupedState(i32, keys[0..], distinct_keys[0..], group_ids[0..], group_counts[0..]);
    energy.buildGroupWeightMatrix(i32, distinct_keys[0..distinct_count], cfg, weights[0 .. distinct_count * distinct_count]);

    const exact = energy.blockEnergy(i32, xs[0..], cfg);
    const grouped = energy.blockEnergyFromGroupIds(group_ids[0..], distinct_count, weights[0 .. distinct_count * distinct_count]);
    try std.testing.expectEqual(exact, grouped);
}
