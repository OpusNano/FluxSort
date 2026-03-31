const std = @import("std");
const adicflux = @import("adicflux");
const reference = @import("../support/reference.zig");

test "already sorted and reverse sorted structured arrays remain correct" {
    var sorted = [_]i64{ -9, -4, -1, 0, 3, 3, 7, 22, 100 };
    const sorted_original = sorted;
    adicflux.sort(i64, sorted[0..]);
    try reference.expectSortedAndMatchingReference(i64, sorted_original[0..], sorted[0..]);

    var reverse = [_]i64{ 100, 22, 7, 3, 3, 0, -1, -4, -9 };
    const reverse_original = reverse;
    adicflux.sort(i64, reverse[0..]);
    try reference.expectSortedAndMatchingReference(i64, reverse_original[0..], reverse[0..]);
}

test "alternating high low bit patterns sort correctly" {
    var xs = [_]u32{ 0xffff0000, 1, 0xff00ff00, 2, 0xf0f0f0f0, 3, 0xaaaaaaaa, 4 };
    const original = xs;
    adicflux.sort(u32, xs[0..]);
    try reference.expectSortedAndMatchingReference(u32, original[0..], xs[0..]);
}
