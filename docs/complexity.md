# Complexity

This document separates implemented costs from conjecture.

## Per-pass costs in the current implementation

- Block energy evaluation is `O(b^2)` for block size `b`.
- Pressure computation is `O(b * neighborhood)`.
- Stable target resolution is `O(b^2)` in the current insertion-sort-based implementation.
- A transport round over `n` items is therefore conservatively `O(n * b)` to `O(n * b^2 / b)`, which simplifies to `O(n * b)` for the pressure part and `O(n * b)` blocks each doing `O(b^2)` local work, giving `O(n * b)`? More explicitly, with `n / b` blocks and `O(b^2)` work per block, transport is `O(n * b)`.

With the default fixed block size, the transport phase is linear in `n` with a larger constant, but that statement depends on treating the block size as a bounded tuning constant.

## Cleanup complexity

Odd-even cleanup has conservative worst-case `O(n^2)` time and `O(1)` extra memory.

## Best case

- Already sorted input may cause all transport moves to be rejected quickly.
- Cleanup then exits after one even pass and one odd pass.

## Conservative worst case

- Transport provides no useful acceleration.
- Cleanup performs the full exact work.
- Overall worst-case time is therefore conservatively quadratic in `n`.

## What is expected but not established

- Some structured inputs may benefit from transport before cleanup.
- Better transport policies may reduce the amount of cleanup work.

Neither point is currently presented as a theorem or benchmark-backed claim.
