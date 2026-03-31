const std = @import("std");
const adicflux = @import("adicflux");
const util = adicflux.testing.util;

pub fn referenceSort(comptime T: type, xs: []T) void {
    util.insertionSort(T, xs);
}

pub fn expectSortedAndMatchingReference(comptime T: type, original: []const T, actual: []const T) !void {
    var expected: [256]T = undefined;
    try std.testing.expect(original.len <= expected.len);
    std.mem.copyForwards(T, expected[0..original.len], original);
    referenceSort(T, expected[0..original.len]);

    try std.testing.expect(adicflux.isSorted(T, actual));
    try std.testing.expect(std.mem.eql(T, expected[0..original.len], actual));
    try std.testing.expect(util.sameMultiset(T, original, actual));
}
