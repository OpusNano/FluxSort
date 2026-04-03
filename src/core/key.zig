const std = @import("std");
const Config = @import("config.zig").Config;
const types = @import("types.zig");

pub const KeyType = types.UnsignedOf;

pub fn biasedKey(comptime T: type, value: T) types.UnsignedOf(T) {
    const info = @typeInfo(T);
    const U = types.UnsignedOf(T);

    return switch (info) {
        .int => |int_info| switch (int_info.signedness) {
            .unsigned => @as(U, @intCast(value)),
            .signed => blk: {
                const raw: U = @bitCast(value);
                const sign_mask: U = @as(U, 1) << (@bitSizeOf(T) - 1);
                break :blk raw ^ sign_mask;
            },
        },
        else => @compileError("FluxSort only supports integer element types"),
    };
}

pub fn closenessBonus(comptime T: type, left: T, right: T, cfg: Config) u8 {
    return closenessBonusFromKeys(T, biasedKey(T, left), biasedKey(T, right), cfg);
}

pub fn closenessBonusFromKeys(comptime T: type, left_key: types.UnsignedOf(T), right_key: types.UnsignedOf(T), cfg: Config) u8 {
    const U = types.UnsignedOf(T);
    const diff: U = left_key ^ right_key;
    if (diff == 0) return cfg.valuation_cap;

    const tz: usize = @ctz(diff);
    return @intCast(@min(tz, cfg.valuation_cap));
}

pub fn compare(comptime T: type, left: T, right: T) std.math.Order {
    if (left < right) return .lt;
    if (left > right) return .gt;
    return .eq;
}

pub fn greaterThan(comptime T: type, left: T, right: T) bool {
    return left > right;
}

pub fn greaterThanKeys(comptime T: type, left_key: types.UnsignedOf(T), right_key: types.UnsignedOf(T)) bool {
    return left_key > right_key;
}
