# Algorithm

## 1. Order-preserving key transform

Signed integers are mapped to unsigned keys by flipping the sign bit of their fixed-width representation. This preserves the natural signed ordering while allowing all later logic to operate on unsigned bit patterns.

For unsigned integers, the key is the value itself.

## 2. Weighted inversion energy

For indices `i < j`, an inversion contributes energy when `key(xs[i]) > key(xs[j])`.

The baseline contribution is `1`. FluxSort adds a capped 2-adic closeness bonus:

- compute `key(xs[i]) xor key(xs[j])`,
- take `ctz(...)`,
- cap it by a configuration value.

This produces a family of discrete energies that emphasize inversions between values that are close in the 2-adic sense.

## 3. Local interference pressure

Inside each block, nearby pairs contribute signed pressure:

- inverted pairs push the left element right and the right element left,
- already ordered unequal pairs contribute a weaker reinforcing signal,
- equal pairs contribute nothing.

The current implementation uses a local neighborhood window and converts accumulated pressure into a bounded displacement proposal.

## 4. Local transport

Each element proposes a target position inside its block. Conflicts are resolved stably by sorting source indices by desired target and original order, then assigning final positions monotonically.

That yields a block-local permutation with these properties:

- it preserves all values,
- it preserves source order among equal desired targets,
- it uses fixed-size stack scratch only.

The move is accepted only if the resulting block energy is strictly smaller than before.

That is a local acceptance criterion. In the current repository it should not be read as a proof of global descent for the whole array.

## 5. Exact cleanup stage

After transport rounds finish, FluxSort runs odd-even adjacent cleanup until no swaps remain. This is the exact stage. With the default configuration, it guarantees that the final output is sorted even if every transport proposal is rejected.

The configuration also exposes `cleanup_pass_limit` for diagnostic runs. Using a finite limit intentionally weakens that guarantee because cleanup may stop before the array is sorted.

## 6. Stability note

The implementation has several stability-friendly features:

- equal keys are never treated as inversions,
- cleanup swaps only strict inversions,
- block conflict resolution is stable for equal desired targets.

This is not yet presented as a completed end-to-end proof of stability for every accepted transport move.
