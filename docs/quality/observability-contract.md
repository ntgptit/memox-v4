# Observability contract — MemoX V4

Where and how to log, so logs are useful and never leak. Read before adding a log site.

## Levels

| Level | Use for | Example |
| --- | --- | --- |
| error | a failure the user feels | persistence failure |
| warn | recovered/degraded | retry succeeded |
| info | notable lifecycle events | migration ran |
| debug | dev-only detail | <gated off in release> |

## Rules

- Log a failure once, at its origin (the layer that maps it to a failure type).
- Never log secrets, tokens, or full PII. Redact.
- Messages are actionable: what failed + enough context to locate it.
- No logging in tight loops / hot paths (see `docs/quality/performance-contract.md`).

API log: package `logging` qua wrapper ở `lib/core/util/` (logger.dart); trường có cấu trúc:
`feature`, `op`, `failure`, `ms`. `debug` tắt ở release (`kReleaseMode`).

## Related

- `docs/quality/performance-contract.md` — no logging in hot paths
- `docs/contracts/error-contract.md` — what to log at failure origin
