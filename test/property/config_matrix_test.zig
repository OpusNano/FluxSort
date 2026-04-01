const std = @import("std");
const validation = @import("../support/validation.zig");

const Config = validation.Config;

fn fillPattern(comptime T: type, xs: []T, pattern: enum { sorted, reverse, alternating, clustered, duplicate_heavy, signed_wave }) void {
    switch (pattern) {
        .sorted => {
            for (xs, 0..) |*slot, i| slot.* = @intCast(i);
        },
        .reverse => {
            for (xs, 0..) |*slot, i| slot.* = @intCast(xs.len - 1 - i);
        },
        .alternating => {
            for (xs, 0..) |*slot, i| {
                if (i % 2 == 0) {
                    slot.* = @intCast(xs.len - 1 - i / 2);
                } else {
                    slot.* = @intCast(i / 2);
                }
            }
        },
        .clustered => {
            for (xs, 0..) |*slot, i| {
                const value: i32 = @as(i32, @intCast((i / 4) * 3)) - @as(i32, @intCast(i % 3));
                slot.* = @intCast(value);
            }
        },
        .duplicate_heavy => {
            for (xs, 0..) |*slot, i| slot.* = @intCast(@as(i32, @intCast(i % 5)) - 2);
        },
        .signed_wave => {
            for (xs, 0..) |*slot, i| {
                const base: i32 = @as(i32, @intCast(i % 7)) - 3;
                slot.* = @intCast(if (i % 3 == 0) -base else base * 2);
            }
        },
    }
}

fn fillKeysFromCode(out: []i32, code: usize, alphabet: []const i32) void {
    var mut_code = code;
    for (out) |*slot| {
        slot.* = alphabet[mut_code % alphabet.len];
        mut_code /= alphabet.len;
    }
}

test "exact config matrix matches reference across structured patterns" {
    const configs = [_]Config{
        Config{ .block_size = 1, .valuation_cap = 0, .neighborhood = 1, .max_displacement = 1, .transport_rounds = 1 },
        Config{ .block_size = 4, .valuation_cap = 2, .neighborhood = 1, .max_displacement = 1, .transport_rounds = 2 },
        Config{ .block_size = 8, .valuation_cap = 8, .neighborhood = 3, .max_displacement = 2, .transport_rounds = 4 },
        Config{ .block_size = 16, .valuation_cap = 12, .neighborhood = 6, .max_displacement = 3, .transport_rounds = 4 },
        Config{ .block_size = 32, .valuation_cap = 16, .neighborhood = 8, .max_displacement = 4, .transport_rounds = 5 },
    };
    const sizes = [_]usize{ 0, 1, 2, 3, 4, 5, 8, 15, 16, 17, 31, 32, 33, 63, 64, 65, 96, 128 };

    var xs: [128]i32 = undefined;
    inline for (configs) |cfg| {
        for (sizes) |size| {
            inline for (.{ .sorted, .reverse, .alternating, .clustered, .duplicate_heavy, .signed_wave }) |pattern| {
                fillPattern(i32, xs[0..size], pattern);
                try validation.expectExactSortCase(i32, xs[0..size], cfg);
            }
        }
    }
}

test "limited cleanup config matrix preserves invariants on structured patterns" {
    const configs = [_]Config{
        Config{ .block_size = 4, .valuation_cap = 2, .neighborhood = 1, .max_displacement = 1, .transport_rounds = 1, .cleanup_pass_limit = 0 },
        Config{ .block_size = 8, .valuation_cap = 8, .neighborhood = 2, .max_displacement = 2, .transport_rounds = 2, .cleanup_pass_limit = 1 },
        Config{ .block_size = 16, .valuation_cap = 12, .neighborhood = 4, .max_displacement = 3, .transport_rounds = 3, .cleanup_pass_limit = 2 },
    };
    const sizes = [_]usize{ 2, 3, 4, 5, 8, 16, 17, 31, 32, 48, 64 };

    var xs: [64]i32 = undefined;
    inline for (configs) |cfg| {
        for (sizes) |size| {
            inline for (.{ .reverse, .alternating, .clustered, .duplicate_heavy, .signed_wave }) |pattern| {
                fillPattern(i32, xs[0..size], pattern);
                try validation.expectLimitedSortCase(i32, xs[0..size], cfg);
            }
        }
    }
}

