const std = @import("std");
const fluxsort = @import("fluxsort");

pub fn main() !void {
    var values = [_]i32{ 12, -4, 7, 7, 0, -8, 19, 3 };
    fluxsort.sort(i32, values[0..]);

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("sorted:", .{});
    for (values) |value| {
        try stdout.print(" {d}", .{value});
    }
    try stdout.print("\n", .{});
    try bw.flush();
}
