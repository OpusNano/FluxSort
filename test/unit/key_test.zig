const std = @import("std");
const adicflux = @import("adicflux");
const key = adicflux.testing.key;
const Config = adicflux.testing.config.Config;

test "biased key preserves signed integer order" {
    const values = [_]i8{ -128, -17, -1, 0, 1, 42, 127 };
    var i: usize = 1;
    while (i < values.len) : (i += 1) {
        try std.testing.expect(key.biasedKey(i8, values[i - 1]) < key.biasedKey(i8, values[i]));
    }
}

test "biased key is identity for unsigned integers" {
    try std.testing.expectEqual(@as(u8, 0), key.biasedKey(u8, 0));
    try std.testing.expectEqual(@as(u8, 200), key.biasedKey(u8, 200));
}

test "closeness bonus matches trailing zero valuation cap" {
    const cfg = Config{ .valuation_cap = 5 };
    try std.testing.expectEqual(@as(u8, 3), key.closenessBonus(u8, 8, 0, cfg));
    try std.testing.expectEqual(@as(u8, 5), key.closenessBonus(u8, 7, 7, cfg));
}
