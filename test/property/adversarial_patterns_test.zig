const std = @import("std");
const adicflux = @import("adicflux");
const reference = @import("../support/reference.zig");

test "large reverse chunks across block boundaries match reference" {
    var xs: [384]i32 = undefined;
    for (0..xs.len) |i| {
        const chunk = i / 32;
        const offset = i % 32;
        xs[i] = @intCast((11 - @as(i32, @intCast(chunk))) * 32 + (31 - @as(i32, @intCast(offset))));
    }
    const original = xs;
    adicflux.sort(i32, xs[0..]);
    try reference.expectSortedAndMatchingReference(i32, original[0..], xs[0..]);
}

test "alternating duplicate bands and extremes match reference" {
    var xs: [257]i64 = undefined;
    for (0..xs.len) |i| {
        xs[i] = switch (i % 5) {
            0 => std.math.maxInt(i64),
            1 => std.math.minInt(i64),
            2 => @as(i64, @intCast(i % 17)),
            3 => -@as(i64, @intCast(i % 17)),
            else => 0,
        };
    }
    const original = xs;
    adicflux.sort(i64, xs[0..]);
    try reference.expectSortedAndMatchingReference(i64, original[0..], xs[0..]);
}

test "high valuation clusters and sawtooth layout match reference" {
    var xs: [320]u32 = undefined;
    for (0..xs.len) |i| {
        const base: u32 = @intCast((i % 40) << 4);
        const low_bits: u32 = @intCast((39 - (i % 40)) & 0xf);
        xs[i] = base | low_bits;
    }
    const original = xs;
    adicflux.sort(u32, xs[0..]);
    try reference.expectSortedAndMatchingReference(u32, original[0..], xs[0..]);
}
