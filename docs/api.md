# API

## Public entry points

### `sort`

```zig
pub fn sort(comptime T: type, xs: []T) void
```

Sorts an integer slice in place using the default FluxSort configuration.

### `sortWithConfig`

```zig
pub fn sortWithConfig(comptime T: type, xs: []T, cfg: Config) void
```

Sorts an integer slice in place using a caller-provided configuration.

Invalid configurations panic with the validation error name. This keeps the public API small while still enforcing release-mode safety constraints.

### `isSorted`

```zig
pub fn isSorted(comptime T: type, xs: []const T) bool
```

Checks whether a slice is nondecreasing under FluxSort's key ordering.

`isSorted` is an intentional part of the public API. It exists as a small validation helper for examples, tests, and user code that experiments with non-default configurations such as `cleanup_pass_limit`, where a caller may intentionally request a diagnostic run that does not complete the exact cleanup stage.

The function is not performance-critical and is not required for ordinary sorting, but it is stable enough to document and support as a public semantic helper.

## `Config`

### `block_size`

Size of each transport block. Must be between `1` and `Config.max_block_size` inclusive.

### `valuation_cap`

Maximum extra weight contributed by the 2-adic closeness term `ctz(x xor y)`.

### `neighborhood`

How many forward neighbors each element inspects when accumulating local pressure.

### `max_displacement`

Maximum absolute movement proposed from one transport step. Must fit in the current `i8` proposal representation.

### `transport_rounds`

Maximum number of full block-transport rounds attempted before exact cleanup.

### `cleanup_pass_limit`

Optional diagnostic/testing limit for odd-even cleanup rounds.

- `null` means cleanup runs to completion and preserves the exactness guarantee.
- a finite value may stop cleanup early and therefore may leave the output not fully sorted.

## Non-stable internal support

Internal modules used by the test suite are exposed under `fluxsort.unstable_test_support`.

That namespace exists for repository development and tests. It is intentionally non-stable and may change without notice.
