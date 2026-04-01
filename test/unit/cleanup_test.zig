const std = @import("std");
const adicflux = @import("adicflux");
const support = adicflux.unstable_test_support;
const cleanup = support.cleanup;
const util = support.util;
const reference = @import("../support/reference.zig");

test "odd-even cleanup sorts reverse input" {
    var xs = [_]i32{ 5, 4, 3, 2, 1, 0 };
    cleanup.exactCleanup(i32, xs[0..], null, null);
    try std.testing.expect(util.isSorted(i32, xs[0..]));
}

test "cleanup does not swap equal adjacent values" {
    var xs = [_]i32{ 2, 2, 1, 1 };
    _ = cleanup.oddEvenPass(i32, xs[0..], 0, null);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 2, 2, 1, 1 }, &xs);
}

test "swapping one strict adjacent inversion reduces ordinary inversion count by one" {
    var xs = [_]i32{ 0, 2, 1, 3 };
    const before = reference.countOrdinaryInversions(i32, xs[0..]);
    const swapped = cleanup.oddEvenPass(i32, xs[0..], 1, null);
    const after = reference.countOrdinaryInversions(i32, xs[0..]);

    try std.testing.expect(swapped);
    try std.testing.expectEqual(before - 1, after);
}

test "zero adjacent inversions implies sorted for integer slices" {
    const xs = [_]i32{ -3, -1, 0, 0, 2, 7, 9 };
    try std.testing.expectEqual(@as(usize, 0), reference.countOrdinaryInversions(i32, xs[0..]));
    try std.testing.expect(util.isSorted(i32, xs[0..]));
}
