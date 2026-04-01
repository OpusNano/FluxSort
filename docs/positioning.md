# Positioning

AdicFlux should currently be described as an experimental sorting proposal built from a specific combination of ingredients:

- an order-preserving signed-to-unsigned key transform,
- a weighted inversion energy using a capped 2-adic closeness term,
- a block-local pressure field,
- energy-checked transport proposals,
- and an exact odd-even cleanup stage.

## What the repository should not claim

- It should not claim to be a proved novel algorithmic family.
- It should not claim superiority over standard-library or classical sorts.
- It should not claim that transport alone is sufficient for exactness.

## Nearby families worth comparing carefully

### Comparison sorts

The exact cleanup phase is an odd-even transposition process. That makes comparison-sort behavior an essential part of the current implementation story, even though the transport phase is not a standard comparison-sort heuristic.

### Radix- and bucket-style methods

AdicFlux does not sort by digit passes, bucket population, or counting frequencies. The 2-adic weighting acts as an interaction term inside a comparison-driven energy model rather than as a radix schedule.

### Local-exchange and cellular styles

The block-local pressure and transport phases are closer in spirit to local interaction or relaxation ideas than to textbook partition/merge pipelines. That similarity should be acknowledged when discussing the design, even if the exact weighting and acceptance rules differ.

## Literature-review tasks before stronger language

- survey local-exchange and transposition-based sorting variants,
- survey integer-sorting work that uses bit structure without being radix sort,
- survey energy-minimization or relaxation-inspired sorting proposals,
- document which components are known ideas versus which combinations appear project-specific.

## Citation-ready review checklist

Use this section as the working structure for literature review issues, notes, and future citations.

### 1. Odd-even and transposition sorting background

Goal: separate what AdicFlux inherits directly from its exact cleanup stage from what is transport-specific.

- [ ] collect standard references for odd-even transposition sort / brick sort
- [ ] note exact guarantees, stability properties, and worst-case complexity for that family
- [ ] record precisely which parts of AdicFlux's exactness story reduce to this prior background

Suggested capture fields per source:

- citation
- family/category
- relevant theorem or claim
- what overlaps with AdicFlux
- what does not overlap with AdicFlux

### 2. Local-exchange and relaxation-style sorting proposals

Goal: identify prior work that uses local interactions, drift fields, cellular updates, or relaxation-like movement.

- [ ] collect sources on local-exchange sorting schemes
- [ ] collect sources on cellular or neighborhood-based sorting processes
- [ ] collect sources on relaxation/energy-minimization sorting proposals if they exist
- [ ] note whether those works use acceptance rules, local potentials, or only fixed schedules

Key comparison questions:

- does the method define an explicit energy or Lyapunov-like quantity?
- are moves accepted only on descent, or always applied?
- is the method exact by itself, or paired with a cleanup/fallback stage?

### 3. Integer sorting that uses bit structure without radix passes

Goal: avoid falsely contrasting AdicFlux only against radix sort when the bit-structure idea may have nearer neighbors.

- [ ] collect integer-sorting methods that inspect bit relations without classic digit passes
- [ ] record whether they remain comparison-based, partially counting-based, or hybrid
- [ ] note whether any use valuation-like or bit-closeness interactions

Key comparison questions:

- is bit structure used for partitioning, weighting, routing, or acceptance?
- does the method require auxiliary buckets or counting arrays?
- does the method remain in-place or near-in-place?

### 4. Stability-specific obligations

Goal: determine whether any nearby method gives reusable proof ideas for equal-key order preservation.

- [ ] collect references on stable local-permutation or stable transposition arguments
- [ ] record whether tie handling is built into the local move rule or delegated to a stable fallback
- [ ] note which proof techniques might transfer to AdicFlux transport

### 5. Novelty-positioning worksheet

For each serious comparison candidate, write a short note with this template:

- citation:
- family:
- closest AdicFlux component:
- strongest similarity:
- strongest difference:
- does it weaken any novelty wording:
- does it suggest clearer, safer wording:

## Working conclusion until review is done

Preferred phrasing remains:

- "experimental algorithm proposal"
- "correctness-first implementation"
- "2-adic weighted transport plus exact cleanup"

Avoid stronger novelty phrasing until the checklist above has been worked through with actual sources.

Until that review is done, "experimental algorithm proposal" is the right framing.
