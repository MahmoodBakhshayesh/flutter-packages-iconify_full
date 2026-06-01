import 'iconify_debug_cache.dart';
import 'iconify_manifest.dart';

/// Registers the generated manifest and optional debug cache in one call.
///
/// Call from `main()` before [runApp]:
///
/// ```dart
/// setupIconifyFull(
///   manifest: iconify_manifest.iconifyAssetFor,
///   debugCachePath: '.iconify_cache', // optional, debug only
/// );
/// ```
void setupIconifyFull({
  /// Generated `iconifyAssetFor` from `iconify_manifest.g.dart`.
  required IconifyAssetResolver manifest,

  /// Path to `.iconify_cache` for debug loading when an icon is not subset yet.
  String? debugCachePath,
}) {
  registerIconifyManifest(manifest);
  if (debugCachePath != null && debugCachePath.isNotEmpty) {
    registerIconifyDebugCache(debugCachePath);
  }
}
