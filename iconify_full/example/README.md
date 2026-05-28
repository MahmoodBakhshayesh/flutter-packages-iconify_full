# iconify_full example

Demo app (lives inside the package for pub.dev `example/` discovery).

## Setup

```bash
# From this directory (iconify_full/example)
flutter pub get
dart run iconify_full:iconify_init

# Download cache at repo root (once)
cd ../..
dart run iconify_full:iconify_download --cache .iconify_cache

cd iconify_full/example
dart run iconify_full:iconify_subset
flutter run -d windows
```

Cache path in `pubspec.yaml`: `../../.iconify_cache` (repo root).
