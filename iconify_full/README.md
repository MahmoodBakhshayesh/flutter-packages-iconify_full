# iconify_full

Use [Iconify](https://icon-sets.iconify.design/) icons in Flutter as **themed SVGs**, with a **local offline cache** of 200+ open icon sets and **automatic subsetting** so release builds only include icons you reference.

> **Icon licenses:** This package is [MIT](LICENSE). Icon artwork has **per-set licenses** — see [LICENSE-ICONS.md](LICENSE-ICONS.md). You are responsible for compliance in your app.

## Features

- **200+ icon sets**, 200k+ icons — same catalogs as [icon-sets.iconify.design](https://icon-sets.iconify.design/)
- **Offline cache** — download once per machine or CI
- **Themed SVG** — `IconifyTheme` + `ColorFilter` tinting for monochrome sets
- **Tree-shaking** — subset copies only `IconifyIcon('prefix:name')` used in `lib/`
- **Auto subset on build** — Android & iOS via plugin; Windows/Linux via CMake; web via `iconify_build`

---

## Step-by-step: new Flutter app

### Step 1 — Add the dependency

In your app `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  iconify_full: ^0.1.0
```

Then:

```bash
flutter pub get
```

### Step 2 — Download the icon cache (once per machine)

From your **app project root** (where your app `pubspec.yaml` lives), or from a monorepo root:

```bash
# Default cache folder: .iconify_cache next to the app
dart run iconify_full:iconify_download

# Or choose a path (e.g. shared repo cache)
dart run iconify_full:iconify_download --cache /path/to/.iconify_cache

# Only specific sets (faster)
dart run iconify_full:iconify_download -p mdi -p tabler -p solar
```

This downloads JSON from [iconify/icon-sets](https://github.com/iconify/icon-sets) and writes SVGs into the cache. **Full download is large (~500MB+)** and can take 20–60 minutes.

Add `.iconify_cache/` to `.gitignore` (recommended). Cache CI separately — see [CI/CD](#cicd) below.

### Step 3 — Configure `iconify_full` (optional)

In your app `pubspec.yaml`:

```yaml
iconify_full:
  cache: .iconify_cache          # default
  assets_dir: assets/iconify     # default
  manifest: lib/generated/iconify_manifest.g.dart
  auto_subset: true              # default
```

For a monorepo with cache at repo root:

```yaml
iconify_full:
  cache: ../.iconify_cache
```

### Step 4 — Register the generated manifest

In `lib/main.dart` (before `runApp`):

```dart
import 'package:iconify_full/iconify_full.dart';
import 'generated/iconify_manifest.g.dart' as iconify_manifest;

void main() {
  registerIconifyManifest(iconify_manifest.iconifyAssetFor);
  runApp(const MyApp());
}
```

The manifest file is **generated** by subsetting (Step 6). Commit it after the first successful subset, or regenerate on each build.

### Step 5 — Use icons in widgets

```dart
import 'package:iconify_full/iconify_full.dart';

IconifyTheme(
  data: IconifyThemeData(
    color: Theme.of(context).colorScheme.primary,
    size: 28,
  ),
  child: Row(
    children: [
      IconifyIcon('mdi:home'),
      IconifyIcon('mdi:heart', color: Colors.red),
      IconifyIcon('tabler:settings', size: 32),
    ],
  ),
)
```

Icon ids use the form **`prefix:name`** (same as Iconify), e.g. `mdi:home`, `solar:star-bold`.

### Step 6 — Subset icons (first time & when adding icons)

**Automatic (recommended):**

| Platform | What happens |
|----------|----------------|
| **Android** | `iconify_subset` runs before `preBuild` (plugin) |
| **iOS** | Run Script phase before compile (plugin) |
| **Windows / Linux** | Run Step 7 once, then subset runs via CMake on build |
| **Web** | Use `iconify_build` — see below |

**Manual** (any platform):

```bash
dart run iconify_full:iconify_subset
```

This:

1. Scans `lib/**/*.dart` for `IconifyIcon('…')` references
2. Copies matching SVGs to `assets/iconify/`
3. Writes `lib/generated/iconify_manifest.g.dart`
4. Adds `assets/iconify/` to `pubspec.yaml` if missing

### Step 7 — Desktop hooks (Windows & Linux, one-time per app)

```bash
dart run iconify_full:iconify_apply_hooks --project .
```

This patches CMake so `flutter build windows` / `linux` subsets automatically.

### Step 8 — Web builds

Gradle/CMake hooks do not run for web. Use:

```bash
dart run iconify_full:iconify_build -- build web
# or: dart run iconify_full:iconify_build -- run -d chrome
```

This runs subset, then forwards to `flutter`.

### Step 9 — Run or release

```bash
flutter run
flutter build apk
flutter build appbundle
flutter build ios
flutter build windows
```

Only icons referenced in code are in the final asset bundle.

---

## CI/CD

Example GitHub Actions pattern:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - name: Restore icon cache
        uses: actions/cache@v4
        with:
          path: .iconify_cache
          key: iconify-cache-${{ hashFiles('pubspec.lock') }}
      - name: Download icons if cache miss
        run: dart run iconify_full:iconify_download
      - name: Build
        run: flutter build apk
```

Subset runs during the native build (Android/iOS) or run `dart run iconify_full:iconify_subset` before `flutter build web`.

---

## CLI reference

| Command | Purpose |
|---------|---------|
| `dart run iconify_full:iconify_download` | Download all (or `-p prefix`) sets to cache |
| `dart run iconify_full:iconify_subset` | Subset used icons into app assets |
| `dart run iconify_full:iconify_apply_hooks` | Patch Windows/Linux CMake (once per app) |
| `dart run iconify_full:iconify_build -- …` | Subset + `flutter …` (good for web) |

**Download flags:** `--cache PATH`, `-p mdi`, `--force` (re-download).

**Subset flags:** `--project PATH`, `--cache PATH`, `--no-pubspec`.

---

## API overview

| Type | Role |
|------|------|
| `IconifyIcon('mdi:home')` | Widget — loads SVG from manifest |
| `IconifyTheme` / `IconifyThemeData` | Default color, size, fit |
| `registerIconifyManifest(...)` | Connect generated `iconifyAssetFor` |
| `IconifyIconRef('mdi', 'home')` | Typed reference (optional) |

---

## Troubleshooting

**Red broken-image placeholder**

- Icon not in manifest → run subset after adding `IconifyIcon('prefix:name')`.
- Icon missing from cache → run `iconify_download` for that prefix.

**Subset finds 0 icons**

- Use string form: `IconifyIcon('mdi:home')` in `lib/` (scanned statically).

**Android build: subset failed**

- Ensure `iconify_full` is in `dependencies` (not only `dev_dependencies`).
- Run `dart run iconify_full:iconify_subset` manually to see errors.

**Cache not found**

- Set `iconify_full.cache` in pubspec or pass `--cache` to subset/download.

---

## Licensing

| Component | License |
|-----------|---------|
| `iconify_full` (this package) | [MIT](LICENSE) |
| Icon artwork | **Per icon set** — [LICENSE-ICONS.md](LICENSE-ICONS.md) |

---

## Links

- [Iconify icon sets](https://icon-sets.iconify.design/)
- [Example app](https://github.com/iconify-full/iconify_full/tree/main/example) (monorepo)
- [Changelog](CHANGELOG.md)

---

## Publishing note (maintainers)

Update `homepage`, `repository`, and `issue_tracker` in `pubspec.yaml` to your real GitHub URLs before `dart pub publish`.
