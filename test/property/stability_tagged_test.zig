const std = @import("std");
const adicflux = @import("adicflux");
const support = adicflux.unstable_test_support;

const Config = support.config.Config;
const Stats = support.stats.Stats;
const TaggedI32 = support.TaggedI32;

fn expectTaggedSortMatchesStableReference(keys: []const i32, cfg: Config) !void {
    const allocator = std.testing.allocator;
    const actual = try allocator.alloc(TaggedI32, keys.len);
    defer allocator.free(actual);
    const expected = try allocator.alloc(TaggedI32, keys.len);
    defer allocator.free(expected);

    support.makeTaggedI32FromKeys(keys, actual);
    support.makeTaggedI32FromKeys(keys, expected);

    var stats = Stats{};
    support.sortTaggedI32WithStats(actual, cfg, &stats);
    support.stableReferenceSortTaggedI32(expected);

    for (expected, actual) |lhs, rhs| {
        try std.testing.expectEqual(lhs.key_value, rhs.key_value);
        try std.testing.expectEqual(lhs.tag, rhs.tag);
    }
}

fn fillKeysFromCode(out: []i32, code: usize, alphabet: []const i32) void {
    var mut_code = code;
    for (out) |*slot| {
        slot.* = alphabet[mut_code % alphabet.len];
        mut_code /= alphabet.len;
    }
}

test "tagged identity search finds no instability on small exhaustive cases" {
    const cfg = Config{
        .block_size = 4,
        .neighborhood = 2,
        .max_displacement = 2,
        .transport_rounds = 3,
    };
    const alphabet = [_]i32{ -1, 0, 1 };

    var len: usize = 0;
    while (len <= 7) : (len += 1) {
        var total_cases: usize = 1;
        for (0..len) |_| total_cases *= alphabet.len;

        var keys_storage: [7]i32 = undefined;
        var case_index: usize = 0;
        while (case_index < total_cases) : (case_index += 1) {
            fillKeysFromCode(keys_storage[0..len], case_index, &alphabet);
            try expectTaggedSortMatchesStableReference(keys_storage[0..len], cfg);
        }
    }
}

test "tagged identity randomized stress matches stable reference" {
    const cfg = Config{
        .block_size = 8,
        .neighborhood = 3,
        .max_displacement = 2,
        .transport_rounds = 4,
    };
    var prng = std.Random.DefaultPrng.init(0x51ab1e);
    const random = prng.random();

    var keys: [96]i32 = undefined;
    const sizes = [_]usize{ 0, 1, 2, 3, 4, 5, 8, 16, 17, 31, 32, 33, 48, 64, 95, 96 };
    for (sizes) |size| {
        var iteration: usize = 0;
        while (iteration < 20) : (iteration += 1) {
            for (0..size) |i| {
                keys[i] = @as(i32, @intCast(random.uintLessThan(u32, 5))) - 2;
            }
            try expectTaggedSortMatchesStableReference(keys[0..size], cfg);
        }
    }
}
