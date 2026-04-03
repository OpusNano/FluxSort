const std = @import("std");
const fluxsort = @import("fluxsort");

const support = fluxsort.unstable_test_support;
const Stats = support.stats.Stats;
const Config = fluxsort.Config;

const Dataset = enum {
    random,
    sorted,
    reverse,
    nearly_sorted,
    duplicate_heavy,
    clustered,
    signed_mixed,
    alternating,
};

const Result = struct {
    algo: []const u8,
    dataset: Dataset,
    size: usize,
    iterations: usize,
    total_ns: u64,
    avg_ns: u64,
    avg_ns_per_item: u64,
    transport_accepted: usize,
    transport_rejected: usize,
    grouped_exact_blocks: usize,
    moved_delta_blocks: usize,
    full_delta_blocks: usize,
    cleanup_rounds: usize,
    cleanup_swaps: usize,
};

const Filters = struct {
    datasets: ?[]const u8 = null,
    sizes: ?[]const u8 = null,
    iterations_override: ?usize = null,
};

fn datasetName(dataset: Dataset) []const u8 {
    return @tagName(dataset);
}

fn datasetSelected(filters: Filters, dataset: Dataset) bool {
    if (filters.datasets) |list| {
        return std.mem.indexOf(u8, list, datasetName(dataset)) != null;
    }
    return true;
}

fn sizeSelected(filters: Filters, size: usize) bool {
    if (filters.sizes) |list| {
        var buf: [32]u8 = undefined;
        const rendered = std.fmt.bufPrint(&buf, "{d}", .{size}) catch return false;
        return std.mem.indexOf(u8, list, rendered) != null;
    }
    return true;
}

fn parseFilters(allocator: std.mem.Allocator) !Filters {
    var filters = Filters{};
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    _ = args.next();
    while (args.next()) |arg| {
        if (std.mem.startsWith(u8, arg, "--datasets=")) {
            filters.datasets = try allocator.dupe(u8, arg[11..]);
        } else if (std.mem.startsWith(u8, arg, "--sizes=")) {
            filters.sizes = try allocator.dupe(u8, arg[8..]);
        } else if (std.mem.startsWith(u8, arg, "--iterations=")) {
            filters.iterations_override = try std.fmt.parseInt(usize, arg[13..], 10);
        }
    }

    return filters;
}

fn fillDataset(xs: []i32, dataset: Dataset, random: std.Random) void {
    switch (dataset) {
        .random => {
            for (xs) |*slot| slot.* = random.int(i32);
        },
        .sorted => {
            for (xs, 0..) |*slot, i| slot.* = @intCast(i);
        },
        .reverse => {
            for (xs, 0..) |*slot, i| slot.* = @intCast(xs.len - 1 - i);
        },
        .nearly_sorted => {
            for (xs, 0..) |*slot, i| slot.* = @intCast(i);
            if (xs.len > 1) {
                var i: usize = 0;
                while (i + 1 < xs.len) : (i += @max(@as(usize, 1), xs.len / 16)) {
                    std.mem.swap(i32, &xs[i], &xs[@min(i + 1, xs.len - 1)]);
                }
            }
        },
        .duplicate_heavy => {
            for (xs, 0..) |*slot, i| {
                slot.* = switch (i % 6) {
                    0 => 0,
                    1 => 1,
                    2 => -1,
                    3 => 2,
                    4 => -2,
                    else => @as(i32, @intCast(random.uintLessThan(u32, 5))) - 2,
                };
            }
        },
        .clustered => {
            for (xs, 0..) |*slot, i| {
                const cluster = @as(i32, @intCast(i / 8));
                const offset = @as(i32, @intCast(i % 5)) - 2;
                slot.* = cluster * 7 + offset;
            }
        },
        .signed_mixed => {
            for (xs, 0..) |*slot, i| {
                const base = @as(i32, @intCast(random.uintLessThan(u32, 8192)));
                slot.* = if (i % 2 == 0) base else -base;
            }
        },
        .alternating => {
            for (xs, 0..) |*slot, i| {
                if (i % 2 == 0) {
                    slot.* = @intCast(xs.len - 1 - i / 2);
                } else {
                    slot.* = -@as(i32, @intCast(i / 2));
                }
            }
        },
    }
}

fn baselineSort(xs: []i32) void {
    std.sort.pdq(i32, xs, {}, std.sort.asc(i32));
}

fn validateCase(allocator: std.mem.Allocator, input: []const i32, cfg: Config) !Stats {
    const actual = try allocator.alloc(i32, input.len);
    defer allocator.free(actual);
    const expected = try allocator.alloc(i32, input.len);
    defer allocator.free(expected);

    @memcpy(actual, input);
    @memcpy(expected, input);

    baselineSort(expected);

    var stats = Stats{};
    support.sortWithStats(i32, actual, cfg, &stats);

    if (!std.mem.eql(i32, expected, actual)) return error.BenchmarkValidationFailed;
    if (!fluxsort.isSorted(i32, actual)) return error.BenchmarkValidationFailed;
    return stats;
}

