# Correctness

## What is proved by the implementation structure

The repository relies on two monotone mechanisms.

1. Accepted transport moves strictly decrease the chosen block-local energy.
2. The cleanup stage repeatedly removes adjacent inversions and terminates only when none remain.

The first statement is enforced directly: the code computes energy before and after a proposed block permutation and accepts the permutation only when the new energy is strictly smaller.

The second statement is classical. Odd-even transposition cleanup swaps an adjacent pair only when it is out of order. Every swap decreases the ordinary inversion count of the full array, which is a nonnegative integer. Therefore repeated cleanup cannot continue forever and terminates in a sorted state.

## What is not claimed

- No proof that the transport phase improves asymptotic complexity.
- No proof that the weighted energy is globally minimized before cleanup.
- No formal proof yet that the whole implementation is stable for every future transport refinement.

## Proof sketch for exactness

Let `I(xs)` be the ordinary inversion count of the full slice under the order-preserving key transform.

- `I(xs) >= 0` for every slice.
- During cleanup, each adjacent swap occurs only for a strict inversion.
- Swapping a strict adjacent inversion decreases `I(xs)` by exactly `1`.
- Therefore cleanup terminates after finitely many swaps.
- A slice with no adjacent inversions is sorted.

So the final array after cleanup is sorted.

Transport affects only how much progress may occur before cleanup. It is not required for correctness.
