# iconify_full example

Demo app for [iconify_full](../iconify_full).

## Run locally

```bash
cd ../example
flutter pub get
dart run iconify_full:iconify_init     # first time: creates lib/generated/iconify_manifest.g.dart

# Download cache at repo root (once)
cd ../iconify_full
dart run :iconify_download --cache ../.iconify_cache

cd ../example
dart run iconify_full:iconify_subset   # optional; native build also subsets
flutter run
```

## What it shows

- `IconifyIcon` with `mdi`, `tabler`, and `solar` icons
- `IconifyTheme` for default color and size
- Light/dark mode and accent slider

Icons are subsetted to `assets/iconify/`; manifest at `lib/generated/iconify_manifest.g.dart`.
