# Code style — MemoX V4

Naming and structure rules the reviewer enforces. Keep this short and absolute.

## Naming

- Semantic names; one responsibility per class/file.
- File: `snake_case.dart` (vd `create_flashcard.dart`, `flashcard_repository_impl.dart`).
- Kiểu/lớp/enum: `UpperCamelCase`; thành viên/biến/hằng: `lowerCamelCase`.
- Use case: 1 lớp / 1 file, hậu tố `UseCase` (vd `CreateFlashcardUseCase`).
- Repository: interface `XxxRepository`, impl `XxxRepositoryImpl`; DAO `XxxDao`.
- Provider (Riverpod annotation): khai báo `@riverpod`, dùng `xxxProvider` sinh ra.
- Màn hình `XxxScreen`; route đặt trong `RoutePaths` (không hardcode chuỗi).
- Test: `*_test.dart`; tên test **trích mã quyết định** (vd `'D-004: sai → lùi 1 ô'`).

## Structure

- Early return; no unnecessary `else`; fail fast.
- No magic values — named constants/tokens only.
- No business logic in controllers/UI.
- Functions do one thing; extract when a block needs a comment to explain "what".

## Errors & results

- Return/propagate failures via the taxonomy in `docs/contracts/error-contract.md`.
- Use case & repository trả `Future<Result<T, Failure>>` — `Result` là **sealed** Dart 3
  (`Ok<T>` / `Err<Failure>`). Data layer bắt exception thô và **ánh xạ thành `Failure`**
  ở ranh giới repository; KHÔNG ném exception thô lên presentation.

## Imports

- Respect the layering in `docs/architecture/overview.md`. No reverse imports.

## Comments

- Comment "why", not "what". Match the density of surrounding code.

## Related

- `docs/contracts/error-contract.md` — result/error idiom
- `docs/contracts/types-catalog.md` — shared types
- `docs/architecture/overview.md` — layer boundaries
