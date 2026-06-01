import 'package:flutter/foundation.dart';

String? _debugCachePath;

/// Points [IconifyIcon] at `.iconify_cache` in debug when an icon is missing from assets.
///
/// Ignored in release builds. Prefer [setupIconifyFull] with `debugCachePath`.
void registerIconifyDebugCache(String cachePath) {
  if (kReleaseMode) return;
  _debugCachePath = cachePath;
}

String? get iconifyDebugCachePath =>
    kReleaseMode ? null : _debugCachePath;

bool get iconifyDebugCacheEnabled =>
    !kReleaseMode && _debugCachePath != null && _debugCachePath!.isNotEmpty;
