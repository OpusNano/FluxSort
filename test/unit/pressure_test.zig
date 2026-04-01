const std = @import("std");
const adicflux = @import("adicflux");
const support = adicflux.unstable_test_support;
const Config = support.config.Config;
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
