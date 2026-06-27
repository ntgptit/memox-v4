# Error contract — MemoX V4

The closed set of failure types and how each surfaces to the user. Code must map
every error into one of these — no ad-hoc strings.

## Failure taxonomy

| Failure | When | User-facing result | Retryable |
| --- | --- | --- | --- |
| ValidationFailure | bad input at a boundary | inline message | no |
| NotFoundFailure | entity missing | empty/not-found state | no |
| ConflictFailure | concurrent/duplicate | conflict prompt | sometimes |
| PersistenceFailure | storage error | error state + retry | yes |
| NetworkFailure | remote unreachable | offline/error state | yes |
| UnexpectedFailure | unhandled | generic error + log | no |

Tên kiểu: lớp gốc **`Failure`** (sealed); các nhánh trên là subtype. Thêm domain-specific:
`ImportFailure` (parse CSV/Excel sai → ValidationFailure mức dòng), `SyncFailure`
(xung đột/đăng nhập Google → Network/Conflict). Use case trả `Result<T>` (thành công
`Ok<T>`, lỗi `Err` mang một `Failure`) — `Result` ở `lib/domain/types/result.dart`
(xem `docs/contracts/code-style.md`).

## Rules

- Validate at boundaries; never trust input deeper in.
- Map low-level exceptions to a failure type at the layer boundary; don't leak raw exceptions to UI.
- Every failure that reaches the user has copy defined in `docs/ui-ux/l10n-copy-contract.md`.
- Log at the failure's origin per `docs/quality/observability-contract.md`.

## Related

- `docs/contracts/types-catalog.md` — shared enums/value objects
- `docs/ui-ux/l10n-copy-contract.md` — user-facing copy for failures
- `docs/quality/observability-contract.md` — where failures are logged
