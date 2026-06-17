## 0.1.11

### Fixed

* **Subset scanner:** detects icon references inside `IconifyIcon(...)` conditional expressions, such as `isSaved ? SvgAssets.bookmarked : SvgAssets.bookmark`, so both branches are included in generated assets.

## 0.1.10

### Added

* **Subset scanner:** resolves `IconifyIcon(SvgAssets.field)` when icons are defined as `static const String` in your own classes (e.g. `SvgAssets.explore`).
* **`normalizeIconIdString`:** accepts `prefix--name` (double dash) in addition to `prefix:name` and `prefix/name` — used by the scanner and `IconifyIconRef.fromId`.

## 0.1.9

### Fixed

* **Rebuild flicker:** cache [SvgPicture] instances and hydrate [FastCachedIconify] from memory before showing placeholder — icons no longer flash on parent rebuilds.

## 0.1.8

### Fixed

* **Codegen:** sanitize both prefix and icon name in generated `Iconifies.*` constants (hyphens now become underscores, e.g. `fluent_emoji_high_contrast_pouring_liquid`).
* **FastCachedIconify:** reliably refreshes from placeholder to icon after first download (no manual refresh needed).

## 0.1.7

### Added

* **`FastCachedIconify`** — runtime download + disk/memory cache for any `prefix:name` icon (no subset). First load fetches from Iconify GitHub; later loads use cache. Call `FastCachedIconify.ensureInitialized()` in `main`. Supports custom **`placeholder`** (loading) and **`errorWidget`** (invalid id, download failure, or missing icon).

### Changed

* **pub.dev:** Ship `example/` app; declare Android, iOS, Web, Windows, macOS plugin platforms.
* Expanded `dartdoc` on public API ([IconifyFullConfig], CLI helpers, widgets).

### Fixed

* **FastCachedIconify:** UI updates when the first download finishes (no longer stuck on [placeholder] until hot reload).
* Export [IconifyFullPlugin] from main library (fixes Windows/Linux/macOS `dart_plugin_registrant` build).

## 0.1.6

### Fixed

* **Android:** Java-only plugin (no Kotlin) — fixes JVM 17/21 mismatch on APK builds (`compileReleaseKotlin` vs `compileReleaseJavaWithJavac`).

## 0.1.5

### Fixed

* **Android:** Set Kotlin `jvmTarget` to 17 to match Java compile options.

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
