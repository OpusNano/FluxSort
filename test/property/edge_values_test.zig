const std = @import("std");
const adicflux = @import("adicflux");
const reference = @import("../support/reference.zig");

test "min max and mixed signs sort correctly" {
    var xs = [_]i64{ std.math.minInt(i64), 0, -1, std.math.maxInt(i64), 7, -9, std.math.minInt(i64), std.math.maxInt(i64) };
    const original = xs;
    adicflux.sort(i64, xs[0..]);
    try reference.expectSortedAndMatchingReference(i64, original[0..], xs[0..]);
}

test "u8 structured patterns sort correctly" {
    var xs = [_]u8{ 0b11110000, 0b00001111, 0b11001100, 0b00110011, 0b10101010, 0b01010101, 0, 255 };
    const original = xs;
    adicflux.sort(u8, xs[0..]);
    try reference.expectSortedAndMatchingReference(u8, original[0..], xs[0..]);
}
