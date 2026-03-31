const std = @import("std");
const adicflux = @import("adicflux");
const cleanup = adicflux.testing.cleanup;
const util = adicflux.testing.util;

test "odd-even cleanup sorts reverse input" {
    var xs = [_]i32{ 5, 4, 3, 2, 1, 0 };
    cleanup.exactCleanup(i32, xs[0..], null);
    try std.testing.expect(util.isSorted(i32, xs[0..]));
}

test "cleanup does not swap equal adjacent values" {
    var xs = [_]i32{ 2, 2, 1, 1 };
    _ = cleanup.oddEvenPass(i32, xs[0..], 0);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 2, 2, 1, 1 }, &xs);
}
