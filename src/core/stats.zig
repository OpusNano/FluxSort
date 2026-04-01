pub const Stats = struct {
    transport_blocks_visited: usize = 0,
    transport_blocks_accepted: usize = 0,
    transport_blocks_rejected: usize = 0,
    cleanup_rounds: usize = 0,
    cleanup_even_passes: usize = 0,
    cleanup_odd_passes: usize = 0,
    cleanup_swaps: usize = 0,
};
