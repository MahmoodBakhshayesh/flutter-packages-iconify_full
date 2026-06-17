/// Offline [Iconify](https://icon-sets.iconify.design/) icons for Flutter.
///
/// ## Widgets
///
/// * [IconifyIcon] — themed SVG from bundled assets (after [runIconifySubset]).
/// * [FastCachedIconify] — download icons at runtime with disk/memory cache.
///
/// ## Setup
///
/// ```dart
/// import 'generated/iconify_manifest.g.dart' as iconify_manifest;
///
/// void main() {
///   setupIconifyFull(manifest: iconify_manifest.iconifyAssetFor);
///   runApp(const MyApp());
/// }
/// ```
///
/// ## CLI (dev)
///
/// * [runIconifyInit] — empty manifest for new apps
/// * [runIconifyDownload] — offline cache of icon sets
/// * [runIconifySubset] — copy only icons used in `lib/`
/// * [runAutoSubset] — subset from build hooks / CI
///
/// See the package README for full workflow.
library;

export 'iconify_full_plugin.dart' show IconifyFullPlugin;
export 'src/builder/auto_subset.dart' show runAutoSubset;
export 'src/builder/config.dart' show IconifyFullConfig;
export 'src/builder/download.dart' show runIconifyDownload;
export 'src/builder/init.dart' show runIconifyInit;
export 'src/builder/subset.dart' show runIconifySubset;
export 'src/builder/svg_export.dart' show iconId, normalizeIconIdString, parseIconId;
export 'src/fast_cached/fast_cached_iconify.dart';
export 'src/fast_cached/iconify_fast_cache_service.dart';
export 'src/iconify_debug_cache.dart' show registerIconifyDebugCache;
export 'src/iconify_icon.dart';
export 'src/iconify_icon_ref.dart';
export 'src/iconify_manifest.dart';
export 'src/iconify_setup.dart';
export 'src/iconify_theme.dart';
