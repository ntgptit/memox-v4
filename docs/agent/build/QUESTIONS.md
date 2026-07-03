# Build-loop questions / blockers

## Open

### V.1 — Golden suite (components + screen states) · BLOCKED (environment)

- **Task**: `V.1` — a pixel golden per shared component + per screen-state, light+dark
  (`test/golden/**`), as the component-layer parity gate.
- **Blocker**: font-dependent pixel goldens are **not cross-platform stable**, and this
  build environment is **Windows** while CI (`.github/workflows/verify.yml`) runs the gate
  (`node tool/verify/run.mjs` → `flutter test`) on **ubuntu-latest**. `flutter test`
  compares committed golden PNGs byte-for-byte; Windows vs. Linux differ in font
  rasterization/hinting and shadow anti-aliasing. Goldens generated here would **pass the
  local gate but red-line CI on `main`**.
- **This is the repo's own documented contract, not a guess**:
  - `test/golden/gallery/component_gallery_test.dart`: *"Pixel goldens for the whole set are
    cross-platform sensitive (text/shadows differ dev↔CI) and are owned by the V.1 golden
    suite, **which runs on the canonical platform**."*
  - `test/golden/token_swatch_golden_test.dart`: *"Font loading … is in place for future
    *text* goldens, which are font-dependent and **should be regenerated on the CI
    platform**."* (The one existing golden is deliberately font-free/byte-stable for exactly
    this reason.)
- **What was skipped / fallback already in place**: no goldens were committed (a Windows
  baseline would break CI). The **structural** component gate already exists and is green —
  `component_gallery_test.dart` asserts every one of the ~25 shared widgets renders in both
  themes with no exception, and each per-screen-state is covered by the provider-state
  widget tests written throughout Phase S. So parity at the render/structure layer is
  guarded; only the **pixel** baselines are missing.
- **What is needed from a human / the canonical env**: generate the golden baselines on the
  **Linux CI platform** — run `flutter test --update-goldens` (for the new
  `test/golden/**` suite) in the ubuntu-latest CI/container, commit the resulting PNGs, and
  keep goldens regenerated there on any intended visual change. Alternatively, add a
  tolerant `goldenFileComparator` (pixel-diff threshold) in `flutter_test_config.dart`
  **validated on Linux**, or gate the pixel-golden suite behind a `@Tags(['golden'])` job
  that only runs on the canonical platform. Any of these needs a Linux run to produce/verify
  the baselines, which this Windows session cannot do.
