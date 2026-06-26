# MemoX V4 — agent tooling (`tool/`)

The deterministic backbone that keeps an AI agent on rails. Design principle:
**generated + linted indexes beat letting the agent re-explore or guess.**

The four token sinks these tools remove:

| Repetitive work | Tool |
| --- | --- |
| Re-exploring the repo each session | `doc_guard generate` → `docs/_generated/repo-map.md` |
| Checking whether docs lie about the code | `doc_guard check` |
| Remembering and running N verify commands in order | `verify` (one command, one table) |
| Hand-writing a task prompt for the dev loop | `prompt_gen` |

## verify — the single verification entry

```
node tool/verify/run.mjs --quick   # inner loop, fast, no marker
node tool/verify/run.mjs --full    # end of code task: full chain + tests, writes pass-marker
node tool/verify/run.mjs --docs    # end of docs task, writes pass-marker
node tool/verify/run.mjs --check-marker   # used by .githooks/pre-commit
```

The chain is data: `tool/verify/verify.config.json` (seeded for Flutter / Dart 3). A PASS
writes `tool/verify/.last-pass.json` bound to the tree's content state; the
pre-commit hook rejects commits without a matching marker. Loose runs write no
marker, so they can't be committed.

## doc_guard — docs/process linter + index generator

```
node tool/doc_guard/run.mjs check        # path-ref existence + path convention + WBS hygiene
node tool/doc_guard/run.mjs generate     # (re)write docs/_generated/repo-map.md
node tool/doc_guard/run.mjs terms <old>  # find leftover refs after a rename
```

## prompt_gen — task prompt composer

```
node tool/prompt_gen/run.mjs "<task title>" [WBS-ID] [--type screen|usecase|repo|schema|route]
```

Prints a ready-to-paste task envelope (required reading + acceptance slot + workflow
+ verify + report). Fill the blanks, hand to Claude Code.

## Chuẩn tài liệu nghiệp vụ (BA)

Đặc tả nghiệp vụ trong `docs/business/**` viết theo chuẩn BA: mỗi tính năng dùng 11 mục
của `docs/business/_feature-template.md` — thông tin tài liệu · mục đích & bối cảnh ·
phạm vi · tác nhân & bên liên quan · user stories · use case flows (tiền điều kiện /
luồng chính / thay thế-ngoại lệ / hậu điều kiện) · business rules **kèm lý do** ·
acceptance criteria (Given/When/Then) · NFR · RAID · truy vết.

Quy tắc nghiệp vụ (BR) và tiêu chí chấp nhận (AC) đều truy vết về dòng quyết định `D-xxx`
trong `docs/decision-tables/core-decision-table.md` và về gói `W-x` trong
`docs/project-management/wbs.md`. `doc_guard` kiểm tra tham chiếu/đường dẫn; `prompt_gen`
trỏ agent vào đúng reading-list này.

Tài liệu khung sản phẩm: `docs/business/index.md` (tóm tắt yêu cầu, BRD-lite) và
`docs/business/system/overview.md` (bối cảnh nghiệp vụ).
