# Testing

The repository uses several layers of validation.

## Unit tests

- key transform and 2-adic closeness,
- weighted inversion energy,
- pressure sign and bounded proposals,
- stable target resolution,
- exact cleanup behavior.

## Deterministic correctness cases

The tests cover empty slices, singleton slices, sorted data, reverse data, duplicates, all equal values, alternating high/low layouts, signed mixtures, and extreme integer values.

## Randomized tests

Random arrays are generated over multiple sizes and compared against a trusted reference path implemented as a simple insertion sort on a copied buffer. This is intentionally plain and easy to audit.

Each randomized case checks:

- sorted output,
- exact match with reference order,
- multiset preservation,
- idempotence of sorting the already sorted result.

## Why a simple reference sort

For the first version, a tiny reference implementation is easier to inspect than a more elaborate dependency. The purpose is correctness cross-checking, not performance.
