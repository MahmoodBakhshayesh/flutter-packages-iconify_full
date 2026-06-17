# iconify_full

Use [Iconify](https://icon-sets.iconify.design/) icons in Flutter as **themed SVGs**, with a **local offline cache** of 200+ open icon sets and **automatic subsetting** so release builds only include icons you reference.

> **Icon licenses:** This package is [MIT](LICENSE). Icon artwork has **per-set licenses** — see [LICENSE-ICONS.md](LICENSE-ICONS.md). You are responsible for compliance in your app.

## Features

- **200+ icon sets**, 200k+ icons — same catalogs as [icon-sets.iconify.design](https://icon-sets.iconify.design/)
- **Offline cache** — download once per machine or CI
- **Themed SVG** — `IconifyTheme` + tinting for monochrome sets
- **Debug cache** — iterate on new icons without re-running subset on every `flutter run`
- **Typed icons** — generated `Iconifies.*` (subset) or `Mdi.*` / `Solar.*` (full catalog via `iconify_codegen`)
- **Tree-shaking** — subset copies only icons you reference in `lib/`
- **Auto subset on build** — Android & iOS via plugin; Windows/Linux via CMake; web via `iconify_build`
- **`FastCachedIconify`** — download icons on demand at runtime (like cached network images)

---

## FastCachedIconify (runtime download)

Use when you need **any** Iconify id without bundling or pre-downloading full sets:

```dart
import 'package:iconify_full/iconify_full.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FastCachedIconify.ensureInitialized();
  // optional: cachePath: '/custom/path'
  runApp(const MyApp());
}

// In widgets:
FastCachedIconify(
  'mdi:account-circle',
  size: 28,
  color: Colors.blue,
  placeholder: const SizedBox(
    width: 28,
    height: 28,
    child: CircularProgressIndicator(strokeWidth: 2),
  ),
  errorWidget: const Icon(Icons.broken_image_outlined, size: 28),
)
```

| | `IconifyIcon` | `FastCachedIconify` |
|--|---------------|---------------------|
| **Needs subset / assets** | Yes (release) | No |
| **Network** | No (offline) | First load per icon/set |
| **Best for** | Production, fixed icon set | Dynamic icons, prototypes, admin UIs |

Cache layout (mobile/desktop): app support dir → `iconify_fast_cache/json/` + `svg/`. Web uses in-memory cache for the session.

Requires **internet** on first use per icon set (JSON is cached per prefix).

---

## Step-by-step: new Flutter app

### Step 1 — Add the dependency

In your app `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  iconify_full: ^0.1.8
```

Then:

```bash
flutter pub get
```

### Step 2 — Create the manifest (first time only)

Before `iconify_manifest.g.dart` exists, your app cannot import it. Bootstrap an **empty starter** file:

```bash
cd your_app   # folder with pubspec.yaml
dart run iconify_full:iconify_init
```

This creates:

- `lib/generated/iconify_manifest.g.dart` — empty map, compiles immediately
- `assets/iconify/` — placeholder folder
- `flutter: assets:` entry in `pubspec.yaml` (if missing)

Use `--force` to replace an existing manifest with a fresh starter.

### Step 3 — Register the manifest in `main.dart`

```dart
import 'package:iconify_full/iconify_full.dart';
import 'generated/iconify_manifest.g.dart' as iconify_manifest;

void main() {
  setupIconifyFull(
    manifest: iconify_manifest.iconifyAssetFor,
    // Debug only — skip re-subset while iterating (see below)
    debugCachePath: '.iconify_cache',
  );
  runApp(const MyApp());
}
```

**Debug vs release**

| Mode | What you do when adding a new icon |
|------|-------------------------------------|
| **Debug** (`flutter run`) | Download the set once, point `debugCachePath` at `.iconify_cache`, use `IconifyIcon('prefix:name')` — **no subset needed** while iterating |
| **Release** (`flutter build …`) | Subset runs automatically on Android/iOS/desktop (or run `iconify_subset` / `iconify_build` for web) — only referenced icons ship |

In release builds, `registerIconifyDebugCache` is ignored; icons must be in the generated manifest.

### Step 4 — Download the icon cache (once per machine)

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

### Step 5 — Configure `iconify_full` (optional)

In your app `pubspec.yaml`:

```yaml
iconify_full:
  cache: .iconify_cache          # default
  assets_dir: assets/iconify     # default
  manifest: lib/generated/iconify_manifest.g.dart
  auto_subset: true              # default
```

For a monorepo with cache next to the `iconify_full` package (e.g. brewlab + iconify_full siblings):

```yaml
iconify_full:
  cache: ../iconify_full/.iconify_cache
```

For cache in the app folder:

```yaml
iconify_full:
  cache: .iconify_cache
```

Only `cache` is required when it is not `.iconify_cache` in the app root. Other keys match defaults and can be omitted:

```yaml
iconify_full:
  cache: ../iconify_full/.iconify_cache
```

### Step 6 — Use icons in widgets

```dart
import 'package:iconify_full/iconify_full.dart';
import 'generated/iconify_icons.g.dart'; // after first subset

IconifyTheme(
  data: IconifyThemeData(
    color: Theme.of(context).colorScheme.primary,
    size: 28,
  ),
  child: Row(
    children: [
      IconifyIcon('mdi:home'),
      IconifyIcon.named(Iconifies.mdi_heart), // typed, autocomplete-friendly
      IconifyIcon('tabler:settings', size: 32),
    ],
  ),
)
```

Icon ids use the form **`prefix:name`** (same as Iconify), e.g. `mdi:home`, `solar:star-bold`.

**Two typed options**

| Source | When | Usage |
|--------|------|--------|
| **`iconify_icons.g.dart`** (subset) | Small — only icons you use | `IconifyIcon.named(Iconifies.mdi_home)` |
| **`iconify_catalog/`** (codegen) | Full set(s) from your cache | `IconifyIcon.named(Mdi.home)` |

The first time you add a brand-new icon with subset-only typing, use the string form once, run subset, then switch to `Iconifies.*`.

### Full catalog typing (all icons in cache)

You **cannot** ship ~200k icons inside the `iconify_full` pub package (size, analyzer, pub.dev). Generate them **in your app** after download:

```bash
dart run iconify_full:iconify_download -p mdi -p solar   # or full cache
dart run iconify_full:iconify_codegen -P mdi -P solar    # one Dart file per set
```

This writes `lib/generated/iconify_catalog/mdi.dart`, `solar.dart`, and a barrel `iconify_catalog.dart`:

```dart
import 'generated/iconify_catalog/iconify_catalog.dart';

const IconifyIcon.named(Mdi.home);
const IconifyIcon.named(Solar.star_bold);
```

Add `lib/generated/iconify_catalog/` to **`.gitignore`** if you generate many sets (can be 10MB+ of Dart). Regenerate when you update the cache.

### Step 7 — Subset icons (fills the manifest & assets)

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

1. Scans `lib/**/*.dart` for `IconifyIcon('…')`, `IconifyIcon(SvgAssets.field)`, conditional refs like `isSaved ? SvgAssets.saved : SvgAssets.save`, `Iconifies.*`, and catalog refs (`Mdi.home`, etc.)
2. Copies matching SVGs to `assets/iconify/`
3. Writes `lib/generated/iconify_manifest.g.dart` and `iconify_icons.g.dart`
4. Adds `assets/iconify/` to `pubspec.yaml` if missing

After you add `IconifyIcon('prefix:name')` in `lib/`, subset **replaces** the starter manifest with real entries and copies SVGs into `assets/iconify/`. This also runs automatically on native builds (see table below).

### Step 8 — Desktop hooks (Windows & Linux, one-time per app)

```bash
dart run iconify_full:iconify_apply_hooks --project .
```

This patches CMake so `flutter build windows` / `linux` subsets automatically.

### Step 9 — Web builds

Gradle/CMake hooks do not run for web. Use:

```bash
dart run iconify_full:iconify_build -- build web
# or: dart run iconify_full:iconify_build -- run -d chrome
```

This runs subset, then forwards to `flutter`.

### Step 10 — Run or release

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
| `dart run iconify_full:iconify_init` | **First-time:** create empty `iconify_manifest.g.dart` |
| `dart run iconify_full:iconify_download` | Download all (or `-p prefix`) sets to cache |
| `dart run iconify_full:iconify_codegen` | Generate typed `Mdi` / `Solar` classes from cache |
| `dart run iconify_full:iconify_subset` | Subset used icons into app assets |
| `dart run iconify_full:iconify_apply_hooks` | Patch Windows/Linux CMake (once per app) |
| `dart run iconify_full:iconify_build -- …` | Subset + `flutter …` (good for web) |

**Download flags:** `--cache PATH`, `-p mdi`, `--force` (re-download).

**Subset flags:** `--project PATH`, `--cache PATH`, `--no-pubspec`.

---

## API overview

| Type | Role |
|------|------|
| `FastCachedIconify('mdi:home')` | Widget — download + cache at runtime |
| `IconifyIcon('mdi:home')` | Widget — manifest assets (release) or cache (debug) |
| `IconifyIcon.named(Iconifies.mdi_home)` | Widget with generated typed ref |
| `IconifyTheme` / `IconifyThemeData` | Default color, size, fit |
| `setupIconifyFull(...)` | Manifest + optional `debugCachePath` |
| `Iconifies` / `Mdi` / `Solar` (generated) | Typed `IconifyIconRef` constants |
| `IconifyIconRef` | Manual typed ref (`prefix` + `name`) |

---

## Troubleshooting

**Solar (or other) icons show blank / nothing**

- Often a **stale cache** from before 0.1.4 mask export fix. Re-download the set and subset:
  ```bash
  dart run iconify_full:iconify_download -p solar --force
  dart run iconify_full:iconify_subset
  ```
- Confirm `assets/iconify/solar/your-icon.svg` contains `fill="#fff"` inside `<mask>`, not only `fill="currentColor"`.

**`generated/iconify_manifest.g.dart` does not exist**

- Run `dart run iconify_full:iconify_init` once, then add the import in `main.dart`.

**Red broken-image placeholder**

- Icon not in manifest → run subset after adding `IconifyIcon('prefix:name')`.
- Icon missing from cache → run `iconify_download` for that prefix.

**Subset finds 0 icons**

- Use string form: `IconifyIcon('mdi:home')` in `lib/` (scanned statically).

**Android build: subset failed**

- Ensure `iconify_full` is in `dependencies` (not only `dev_dependencies`).
- Run `dart run iconify_full:iconify_subset` manually to see errors.

**Android: JVM target mismatch (Kotlin 21 vs Java 17)**

- Update to `iconify_full` **0.1.6+** (Android plugin is Java-only; no Kotlin in this package).

**CMake: `iconify_subset` does not exist**

- Old `iconify_apply_hooks` only patched `runner/CMakeLists.txt` with `add_dependencies` but not the target.
- Re-run: `dart run iconify_full:iconify_apply_hooks --project .`
- Or replace the `# >>> iconify_full` block in `windows/runner/CMakeLists.txt` (see package README / example app).

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
