# Stability

## Current status

AdicFlux should currently be described as stability-aware, not stability-proved.

The repository does not claim a complete end-to-end proof that equal integer keys always preserve their original relative order under every accepted transport move.

The test suite now includes tagged-identity checks that simulate stable ordering obligations explicitly rather than relying on plain integer duplicates alone. Those tests have not found a counterexample in the current small exhaustive search and randomized stress coverage, but that remains evidence, not proof.

## What is stability-friendly today

- the key transform treats equal values as equal keys,
- equal keys are never counted as inversions,
- cleanup swaps only strict adjacent inversions,
- target resolution is stable when multiple sources request the same target.

## Where the proof gap remains

Transport pressure is contextual. Two equal values can experience different surrounding neighborhoods, accumulate different pressures, and therefore request different targets.

That means the current target-resolution argument is not enough to prove full stability by itself. It only proves stable tie handling once desired targets have already collided.

## Repository wording standard

Until a stronger argument or stronger testing harness exists, the project should use language like:

- "intended stability property",
- "stability-friendly implementation choices",
- "not yet formally proved end-to-end".

It should avoid claiming simply "the algorithm is stable" as an unconditional theorem.

## What the tests now establish

- plain integer tests continue to verify sortedness and multiset preservation,
- tagged-identity tests compare AdicFlux-style behavior against a stable reference ordering,
- small exhaustive searches over short arrays and randomized duplicate-heavy tests have not exposed an equal-key reorder so far.

That strengthens confidence in the current implementation, but it still falls short of a proof obligation.

## What would justify stronger language later

- a proof that accepted transport moves cannot reverse equal keys,
- or a transport rule refined specifically to preserve equal-key order,
- plus tests capable of observing tagged equal-key identities rather than plain integers alone.
