# Overview

FluxSort is an experimental integer sorting project built around a 2-adic interaction idea. The implementation treats each integer as an order-preserving unsigned key, defines a weighted inversion energy, estimates block-local transport pressure, and attempts only energy-decreasing local permutations before falling back to an exact cleanup stage.

Repository goals for this first version:

- provide a small and auditable baseline,
- distinguish implemented behavior from conjecture,
- document exactness carefully,
- keep tests ahead of optimization work.

The code should be read as a correctness-first prototype of a novel proposal, not as a final algorithmic result.
