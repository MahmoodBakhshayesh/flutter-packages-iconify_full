import 'package:flutter/foundation.dart';

/// Registered in debug via [registerIconifyDebugCache] (ignored in release builds).
String? _debugCachePath;

/// Offline cache used when an icon is not yet in the release asset bundle.
/// No-op in [kReleaseMode] — release builds rely on subset + [registerIconifyManifest].
void registerIconifyDebugCache(String cachePath) {
  if (kReleaseMode) return;
  _debugCachePath = cachePath;
}

String? get iconifyDebugCachePath =>
    kReleaseMode ? null : _debugCachePath;

bool get iconifyDebugCacheEnabled =>
    !kReleaseMode && _debugCachePath != null && _debugCachePath!.isNotEmpty;