test "small exhaustive config matrix matches reference" {
    const configs = [_]Config{
        Config{ .block_size = 1, .valuation_cap = 0, .neighborhood = 1, .max_displacement = 1, .transport_rounds = 1 },
        Config{ .block_size = 4, .valuation_cap = 4, .neighborhood = 1, .max_displacement = 1, .transport_rounds = 2 },
        Config{ .block_size = 8, .valuation_cap = 8, .neighborhood = 2, .max_displacement = 2, .transport_rounds = 3 },
    };
    const alphabet = [_]i32{ -1, 0, 1 };

    var len: usize = 0;
    while (len <= 6) : (len += 1) {
        var total_cases: usize = 1;
        for (0..len) |_| total_cases *= alphabet.len;

        var xs: [6]i32 = undefined;
        var case_index: usize = 0;
        while (case_index < total_cases) : (case_index += 1) {
            fillKeysFromCode(xs[0..len], case_index, &alphabet);
            inline for (configs) |cfg| {
                try validation.expectExactSortCase(i32, xs[0..len], cfg);
            }
        }
    }
}

test "random config matrix preserves exact behavior across bounded random cases" {
    const configs = [_]Config{
        Config{ .block_size = 1, .valuation_cap = 0, .neighborhood = 1, .max_displacement = 1, .transport_rounds = 1 },
        Config{ .block_size = 4, .valuation_cap = 3, .neighborhood = 1, .max_displacement = 1, .transport_rounds = 2 },
        Config{ .block_size = 8, .valuation_cap = 8, .neighborhood = 3, .max_displacement = 2, .transport_rounds = 4 },
        Config{ .block_size = 32, .valuation_cap = 16, .neighborhood = 8, .max_displacement = 4, .transport_rounds = 5 },
    };

    var prng = std.Random.DefaultPrng.init(0xc0f19aa);
    const random = prng.random();
    var xs: [160]i32 = undefined;
    const sizes = [_]usize{ 0, 1, 2, 3, 4, 8, 15, 16, 17, 31, 32, 33, 64, 96, 128, 160 };

    inline for (configs) |cfg| {
        for (sizes) |size| {
            const iterations: usize = if (size <= 32) 18 else if (size <= 96) 10 else 6;
            var iteration: usize = 0;
            while (iteration < iterations) : (iteration += 1) {
                for (0..size) |i| xs[i] = random.int(i32);
                try validation.expectExactSortCase(i32, xs[0..size], cfg);
            }
        }
    }
}

test "tagged duplicate-heavy config matrix matches stable reference" {
    const configs = [_]Config{
        Config{ .block_size = 1, .valuation_cap = 0, .neighborhood = 1, .max_displacement = 1, .transport_rounds = 1 },
        Config{ .block_size = 4, .valuation_cap = 4, .neighborhood = 1, .max_displacement = 1, .transport_rounds = 3 },
        Config{ .block_size = 8, .valuation_cap = 8, .neighborhood = 3, .max_displacement = 2, .transport_rounds = 4 },
        Config{ .block_size = 16, .valuation_cap = 12, .neighborhood = 4, .max_displacement = 3, .transport_rounds = 4 },
    };

    var prng = std.Random.DefaultPrng.init(0xad1cf10);
    const random = prng.random();
    var keys: [96]i32 = undefined;
    const sizes = [_]usize{ 0, 1, 2, 3, 4, 8, 16, 17, 32, 48, 64, 96 };

    inline for (configs) |cfg| {
        for (sizes) |size| {
            var iteration: usize = 0;
            while (iteration < 16) : (iteration += 1) {
                for (0..size) |i| {
                    keys[i] = switch (i % 4) {
                        0 => 0,
                        1 => @as(i32, @intCast(random.uintLessThan(u32, 3))) - 1,
                        2 => @as(i32, @intCast(random.uintLessThan(u32, 5))) - 2,
                        else => 1,
                    };
                }
                try validation.expectTaggedStableCase(keys[0..size], cfg);
            }
        }
    }
}
