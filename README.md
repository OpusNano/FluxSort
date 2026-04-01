# AdicFlux

Experimental 2-adic interference transport sort in Zig.

AdicFlux is a correctness-first implementation of an experimental integer sorting proposal called 2-Adic Interference Transport Sort. The current repository focuses on a small, auditable baseline: a 2-adic weighted local transport stage that is only accepted when it decreases a block-local inversion energy, plus an exact odd-even cleanup stage that guarantees completion.

## Status

- Experimental research prototype, not a validated claim of algorithmic novelty.
- Correctness and documentation are the current priorities.
- Benchmarking and performance claims are intentionally deferred.

## What is implemented today

- Order-preserving signed-to-unsigned key transform by sign-bit flip.
- Modular weighted inversion energy with a capped 2-adic closeness bonus using `ctz(x xor y)`.
- Cache-friendly block-local pressure estimation and bounded displacement proposals.
- Stable target resolution inside each block.
- Transport moves that are accepted only when they strictly reduce local energy.
- Exact odd-even cleanup that guarantees eventual sorting.
- Unit tests, deterministic edge cases, randomized reference comparisons, and stats/invariant checks.
- Tagged-identity stability checks that provide test-supported evidence without claiming a formal proof.
- A source-backed literature review log that keeps positioning and novelty language conservative.

## What is not implemented yet

- Formal literature review or external novelty validation.
- Strong complexity results beyond conservative discussion.
- Tuned transport schedules, SIMD work, or benchmark claims.
- Published benchmark suite.

## Correctness story

The transport phase is heuristic and experimental. It may speed progress, but it is not relied on for exactness. Exactness comes from the cleanup phase: with the default configuration, odd-even adjacent inversion cleanup runs to completion and guarantees a sorted result even if every transport proposal is rejected.

Accepted transport moves only establish a local fact: the chosen block-local weighted inversion energy strictly decreases for that block. The repository does not currently claim that this implies global progress beyond the final exact cleanup.

## Stability status

The current implementation should be treated as test-supported for stability, not stability-proved.

- cleanup swaps only strict inversions,
- equal pairs contribute no direct pressure,
- target resolution is stable when multiple elements request the same target.

That is encouraging, but the repository does not yet claim a full end-to-end stability proof for all transport interactions.

## Build

```sh
zig build
```

## Test

```sh
zig build test
```

## Basic usage

```zig
const adicflux = @import("adicflux");

var xs = [_]i64{ 9, -3, 4, 4, 0, -9, 7 };
adicflux.sort(i64, xs[0..]);
```

You can also pass a configuration:

```zig
const cfg = adicflux.Config{
    .block_size = 32,
    .valuation_cap = 8,
    .neighborhood = 8,
    .max_displacement = 4,
    .transport_rounds = 4,
};

adicflux.sortWithConfig(i64, xs[0..], cfg);
```

`cleanup_pass_limit` is also available for diagnostic/testing runs. Leaving it as `null` preserves the exactness guarantee. Supplying a finite limit may stop cleanup early and therefore may leave the array not fully sorted.

For those diagnostic runs, `adicflux.isSorted(T, xs)` remains part of the public API as a small validation helper that checks the library's ordering semantics directly.

## Layout

- `src/adicflux.zig` public API.
- `src/core/` algorithm pieces.
- `test/` unit and property-style validation.
- `docs/` design and correctness notes.

## Additional docs

- `docs/api.md` public API and configuration semantics.
- `docs/literature-review-log.md` active source-backed review tasks for positioning.
- `docs/progress.md` current next-phase checklist and work buckets.
- `docs/stability.md` current stability status and proof gap.
- `docs/positioning.md` conservative positioning relative to nearby sort families.
- `docs/benchmarking-plan.md` conservative benchmark-readiness gates.

## Roadmap

- Improve transport policies and acceptance criteria.
- Add deeper stability analysis and proof notes.
- Introduce profiling and benchmarks only after correctness baselines settle.
- Explore SIMD-friendly block kernels.
- Expand literature review and positioning.

## Benchmark disclaimer

This repository intentionally does not claim AdicFlux is fast, faster than standard algorithms, or competitive in production. Benchmarking is deferred until the implementation, invariants, and methodology are stronger.
