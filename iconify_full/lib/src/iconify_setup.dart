import 'iconify_debug_cache.dart';
import 'iconify_manifest.dart';

/// One-call setup for apps (manifest + optional debug cache path).
void setupIconifyFull({
  required IconifyAssetResolver manifest,
  String? debugCachePath,
}) {
  registerIconifyManifest(manifest);
  if (debugCachePath != null && debugCachePath.isNotEmpty) {
    registerIconifyDebugCache(debugCachePath);
  }
}
