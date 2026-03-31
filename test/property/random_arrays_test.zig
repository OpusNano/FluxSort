const std = @import("std");
const adicflux = @import("adicflux");
const reference = @import("../support/reference.zig");

test "randomized arrays match reference sort" {
    var prng = std.Random.DefaultPrng.init(0x2ad1cf1);
    const random = prng.random();

    var original: [256]i32 = undefined;
    var actual: [256]i32 = undefined;

    const sizes = [_]usize{ 0, 1, 2, 3, 4, 5, 8, 16, 31, 32, 33, 48, 63, 64, 65, 96, 128, 192, 256 };
    for (sizes) |size| {
        var iteration: usize = 0;
        while (iteration < 25) : (iteration += 1) {
            for (0..size) |i| {
                const value = random.int(i32);
                original[i] = value;
                actual[i] = value;
            }

            adicflux.sort(i32, actual[0..size]);
            try reference.expectSortedAndMatchingReference(i32, original[0..size], actual[0..size]);

            var second = actual;
            adicflux.sort(i32, second[0..size]);
            try std.testing.expectEqualSlices(i32, actual[0..size], second[0..size]);
        }
    }
}
