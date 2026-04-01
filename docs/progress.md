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

## Active next-phase checklist

- [ ] Decide whether tagged-identity evidence is strong enough to strengthen or further narrow stability wording
- [x] Add more stats-based convergence tests around transport acceptance and cleanup work
- [x] Expand literature-positioning notes into a review checklist with citations/tasks
- [ ] Open source-backed literature review tasks from the new checklist
- [ ] Decide whether `isSorted` remains part of the long-term public API
- [ ] Freeze a benchmark-readiness checklist version before any benchmark harness is added

## Suggested issue buckets

### Correctness and semantics

- stability proof obligations
- cleanup-limit semantics and diagnostics
- transport local-vs-global invariant documentation

### Testing

- larger exhaustive tagged-identity searches where still tractable
- additional structured duplicate-heavy adversarial fixtures
- convergence/accounting tests using debug counters

### Docs and positioning

- literature review checklist
- source-backed literature review issues
- algorithm-family comparison notes with citations
- API surface notes for unstable test support
