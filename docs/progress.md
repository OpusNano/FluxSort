# Progress Tracking

This document tracks the next correctness-first phase as repository-visible work items.

## Completed

- [x] Public repository bootstrap and CI baseline
- [x] Core AdicFlux baseline with exact cleanup guarantee
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

## Active next-phase checklist

- [x] Decide whether tagged-identity evidence is strong enough to strengthen or further narrow stability wording
- [x] Add more stats-based convergence tests around transport acceptance and cleanup work
- [x] Expand literature-positioning notes into a review checklist with citations/tasks
- [x] Open source-backed literature review tasks from the new checklist
- [x] Decide whether `isSorted` remains part of the long-term public API
- [x] Freeze a benchmark-readiness checklist version before any benchmark harness is added

## Current open items

- [ ] Decide whether to cite a dedicated stable-sorting or local-permutation proof source beyond Knuth's general background
- [ ] Continue expanding source-backed notes for Task 2 and Task 3 if they materially affect wording

## Suggested issue buckets

### Correctness and semantics

- stability proof obligations
- cleanup-limit semantics and diagnostics
- transport local-vs-global invariant documentation

### Testing

- larger exhaustive tagged-identity searches where still tractable
- additional structured duplicate-heavy adversarial fixtures
- convergence/accounting tests using debug counters
- continued cross-config differential coverage as implementation changes land

### Benchmarking and tuning

- extend baseline set beyond the first stdlib comparison
- keep benchmark datasets aligned with correctness stress patterns
- use benchmark observations to justify small, auditable optimization passes
- continue reducing transport acceptance cost without weakening exactness
- improve duplicate-heavy paths without regressing transport-first semantics

### Docs and positioning

- literature review checklist
- source-backed literature review issues
- literature review log with actual citations
- algorithm-family comparison notes with citations
- API surface notes for unstable test support
