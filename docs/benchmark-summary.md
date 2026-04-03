# Benchmark Summary

This repository now includes a small published benchmark snapshot for the stable milestone `7d12617`.

These numbers are presented as evidence about the project's behavior, not as marketing claims.

## Commands Used

Stable representative snapshot:

```sh
./.toolchain/zig-0.14.1/zig build bench -Doptimize=ReleaseFast -- --datasets=duplicate_heavy,random,clustered,sorted --sizes=1024,4096 --iterations=400
```

Internal milestone comparison baseline:

```sh
./.toolchain/zig-0.14.1/zig build bench -Doptimize=ReleaseFast -- --datasets=duplicate_heavy,random --sizes=1024,4096 --iterations=400
```

Pre-milestone comparison was collected from `46f9743` in a temporary worktree using the same command and toolchain.

## Representative Stable Numbers (`7d12617`)

| Dataset | Size | FluxSort | `std.sort.pdq` |
| --- | ---: | ---: | ---: |
| `duplicate_heavy` | 1024 | 360123 ns | 1253 ns |
| `duplicate_heavy` | 4096 | 3481692 ns | 3678 ns |
| `clustered` | 1024 | 48119 ns | 2862 ns |
| `clustered` | 4096 | 189747 ns | 14805 ns |
| `random` | 1024 | 604275 ns | 3608 ns |
| `random` | 4096 | 4352358 ns | 45065 ns |
| `sorted` | 1024 | 680 ns | 336 ns |
| `sorted` | 4096 | 2340 ns | 1199 ns |

## Internal Milestone Comparison

| Dataset | Size | `46f9743` | `7d12617` | Change |
| --- | ---: | ---: | ---: | ---: |
| `duplicate_heavy` | 1024 | 387734 ns | 360123 ns | -7.1% |
| `duplicate_heavy` | 4096 | 3610599 ns | 3481692 ns | -3.6% |
| `random` | 1024 | 586323 ns | 604275 ns | +3.1% |
| `random` | 4096 | 4399906 ns | 4352358 ns | -1.1% |

## Reading These Results

- The grouped duplicate-heavy optimization is real.
- The project never became broadly competitive against `std.sort.pdq`.
- The benchmark suite was most useful as a reality check and experiment filter, not as evidence of production readiness.

## Why The README Shows Only A Small Subset

The README intentionally uses a compact summary because the main point is qualitative:

- one meaningful internal milestone,
- strong testing and documentation,
- no credible claim of broad speed competitiveness.

The local harness remains available for deeper inspection or reproduction.
