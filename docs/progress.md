# Progress Tracking

This document now serves as a compact archive of the best stable milestone and the research trail that followed it.

## Completed

- [x] Public repository bootstrap and CI baseline
- [x] Core FluxSort baseline with exact cleanup guarantee
- [x] Reference-backed randomized correctness tests
- [x] Public-config semantics hardening
- [x] Large-array and adversarial test expansion
- [x] Stability wording hardening
- [x] Debug counters for transport and cleanup
- [x] Tagged-identity stability harness
- [x] Stats-based accounting tests for cleanup limits and multi-block work
- [x] `isSorted` public API decision documented
- [x] Benchmark-readiness checklist v1 frozen
- [x] Source-backed literature review task log activated
- [x] Stability wording updated to reflect tagged-evidence status
- [x] Broader tagged-identity stability search coverage added
- [x] Initial citations expanded beyond the odd-even / local-exchange baseline
- [x] Source-level `isSorted` doc comment added
- [x] Config-matrix differential and invariant test layer added
- [x] Local benchmark harness and first measured optimization pass added
- [x] Exact acceptance-cost optimization using permutation delta energy added
- [x] Duplicate-aware grouped exact evaluator path added
- [x] Benchmark filtering and evaluator-path counters added for tuning loops
- [x] One-pass grouped-state construction for low-cardinality blocks added
- [x] Grouped-window pressure compression landed as stable milestone `7d12617`
- [x] Repository finalized as an honest research artifact rather than a benchmark-claim project

## Stable conclusion

- Best stable code milestone: `7d12617`
- Strongest confirmed optimization line: grouped duplicate-heavy pressure compression
- Broad generic-path optimization attempts were mostly rejected after measurement
- No tested production niche beat straightforward baselines convincingly enough to justify stronger positioning

## Research trail kept off-mainline

- residue-tree experiments
- frontier / narrow-breakpoint experiments
- cohort and segment transport ideas
- signature-bucket pressure compression
- persistent-field reuse
- flux transport variants
- scheduler / overlap-graph execution models
- specialist low-cardinality pivot
- sparse-edit repair pivot

## Remaining value

- compact exact implementation of a 2-adic local-transport sorter
- extensive correctness/property tests
- benchmark harness and negative-results record
- useful reference point for future experimental sorting work in Zig
