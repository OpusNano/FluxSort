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
- Unit tests, deterministic edge cases, and randomized reference comparisons.

## What is not implemented yet

- Formal literature review or external novelty validation.
- Strong complexity results beyond conservative discussion.
- Tuned transport schedules, SIMD work, or benchmark claims.
- Published benchmark suite.

## Correctness story

The transport phase is heuristic and experimental. It may speed progress, but it is not relied on for exactness. Exactness comes from the cleanup phase: an odd-even adjacent inversion cleanup that repeatedly removes local inversions until the slice is sorted. Equal values are never swapped by cleanup, and block target resolution is stable, so the current implementation is intended to be stable for equal keys.

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

## Layout

- `src/adicflux.zig` public API.
- `src/core/` algorithm pieces.
- `test/` unit and property-style validation.
- `docs/` design and correctness notes.

## Roadmap

- Improve transport policies and acceptance criteria.
- Add deeper stability analysis and proof notes.
- Introduce profiling and benchmarks only after correctness baselines settle.
- Explore SIMD-friendly block kernels.
- Expand literature review and positioning.

## Benchmark disclaimer

This repository intentionally does not claim AdicFlux is fast, faster than standard algorithms, or competitive in production. Benchmarking is deferred until the implementation, invariants, and methodology are stronger.
