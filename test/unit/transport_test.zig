const std = @import("std");
const adicflux = @import("adicflux");
const support = adicflux.unstable_test_support;
const Config = support.config.Config;
const energy = support.energy;
const transport = support.transport;
const reference = @import("../support/reference.zig");

fn expectPermutation(mapping: []const usize) !void {
    var seen = [_]bool{false} ** Config.max_block_size;
    for (mapping) |value| {
        try std.testing.expect(value < mapping.len);
        try std.testing.expect(!seen[value]);
        seen[value] = true;
    }
    for (seen[0..mapping.len]) |value| {
        try std.testing.expect(value);
    }
}

test "stable target resolution preserves source order on ties" {
    const desired = [_]usize{ 1, 1, 0, 0 };
    var resolved = [_]usize{ 0, 0, 0, 0 };
    transport.resolveTargets(desired[0..], resolved[0..]);
    try std.testing.expectEqualSlices(usize, &[_]usize{ 2, 3, 0, 1 }, &resolved);
    try expectPermutation(&resolved);
}

test "target resolution always yields a valid permutation" {
    const desired = [_]usize{ 3, 0, 3, 2, 1, 2, 0 };
    var resolved = [_]usize{ 0, 0, 0, 0, 0, 0, 0 };
    transport.resolveTargets(desired[0..], resolved[0..]);
    try expectPermutation(&resolved);
}

test "accepted transport move strictly reduces local energy" {
    const cfg = Config{ .block_size = 8, .neighborhood = 1, .max_displacement = 2 };
    const original = [_]i32{ 2, 0, 1 };
    var xs = original;
    const before = energy.blockEnergy(i32, xs[0..], cfg);
    const result = transport.tryTransportBlock(i32, xs[0..], cfg, null);
    const after = energy.blockEnergy(i32, xs[0..], cfg);

    try std.testing.expect(result.accepted);
    try std.testing.expect(before > after);
    try std.testing.expectEqual(result.before_energy, before);
    try std.testing.expectEqual(result.after_energy, after);
    try reference.expectSameMultiset(i32, original[0..], xs[0..]);
}

test "rejected transport leaves sorted block unchanged" {
    const cfg = Config{ .block_size = 8, .neighborhood = 2, .max_displacement = 2 };
    const original = [_]i32{ -2, -1, 0, 1, 2, 3 };
    var xs = original;
    const result = transport.tryTransportBlock(i32, xs[0..], cfg, null);

    try std.testing.expect(!result.accepted);
    try std.testing.expectEqual(result.before_energy, result.after_energy);
    try std.testing.expectEqualSlices(i32, original[0..], xs[0..]);
}

test "accepted transport keeps block as a permutation" {
    const cfg = Config{ .block_size = 8, .neighborhood = 3, .max_displacement = 2 };
    const original = [_]i32{ 9, 1, 8, 2, 7, 3, 6, 4 };
    var xs = original;
    const result = transport.tryTransportBlock(i32, xs[0..], cfg, null);

    if (result.accepted) {
        try reference.expectSameMultiset(i32, original[0..], xs[0..]);
        try std.testing.expect(result.after_energy < result.before_energy);
    } else {
        try std.testing.expectEqualSlices(i32, original[0..], xs[0..]);
    }
}
