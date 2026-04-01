const key = @import("key.zig");
const Stats = @import("stats.zig").Stats;

pub fn oddEvenPass(comptime T: type, xs: []T, parity: usize, stats: ?*Stats) bool {
    var swapped = false;
    if (stats) |s| {
        if (parity == 0) {
            s.cleanup_even_passes += 1;
        } else {
            s.cleanup_odd_passes += 1;
        }
    }

    var i = parity;
    while (i + 1 < xs.len) : (i += 2) {
        if (key.greaterThan(T, xs[i], xs[i + 1])) {
            const tmp = xs[i];
            xs[i] = xs[i + 1];
            xs[i + 1] = tmp;
            swapped = true;
            if (stats) |s| s.cleanup_swaps += 1;
        }
    }
    return swapped;
}

pub fn exactCleanup(comptime T: type, xs: []T, pass_limit: ?usize, stats: ?*Stats) void {
    if (xs.len <= 1) return;

    var pass: usize = 0;
    while (true) : (pass += 1) {
        if (stats) |s| s.cleanup_rounds += 1;

        if (pass_limit) |limit| {
            if (pass >= limit) break;
        }

        const swapped_even = oddEvenPass(T, xs, 0, stats);
        const swapped_odd = oddEvenPass(T, xs, 1, stats);
        if (!swapped_even and !swapped_odd) break;
    }
}
