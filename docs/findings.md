# Findings

FluxSort ended up as a useful algorithm experiment, not a competitive production sorter.

## Stable Milestone

The best stable implementation is `7d12617` (`compress grouped-window pressure computation`).

That revision landed the only clearly durable optimization win found during the project:

- exact grouped-window pressure for duplicate-heavy low-cardinality blocks
- fused grouped pressure + grouped baseline energy computation
- measurable duplicate-heavy improvement without changing the overall algorithm story

## What Worked

- Exact local pressure and exact energy acceptance behaved reliably under heavy property testing.
- Grouped duplicate-heavy structure was the strongest optimization signal.
- Benchmark tooling became good enough to reject interesting-but-unhelpful ideas quickly.

## What Was Tried And Rejected

- residue-tree / residue-compressed engines
- grouped-pressure compression variants beyond the landed one
- cohort / segment transport engines
- frontier / narrow-breakpoint engines
- artifact-separated frontier experiments
- generic signature-bucket pressure aggregation
- persistent exact block-field reuse
- strongest-cut flux transport
- distributed flux transport
- event-driven active-block scheduling on fixed blocks
- overlapping-window graph scheduling
- grouped-first low-cardinality specialist path
- sparse-edit exact repair pivot

These were rejected for one or more of the following reasons:

- broad regression outside the target case
- same-binary/codegen sensitivity
- wins came mainly from shifting work to cleanup
- setup cost outweighed savings at current block sizes
- still lost badly to straightforward baselines even in the intended niche

## Bottom Line

- FluxSort has a real internal optimization milestone.
- It does not have a convincing benchmark niche against standard baselines.
- The repository is most valuable as a compact, honest record of an unusual sorting design and the experiments run against it.