fn timeFluxSort(allocator: std.mem.Allocator, input: []const i32, cfg: Config, iterations: usize) !Result {
    const scratch = try allocator.alloc(i32, input.len);
    defer allocator.free(scratch);

    const validation_stats = try validateCase(allocator, input, cfg);

    var timer = try std.time.Timer.start();
    var iter: usize = 0;
    while (iter < iterations) : (iter += 1) {
        @memcpy(scratch, input);
        fluxsort.sort(i32, scratch);
    }
    const total_ns = timer.read();

    return .{
        .algo = "fluxsort",
        .dataset = undefined,
        .size = input.len,
        .iterations = iterations,
        .total_ns = total_ns,
        .avg_ns = @divFloor(total_ns, iterations),
        .avg_ns_per_item = @divFloor(total_ns, iterations * @max(@as(usize, 1), input.len)),
        .transport_accepted = validation_stats.transport_blocks_accepted,
        .transport_rejected = validation_stats.transport_blocks_rejected,
        .grouped_exact_blocks = validation_stats.grouped_exact_blocks,
        .moved_delta_blocks = validation_stats.moved_delta_blocks,
        .full_delta_blocks = validation_stats.full_delta_blocks,
        .cleanup_rounds = validation_stats.cleanup_rounds,
        .cleanup_swaps = validation_stats.cleanup_swaps,
    };
}

fn timeBaseline(allocator: std.mem.Allocator, input: []const i32, iterations: usize) !Result {
    const scratch = try allocator.alloc(i32, input.len);
    defer allocator.free(scratch);
    const expected = try allocator.alloc(i32, input.len);
    defer allocator.free(expected);

    @memcpy(expected, input);
    baselineSort(expected);

    @memcpy(scratch, input);
    baselineSort(scratch);
    if (!std.mem.eql(i32, expected, scratch)) return error.BenchmarkValidationFailed;

    var timer = try std.time.Timer.start();
    var iter: usize = 0;
    while (iter < iterations) : (iter += 1) {
        @memcpy(scratch, input);
        baselineSort(scratch);
    }
    const total_ns = timer.read();

    return .{
        .algo = "std_pdq",
        .dataset = undefined,
        .size = input.len,
        .iterations = iterations,
        .total_ns = total_ns,
        .avg_ns = @divFloor(total_ns, iterations),
        .avg_ns_per_item = @divFloor(total_ns, iterations * @max(@as(usize, 1), input.len)),
        .transport_accepted = 0,
        .transport_rejected = 0,
        .grouped_exact_blocks = 0,
        .moved_delta_blocks = 0,
        .full_delta_blocks = 0,
        .cleanup_rounds = 0,
        .cleanup_swaps = 0,
    };
}

fn chooseIterations(size: usize) usize {
    if (size <= 64) return 4000;
    if (size <= 256) return 1600;
    if (size <= 1024) return 500;
    if (size <= 4096) return 120;
    return 40;
}

fn printResult(writer: anytype, result: Result, dataset: Dataset) !void {
    try writer.print(
        "{s},{s},{d},{d},{d},{d},{d},{d},{d},{d},{d},{d},{d},{d}\n",
        .{
            result.algo,
            datasetName(dataset),
            result.size,
            result.iterations,
            result.total_ns,
            result.avg_ns,
            result.avg_ns_per_item,
            result.transport_accepted,
            result.transport_rejected,
            result.grouped_exact_blocks,
            result.moved_delta_blocks,
            result.full_delta_blocks,
            result.cleanup_rounds,
            result.cleanup_swaps,
        },
    );
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const filters = try parseFilters(allocator);
    defer if (filters.datasets) |value| allocator.free(value);
    defer if (filters.sizes) |value| allocator.free(value);

    const stdout = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout);
    const writer = bw.writer();

    const sizes = [_]usize{ 32, 64, 128, 256, 512, 1024, 2048, 4096 };
    const datasets = [_]Dataset{ .random, .sorted, .reverse, .nearly_sorted, .duplicate_heavy, .clustered, .signed_mixed, .alternating };
    const cfg = fluxsort.DefaultConfig;
    var prng = std.Random.DefaultPrng.init(0xad1cf1);
    const random = prng.random();

    try writer.print("# fluxsort benchmark harness\n", .{});
    try writer.print("# zig_version,{s}\n", .{@import("builtin").zig_version_string});
    try writer.print("# optimize_mode,{s}\n", .{@tagName(@import("builtin").mode)});
    try writer.print("algo,dataset,size,iterations,total_ns,avg_ns,avg_ns_per_item,transport_accepted,transport_rejected,grouped_exact_blocks,moved_delta_blocks,full_delta_blocks,cleanup_rounds,cleanup_swaps\n", .{});

    for (datasets) |dataset| {
        if (!datasetSelected(filters, dataset)) continue;
        for (sizes) |size| {
            if (!sizeSelected(filters, size)) continue;
            const input = try allocator.alloc(i32, size);
            defer allocator.free(input);
            fillDataset(input, dataset, random);

            const iterations = filters.iterations_override orelse chooseIterations(size);

            var adic_result = try timeFluxSort(allocator, input, cfg, iterations);
            adic_result.dataset = dataset;
            try printResult(writer, adic_result, dataset);

            var baseline_result = try timeBaseline(allocator, input, iterations);
            baseline_result.dataset = dataset;
            try printResult(writer, baseline_result, dataset);
        }
    }

    try bw.flush();
}
