const std = @import("std");
const fluxsort = @import("fluxsort");

pub fn main() !void {
    var values = [_]i64{ 9, -3, 4, 4, 0, -9, 7, 1, -1, 8 };
    fluxsort.sort(i64, values[0..]);

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("FluxSort demo output:\n", .{});
    for (values, 0..) |value, index| {
        if (index != 0) try stdout.print(", ", .{});
        try stdout.print("{d}", .{value});
    }
    try stdout.print("\n", .{});
    try bw.flush();
}
