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
