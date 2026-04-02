const std = @import("std");
const Config = @import("config.zig").Config;
const energy = @import("energy.zig");
const key = @import("key.zig");

pub fn compute(comptime T: type, block: []const T, cfg: Config, pressures: []i32) void {
    std.debug.assert(pressures.len >= block.len);

    @memset(pressures[0..block.len], 0);
    if (block.len <= 1) return;

    for (block, 0..) |left, i| {
        const end = @min(block.len, i + cfg.neighborhood + 1);
        var j = i + 1;
        while (j < end) : (j += 1) {
            const right = block[j];
            switch (key.compare(T, left, right)) {
                .gt => {
                    const w: i32 = @intCast(energy.pairWeight(T, left, right, cfg));
                    pressures[i] += w;
                    pressures[j] -= w;
                },
                .lt => {
                    pressures[i] -= 1;
                    pressures[j] += 1;
                },
                .eq => {},
            }
        }
    }
}

pub fn computeFromKeys(comptime T: type, keys: []const key.KeyType(T), cfg: Config, pressures: []i32) void {
    std.debug.assert(pressures.len >= keys.len);

    @memset(pressures[0..keys.len], 0);
    if (keys.len <= 1) return;

    for (keys, 0..) |left_key, i| {
        const end = @min(keys.len, i + cfg.neighborhood + 1);
        var j = i + 1;
        while (j < end) : (j += 1) {
            const right_key = keys[j];
            if (left_key > right_key) {
                const w: i32 = @intCast(energy.pairWeightFromKeys(T, left_key, right_key, cfg));
                pressures[i] += w;
                pressures[j] -= w;
            } else if (left_key < right_key) {
                pressures[i] -= 1;
                pressures[j] += 1;
            }
        }
    }
}

pub fn computeFromGroupIdsWithEnergy(
    group_ids: []const u8,
    distinct_count: usize,
    neighborhood: usize,
    weight_matrix: []const u16,
    pressures: []i32,
) u64 {
    std.debug.assert(pressures.len >= group_ids.len);

    @memset(pressures[0..group_ids.len], 0);
    if (group_ids.len <= 1) return 0;

    var total_energy: u64 = 0;
    var active_counts: [Config.max_block_size]usize = [_]usize{0} ** Config.max_block_size;
    var seen_counts: [Config.max_block_size]usize = [_]usize{0} ** Config.max_block_size;
    var lazy_group_delta: [Config.max_block_size]i32 = [_]i32{0} ** Config.max_block_size;
    var entry_group_delta: [Config.max_block_size]i32 = [_]i32{0} ** Config.max_block_size;

    for (group_ids, 0..) |group, j| {
        if (j > neighborhood) {
            const expired = j - neighborhood - 1;
            const expired_group = group_ids[expired];
            pressures[expired] += lazy_group_delta[expired_group] - entry_group_delta[expired];
            active_counts[expired_group] -= 1;
        }

        var pressure_value: i32 = 0;
        var left_group: usize = 0;
        while (left_group < distinct_count) : (left_group += 1) {
            const seen_left_count = seen_counts[left_group];
            if (left_group > group and seen_left_count != 0) {
                total_energy += @as(u64, seen_left_count) * weight_matrix[left_group * distinct_count + group];
            }

            const left_count = active_counts[left_group];
            if (left_count == 0 or left_group == group) continue;

            if (left_group < group) {
                pressure_value += @intCast(left_count);
                lazy_group_delta[left_group] -= 1;
            } else {
                const weight: i32 = weight_matrix[left_group * distinct_count + group];
                pressure_value -= @intCast(@as(usize, @intCast(weight)) * left_count);
                lazy_group_delta[left_group] += weight;
            }
        }

        pressures[j] += pressure_value;
        entry_group_delta[j] = lazy_group_delta[group];
        active_counts[group] += 1;
        seen_counts[group] += 1;
    }

    const tail_start = if (group_ids.len > neighborhood) group_ids.len - neighborhood - 1 else 0;
    for (tail_start..group_ids.len) |idx| {
        const group = group_ids[idx];
        pressures[idx] += lazy_group_delta[group] - entry_group_delta[idx];
    }

    return total_energy;
}

pub fn computeFromKeysWithEnergy(comptime T: type, keys: []const key.KeyType(T), cfg: Config, pressures: []i32) u64 {
    std.debug.assert(pressures.len >= keys.len);

    @memset(pressures[0..keys.len], 0);
    if (keys.len <= 1) return 0;

    var total_energy: u64 = 0;
    for (keys, 0..) |left_key, i| {
        const pressure_end = @min(keys.len, i + cfg.neighborhood + 1);
        var j = i + 1;
        while (j < keys.len) : (j += 1) {
            const right_key = keys[j];
            const in_pressure_window = j < pressure_end;

            if (left_key > right_key) {
                const weight = energy.pairWeightFromKeys(T, left_key, right_key, cfg);
                total_energy += weight;
                if (in_pressure_window) {
                    const w: i32 = @intCast(weight);
                    pressures[i] += w;
                    pressures[j] -= w;
                }
            } else if (left_key < right_key and in_pressure_window) {
                pressures[i] -= 1;
                pressures[j] += 1;
            }
        }
    }

    return total_energy;
}

pub fn proposalsFromPressure(pressures: []const i32, cfg: Config, proposals: []i8) void {
    std.debug.assert(proposals.len >= pressures.len);

    const divisor: i32 = @intCast(@max(@as(usize, 1), cfg.neighborhood));
    const max_disp: i32 = @intCast(cfg.max_displacement);

    for (pressures, 0..) |pressure_value, i| {
        var displacement = @divTrunc(pressure_value, divisor);
        displacement = std.math.clamp(displacement, -max_disp, max_disp);
        proposals[i] = @intCast(displacement);
    }
}
