# iconify_full (monorepo)

Flutter package for offline [Iconify](https://icon-sets.iconify.design/) icons with themed SVGs and build-time subsetting.

## Repository layout

```
iconify_full/           ← you are here (monorepo root)
  .iconify_cache/       ← offline icons (gitignored, ~500MB+)
  iconify_full/         ← Dart package published to pub.dev
  example/              ← demo Flutter app
  PUBLISHING.md         ← how to publish to pub.dev
```

## Quick start

See the **[package README](iconify_full/README.md)** for full step-by-step usage.

```bash
cd iconify_full
flutter pub get
dart run :iconify_download --cache ../.iconify_cache

cd ../example
flutter pub get
dart run iconify_full:iconify_subset
flutter run
```

## Publish to pub.dev

Instructions: [PUBLISHING.md](PUBLISHING.md)

## License

- Package code: MIT — [iconify_full/LICENSE](iconify_full/LICENSE)
- Icons: per-set licenses — [iconify_full/LICENSE-ICONS.md](iconify_full/LICENSE-ICONS.md)
