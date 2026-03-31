# Benchmarking Plan

This repository intentionally does not publish benchmark numbers yet.

Benchmarks should be added only after:

- the algorithm and configuration surface stop changing rapidly,
- correctness tests are broad enough to trust aggressive refactors,
- the benchmark methodology is documented in advance.

When benchmarking is introduced, compare against:

- Zig standard-library integer sorting paths where applicable,
- a simple insertion sort baseline on tiny arrays,
- common comparison sorts for medium and large arrays.

Datasets should include:

- random integers,
- already sorted data,
- reverse sorted data,
- nearly sorted data,
- heavy-duplicate distributions,
- structured bit-pattern families.

Metrics should include:

- wall-clock time,
- throughput,
- allocation behavior,
- branch/cache counters where available,
- sensitivity to block and valuation parameters.

Fairness controls should include:

- identical compiler version and flags,
- warmed caches versus cold starts reported separately,
- repeated trials with dispersion statistics,
- clear hardware and OS reporting.
