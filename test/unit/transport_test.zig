const std = @import("std");
const adicflux = @import("adicflux");
const Config = adicflux.testing.config.Config;
const energy = adicflux.testing.energy;
const transport = adicflux.testing.transport;

test "stable target resolution preserves source order on ties" {
    const desired = [_]usize{ 1, 1, 0, 0 };
    var resolved = [_]usize{ 0, 0, 0, 0 };
    transport.resolveTargets(desired[0..], resolved[0..]);
    try std.testing.expectEqualSlices(usize, &[_]usize{ 2, 3, 0, 1 }, &resolved);
}

test "accepted transport move strictly reduces local energy" {
    const cfg = Config{ .block_size = 8, .neighborhood = 1, .max_displacement = 2 };
    var xs = [_]i32{ 2, 0, 1 };
    const before = energy.blockEnergy(i32, xs[0..], cfg);
    const result = transport.tryTransportBlock(i32, xs[0..], cfg);
    const after = energy.blockEnergy(i32, xs[0..], cfg);

    try std.testing.expect(result.accepted);
    try std.testing.expect(before > after);
    try std.testing.expectEqual(result.before_energy, before);
    try std.testing.expectEqual(result.after_energy, after);
}
