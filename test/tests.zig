test {
    _ = @import("unit/config_test.zig");
    _ = @import("unit/key_test.zig");
    _ = @import("unit/energy_test.zig");
    _ = @import("unit/pressure_test.zig");
    _ = @import("unit/transport_test.zig");
    _ = @import("unit/cleanup_test.zig");
    _ = @import("unit/stats_test.zig");
    _ = @import("property/random_arrays_test.zig");
    _ = @import("property/adversarial_patterns_test.zig");
    _ = @import("property/duplicates_test.zig");
    _ = @import("property/sorted_reverse_test.zig");
    _ = @import("property/edge_values_test.zig");
}
