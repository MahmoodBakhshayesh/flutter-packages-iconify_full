## 0.1.4

### Added

* **`setupIconifyFull`** — register manifest and optional **`debugCachePath`** in one call.
* **Debug cache** — `registerIconifyDebugCache` loads SVGs from `.iconify_cache` during `flutter run` when an icon is not in the manifest yet (no subset on every new icon in debug).
* **Typed icons (subset)** — `iconify_subset` generates `lib/generated/iconify_icons.g.dart` with `Iconifies.*` constants; use `IconifyIcon.named(Iconifies.mdi_home)`.
* **Full catalog typing** — `dart run iconify_full:iconify_codegen` generates per-set classes (`Mdi.home`, `Solar.star_bold`, …) from your downloaded cache under `lib/generated/iconify_catalog/`.
* **`IconifyIconRef`** and **`IconifyIcon.named`** for compile-time typed icons.
* Scanner recognizes `IconifyIcon('…')`, `Iconifies.*`, `IconifyIcon.named(…)`, and catalog refs like `Mdi.home`.

### Fixed

* **Solar / mask icons invisible** — SVG export no longer replaces `#fff` / `#000` inside `<mask>` with `currentColor`. Re-run `iconify_download` and `iconify_subset` for affected sets (e.g. `solar`).
* Tint applied via `SvgPicture` `colorFilter` instead of wrapping in `ColorFiltered` (better SVG rendering).

### Migration from 0.1.3

1. Bump dependency: `iconify_full: ^0.1.4`
2. Optional: switch `registerIconifyManifest` to `setupIconifyFull(..., debugCachePath: '.iconify_cache')`
3. If you use **Solar** or other mask-based sets, re-download and subset:
   ```bash
   dart run iconify_full:iconify_download -p solar --force
   dart run iconify_full:iconify_subset
   ```

## 0.1.3

* **Fix:** Desktop subset runs before `flutter_assemble` so SVGs are included in `flutter_assets`.
* Subset writes **explicit** asset paths in `pubspec.yaml` (fixes Flutter not bundling `assets/iconify/*` subfolders).
* Fix `iconify_apply_hooks` Dart analyze error (CMake `FLUTTER_MANAGED_DIR` anchor uses raw string).

## 0.1.2

* CMake / `iconify_apply_hooks`: try `../iconify_full/.iconify_cache` (monorepo layout like brewlab).
* Scanner: ignore false positives such as `dart:async` in `prefix:name` pattern.

## 0.1.1

* Added `iconify_init` CLI to create `lib/generated/iconify_manifest.g.dart` for new apps.
* Fixed desktop CMake hooks: runner defines `iconify_subset` target (any app name).
* `iconify_apply_hooks` detects any `project(...)` line and upgrades old runner patches.
* Subset writes an empty manifest when no icons are found (with guidance).

## 0.1.0

* Initial release.
* Offline download of all Iconify open icon sets to `.iconify_cache`.
* Themed SVG rendering via `IconifyIcon` and `IconifyTheme`.
* Build-time subsetting: only referenced icons are bundled.
* Automatic subset on Android/iOS builds (Flutter plugin).
* CLI: `iconify_download`, `iconify_subset`, `iconify_apply_hooks`, `iconify_build`.
* Desktop CMake hooks via `iconify_apply_hooks`.
