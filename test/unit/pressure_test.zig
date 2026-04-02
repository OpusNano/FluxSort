const std = @import("std");
const adicflux = @import("adicflux");
const support = adicflux.unstable_test_support;
const Config = support.config.Config;
const energy = support.energy;
const key = support.key;
const pressure = support.pressure;

test "pressure points inverted endpoints toward each other" {
    const cfg = Config{ .neighborhood = 4 };
    const xs = [_]i32{ 9, 1, 2, 3 };
    var values = [_]i32{ 0, 0, 0, 0 };
    pressure.compute(i32, xs[0..], cfg, values[0..]);

    try std.testing.expect(values[0] > 0);
    try std.testing.expect(values[1] < values[2]);
    try std.testing.expect(values[1] < 0 or values[2] < 0 or values[3] < 0);
}

test "pressure proposals stay within displacement bounds" {
    const cfg = Config{ .neighborhood = 2, .max_displacement = 3 };
    const pressures = [_]i32{ -100, -2, 0, 9, 100 };
    var proposals = [_]i8{ 0, 0, 0, 0, 0 };
    pressure.proposalsFromPressure(pressures[0..], cfg, proposals[0..]);

    for (proposals) |proposal| {
        try std.testing.expect(proposal >= -3);
        try std.testing.expect(proposal <= 3);
    }
}

test "combined pressure and energy pass matches separate computations" {
    const cfg = Config{ .neighborhood = 3, .valuation_cap = 8 };
    const xs = [_]i32{ 5, 1, 4, 2, 3 };
    var keys = [_]key.KeyType(i32){ 0, 0, 0, 0, 0 };
    for (xs, 0..) |value, i| keys[i] = key.biasedKey(i32, value);

    var separate_pressures = [_]i32{ 0, 0, 0, 0, 0 };
    var combined_pressures = [_]i32{ 0, 0, 0, 0, 0 };

    pressure.computeFromKeys(i32, keys[0..], cfg, separate_pressures[0..]);
    const combined_energy = pressure.computeFromKeysWithEnergy(i32, keys[0..], cfg, combined_pressures[0..]);
    const separate_energy = energy.blockEnergy(i32, xs[0..], cfg);

    try std.testing.expectEqual(separate_energy, combined_energy);
    try std.testing.expectEqualSlices(i32, separate_pressures[0..], combined_pressures[0..]);
}

fn expectGroupedPressureMatchesExact(xs: []const i32, cfg: Config) !void {
    var keys = [_]key.KeyType(i32){0} ** Config.max_block_size;
    var exact_pressures = [_]i32{0} ** Config.max_block_size;
    var grouped_pressures = [_]i32{0} ** Config.max_block_size;
    var distinct_keys = [_]key.KeyType(i32){0} ** Config.max_block_size;
    var group_ids = [_]u8{0} ** Config.max_block_size;
    var group_counts = [_]usize{0} ** Config.max_block_size;
    var weights = [_]u16{0} ** (Config.max_block_size * Config.max_block_size);

    for (xs, 0..) |value, i| keys[i] = key.biasedKey(i32, value);

    const distinct_count = energy.buildGroupedState(
        i32,
        keys[0..xs.len],
        distinct_keys[0..xs.len],
        group_ids[0..xs.len],
        group_counts[0..xs.len],
    );
    energy.buildGroupWeightMatrix(i32, distinct_keys[0..distinct_count], cfg, weights[0 .. distinct_count * distinct_count]);

    pressure.computeFromKeys(i32, keys[0..xs.len], cfg, exact_pressures[0..xs.len]);
    const grouped_energy = pressure.computeFromGroupIdsWithEnergy(
        group_ids[0..xs.len],
        distinct_count,
        cfg.neighborhood,
        weights[0 .. distinct_count * distinct_count],
        grouped_pressures[0..xs.len],
    );

    try std.testing.expectEqual(energy.blockEnergy(i32, xs, cfg), grouped_energy);
    try std.testing.expectEqualSlices(i32, exact_pressures[0..xs.len], grouped_pressures[0..xs.len]);
}

test "grouped pressure kernel matches exact duplicate-heavy block" {
    const cfg = Config{ .neighborhood = 8, .valuation_cap = 8 };
    try expectGroupedPressureMatchesExact(&[_]i32{ 2, 2, 1, 1, 0, 0, 2, 1, -1, -1, 2, 0 }, cfg);
}

test "grouped pressure kernel matches exact clustered block" {
    const cfg = Config{ .neighborhood = 8, .valuation_cap = 8 };
    try expectGroupedPressureMatchesExact(&[_]i32{ 14, 12, 13, 21, 19, 20, 28, 26, 27, 35, 33, 34 }, cfg);
}

test "grouped pressure kernel matches exact nearly-sorted block" {
    const cfg = Config{ .neighborhood = 8, .valuation_cap = 8 };
    try expectGroupedPressureMatchesExact(&[_]i32{ 0, 1, 3, 2, 4, 5, 7, 6, 8, 9 }, cfg);
}

test "grouped pressure kernel matches exact signed-mixed block" {
    const cfg = Config{ .neighborhood = 8, .valuation_cap = 8 };
    try expectGroupedPressureMatchesExact(&[_]i32{ 8, -1, 7, -2, 6, -3, 5, -4, 4, -5 }, cfg);
}

test "grouped pressure kernel matches exact random small block" {
    const cfg = Config{ .neighborhood = 5, .valuation_cap = 8 };
    try expectGroupedPressureMatchesExact(&[_]i32{ 5, 1, 9, 3, 7, 2, 8, 4, 6, 0 }, cfg);
}
