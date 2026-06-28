# Release readiness — MemoX V4

What to finish + verify before shipping a build. Automated gates are green via CI
(`.github/workflows/ci.yml` runs `node tool/verify/run.mjs --full`); the rest is
build config + manual device verification of the platform-channel features that
unit tests fake.

## 1. Automated (already enforced)

- [ ] CI green on the branch (`.github/workflows/ci.yml`): doc_guard + analyze +
      format + full test suite.
- [ ] `node tool/verify/run.mjs --full` green locally.

## 2. Build configuration

Current values (confirm/finish per release):

| Item | Current | Action |
| --- | --- | --- |
| App id (Android) | `com.memox.memox_v4` (`android/app/build.gradle.kts`) | confirm final |
| Bundle id (iOS) | `com.memox.memoxV4` (`ios/Runner.xcodeproj/project.pbxproj`) | confirm final |
| Display name | `memox_v4` (Android `android:label`, iOS `CFBundleDisplayName`) | **set the brand display name** (decision) |
| Version | `1.0.0+1` (`pubspec.yaml`) | bump `version:` per release |
| App icon + splash | default Flutter | 🔴 provide brand assets (e.g. `flutter_launcher_icons` + `flutter_native_splash`) |
| Android signing | debug only | 🔴 add a release keystore + `android/key.properties`; never commit secrets |
| iOS signing | none | 🔴 set the signing team + provisioning profile in Xcode |

## 3. 🔴 Human gaps (external config — cannot be done from code)

- **W10 Google Drive sync** (`docs/business/account-sync/account-sync.md` §12):
  GCP project with **Drive API enabled** + an **OAuth client id** in
  `CloudSyncConfig` (or `--dart-define` overriding `cloudSyncConfigProvider`) +
  per-platform OAuth (Android SHA-1 + `android/app/google-services.json`, iOS URL
  scheme + `ios/Runner/Info.plist`, desktop client). Until configured, sync stays
  inert by design.

## 4. Manual device smoke tests

Unit tests fake the platform channels; verify these on a real device per platform.

### Core flows
- [ ] Create language pair → deck (nested) → card with meaning; edit; hide; delete.
- [ ] NewLearn: 5 stages (learn → matching → multiple-choice → recall → typing);
      finishing all 5 schedules the card into box 1.
- [ ] DueReview: grading moves the card up/down the Leitner boxes.
- [ ] Four practice games run and don't affect SRS/activity.
- [ ] Search by term and by meaning; multi-token; status filter; hidden cards show.
- [ ] Statistics + Today dashboard (accuracy, heatmap, streak, longest streak).
- [ ] Theme + personalization apply live; settings persist across restart.

### Platform-channel (the human-gap surfaces)
- [ ] Reminders: set time + weekdays → permission prompt → notification fires;
      disabling cancels it.
- [ ] TTS: the speaker button reads the term in the source language.
- [ ] Import: pick a CSV and an XLSX file (file picker) + paste from clipboard;
      a failed import shows an error, a malformed row is skipped, dups counted.
- [ ] Export: CSV / XLSX / clipboard; file lands in the documents directory.
- [ ] Local backup → restore round-trips all data (including stats).
- [ ] Drive sync (after §3 config): sign in → push → pull on a second device.

### Resilience
- [ ] App is fully usable offline; reminders/TTS degrade gracefully without
      permission/voices.

## Related

- `docs/checklist/implementation-checklist.md` — the per-task completion gate.
- `docs/business/account-sync/account-sync.md` — the sync human gap detail.
- `docs/business/system/overview.md` — feature status table.
