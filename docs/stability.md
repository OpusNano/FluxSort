# Stability

## Current status

FluxSort should currently be described as test-supported for stability, not stability-proved.

The repository still does not claim a complete end-to-end proof that equal integer keys always preserve their original relative order under every accepted transport move.

The test suite now includes tagged-identity checks that simulate stable ordering obligations explicitly rather than relying on plain integer duplicates alone. Those tests have not found a counterexample in the current small exhaustive search and randomized stress coverage. That is stronger than a design intention alone, but it is still evidence rather than proof.

After the broader tagged-search expansion currently in the repository, the project still keeps the same wording: the evidence is stronger, but not yet proof-grade.

## What is stability-friendly today

- the key transform treats equal values as equal keys,
- equal keys are never counted as inversions,
- cleanup swaps only strict adjacent inversions,
- target resolution is stable when multiple sources request the same target.

## Where the proof gap remains

Transport pressure is contextual. Two equal values can experience different surrounding neighborhoods, accumulate different pressures, and therefore request different targets.

That means the current target-resolution argument is not enough to prove full stability by itself. It only proves stable tie handling once desired targets have already collided.

## Repository wording standard

Until a stronger argument or significantly broader evidence exists, the project should use language like:

- "test-supported stability behavior",
- "stability-friendly implementation choices",
- "not yet formally proved end-to-end".

It should avoid claiming simply "the algorithm is stable" as an unconditional theorem.

## What the tests now establish

- plain integer tests continue to verify sortedness and multiset preservation,
- tagged-identity tests compare FluxSort-style behavior against a stable reference ordering,
- small exhaustive searches over short arrays and randomized duplicate-heavy tests have not exposed an equal-key reorder so far.

That strengthens confidence in the current implementation and justifies slightly stronger wording than a bare design intention, but it still falls short of a proof obligation.

## What would justify stronger language later

- a proof that accepted transport moves cannot reverse equal keys,
- or a transport rule refined specifically to preserve equal-key order,
- plus tests capable of observing tagged equal-key identities rather than plain integers alone.
