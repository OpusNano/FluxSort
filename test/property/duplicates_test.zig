const std = @import("std");
const adicflux = @import("adicflux");
const reference = @import("../support/reference.zig");

test "duplicates and all equal arrays are handled correctly" {
    const cases = [_][12]i16{
        [_]i16{ 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5 },
        [_]i16{ 3, 1, 3, 2, 3, 1, 3, 2, 3, 1, 3, 2 },
        [_]i16{ -1, 0, -1, 0, -1, 0, -1, 0, -1, 0, -1, 0 },
    };

    for (cases) |case_values| {
        var actual = case_values;
        adicflux.sort(i16, actual[0..]);
        try reference.expectSortedAndMatchingReference(i16, case_values[0..], actual[0..]);
    }
}
