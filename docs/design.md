# Design

## Why correctness first

AdicFlux starts from an unusual mathematical idea. That makes honesty and auditability more important than squeezing out early speed. The implementation deliberately keeps the control flow small:

- no heap allocation in the transport hot path,
- fixed-size stack scratch per block,
- simple acceptance criterion,
- exact fallback separated from heuristic work.

## Why block-local transport

Block-local work is a natural place to experiment with pair interactions while keeping memory access contiguous and later SIMD work plausible. The current code uses blocks not because the approach is already tuned, but because locality is a reasonable structural assumption for future optimization.

## Why no benchmarks yet

Before benchmarking, the repository needs:

- stable APIs and invariants,
- documented fairness controls,
- meaningful competitors,
- confidence that the transport phase is worth tuning.

Premature benchmarks would encourage overclaiming.

## First-implementation tradeoffs

- Stable target resolution is simple rather than asymptotically optimal.
- Cleanup is exact and easy to reason about, but not fast in the worst case.
- The energy uses a configurable capped valuation bonus so alternative weighting rules remain easy to test.
