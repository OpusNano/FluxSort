# Testing

The repository uses several layers of validation.

## Unit tests

- key transform and 2-adic closeness,
- weighted inversion energy,
- pressure sign and bounded proposals,
- stable target resolution and permutation validity,
- accepted versus rejected transport behavior,
- exact cleanup behavior.

## Deterministic correctness cases

The tests cover empty slices, singleton slices, sorted data, reverse data, duplicates, all equal values, alternating high/low layouts, signed mixtures, and extreme integer values.

## Randomized and adversarial tests

Random arrays are generated over multiple sizes, including multi-block sizes beyond the initial 256-element baseline. The suite also includes structured adversarial fixtures that stress block boundaries, duplicate/extreme mixtures, and bit-pattern families.

Each randomized case checks:

- sorted output,
- exact match with reference order,
- multiset preservation,
- idempotence of sorting the already sorted result.

## Tagged stability tests

Because plain integer duplicates do not expose equal-key identity directly, the suite also includes a test-only tagged harness. It runs AdicFlux-style transport and cleanup on `(key, tag)` records while comparing the result against a stable reference ordering.

This gives the repository a meaningful way to search for equal-key reorderings without promoting the result to a formal proof.

## Reference oracles

The primary oracle remains a small insertion-sort reference because it is easy to audit. Test-only scratch buffers are allocated dynamically so larger arrays can still be checked exactly.

The purpose of these reference paths is correctness cross-checking, not performance.
