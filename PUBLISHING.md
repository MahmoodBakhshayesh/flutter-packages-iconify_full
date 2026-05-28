# Publishing `iconify_full` to pub.dev

## Before you publish

1. **Create a GitHub repo** (if you want public source links).
2. **Edit `iconify_full/pubspec.yaml`** — set real URLs:
   - `homepage`
   - `repository`
   - `issue_tracker`
   - `documentation`
3. **Log in to pub.dev:** `dart pub login`
4. **Claim the package name** on first publish (name must be unused).

## Dry run (required)

From the **package directory** (not the monorepo root):

```bash
cd iconify_full
dart pub publish --dry-run
```

Fix any warnings (missing LICENSE, oversized files, etc.).

## Publish 0.1.3

```bash
cd iconify_full
dart pub publish --dry-run   # must show 0 warnings
dart pub publish
```

Confirm version `0.1.3` in `pubspec.yaml` and `CHANGELOG.md` before publishing.

Confirm when prompted. You cannot unpublish; you can only publish new versions.

## What gets published

Only files under `iconify_full/` (the inner package folder):

- `lib/`, `bin/`, `android/`, `ios/`, `hooks/`
- `README.md`, `LICENSE`, `LICENSE-ICONS.md`, `CHANGELOG.md`, `pubspec.yaml`

**Not published:** `example/`, `.iconify_cache/`, monorepo root README.

## Version bumps

1. Update `version:` in `iconify_full/pubspec.yaml` (semver).
2. Add entry to `iconify_full/CHANGELOG.md`.
3. `dart pub publish --dry-run` then `dart pub publish`.

## pub.dev checklist

- [x] MIT `LICENSE` in package root
- [x] `LICENSE-ICONS.md` for icon artwork
- [x] README with install + usage + licensing
- [x] `CHANGELOG.md`
- [x] `description` in pubspec (≤ 180 chars for display)
- [x] `topics` in pubspec
- [ ] Your real `repository` URL in pubspec
- [ ] `dart pub publish --dry-run` passes
- [ ] Example app runs (optional but recommended)

## After publish

Users install with:

```yaml
dependencies:
  iconify_full: ^0.1.0
```

Point `documentation` on pub.dev to your README anchor or GitHub.
