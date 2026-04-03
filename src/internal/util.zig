const std = @import("std");
const key = @import("../core/key.zig");

pub fn assertIntegerType(comptime T: type) void {
    switch (@typeInfo(T)) {
        .int => {},
        else => @compileError("FluxSort only supports integer element types"),
    }
}

pub fn isSorted(comptime T: type, xs: []const T) bool {
    if (xs.len <= 1) return true;
    var i: usize = 1;
    while (i < xs.len) : (i += 1) {
        if (key.greaterThan(T, xs[i - 1], xs[i])) return false;
    }
    return true;
}

pub fn insertionSort(comptime T: type, xs: []T) void {
    var i: usize = 1;
    while (i < xs.len) : (i += 1) {
        var j = i;
        while (j > 0 and key.greaterThan(T, xs[j - 1], xs[j])) : (j -= 1) {
            const tmp = xs[j - 1];
            xs[j - 1] = xs[j];
            xs[j] = tmp;
        }
    }
}

pub fn sameMultiset(comptime T: type, lhs: []const T, rhs: []const T) bool {
    if (lhs.len != rhs.len) return false;

    var left_copy: [256]T = undefined;
    var right_copy: [256]T = undefined;
    if (lhs.len > left_copy.len) return false;

    std.mem.copyForwards(T, left_copy[0..lhs.len], lhs);
    std.mem.copyForwards(T, right_copy[0..rhs.len], rhs);
    insertionSort(T, left_copy[0..lhs.len]);
    insertionSort(T, right_copy[0..rhs.len]);
    return std.mem.eql(T, left_copy[0..lhs.len], right_copy[0..rhs.len]);
}
