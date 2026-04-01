const std = @import("std");
const adicflux = @import("adicflux");
const util = adicflux.unstable_test_support.util;
const key = adicflux.unstable_test_support.key;

pub fn referenceSort(comptime T: type, xs: []T) void {
    util.insertionSort(T, xs);
}

pub fn expectSortedAndMatchingReference(comptime T: type, original: []const T, actual: []const T) !void {
    const allocator = std.testing.allocator;
    const expected = try allocator.alloc(T, original.len);
    defer allocator.free(expected);

    std.mem.copyForwards(T, expected, original);
    referenceSort(T, expected);

    try std.testing.expect(adicflux.isSorted(T, actual));
    try std.testing.expect(std.mem.eql(T, expected, actual));
    try expectSameMultiset(T, original, actual);
}

pub fn expectSameMultiset(comptime T: type, lhs: []const T, rhs: []const T) !void {
    const allocator = std.testing.allocator;
    if (lhs.len != rhs.len) return error.TestUnexpectedResult;

    const left_copy = try allocator.alloc(T, lhs.len);
    defer allocator.free(left_copy);
    const right_copy = try allocator.alloc(T, rhs.len);
    defer allocator.free(right_copy);

    std.mem.copyForwards(T, left_copy, lhs);
    std.mem.copyForwards(T, right_copy, rhs);
    util.insertionSort(T, left_copy);
    util.insertionSort(T, right_copy);
    try std.testing.expect(std.mem.eql(T, left_copy, right_copy));
}

pub fn countOrdinaryInversions(comptime T: type, xs: []const T) usize {
    var total: usize = 0;
    for (xs, 0..) |left, i| {
        var j = i + 1;
        while (j < xs.len) : (j += 1) {
            if (key.greaterThan(T, left, xs[j])) total += 1;
        }
    }
    return total;
}
