pub const config = @import("core/config.zig");
pub const key = @import("core/key.zig");
pub const energy = @import("core/energy.zig");
pub const pressure = @import("core/pressure.zig");
pub const transport = @import("core/transport.zig");
pub const cleanup = @import("core/cleanup.zig");
pub const stats = @import("core/stats.zig");
pub const util = @import("internal/util.zig");

const Config = config.Config;
const Stats = stats.Stats;

pub fn sortWithStats(comptime T: type, xs: []T, cfg: Config, out_stats: *Stats) void {
    util.assertIntegerType(T);
    cfg.validate() catch |err| @panic(@errorName(err));

    if (xs.len <= 1) return;

    var round: usize = 0;
    while (round < cfg.transport_rounds) : (round += 1) {
        var any_accepted = false;
        var start: usize = 0;

        while (start < xs.len) : (start += cfg.block_size) {
            const end = @min(start + cfg.block_size, xs.len);
            const result = transport.tryTransportBlock(T, xs[start..end], cfg, out_stats);
            any_accepted = any_accepted or result.accepted;
        }

        if (!any_accepted) break;
    }

    cleanup.exactCleanup(T, xs, cfg.cleanup_pass_limit, out_stats);
}
