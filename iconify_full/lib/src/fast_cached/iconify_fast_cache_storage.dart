import 'iconify_fast_cache_storage_io.dart'
    if (dart.library.html) 'iconify_fast_cache_storage_web.dart'
    as impl;

/// Disk-backed cache paths under a root directory (no-op on web).
class IconifyFastCacheStorage {
  IconifyFastCacheStorage(this.rootPath);

  final String? rootPath;

  bool get isAvailable => rootPath != null && rootPath!.isNotEmpty;

  Future<String?> readSvg(String prefix, String name) =>
      impl.readSvg(rootPath, prefix, name);

  Future<void> writeSvg(String prefix, String name, String svg) =>
      impl.writeSvg(rootPath, prefix, name, svg);

  Future<String?> readJson(String prefix) => impl.readJson(rootPath, prefix);

  Future<void> writeJson(String prefix, String body) =>
      impl.writeJson(rootPath, prefix, body);

  Future<String?> readCollections() => impl.readCollections(rootPath);

  Future<void> writeCollections(String body) =>
      impl.writeCollections(rootPath, body);
}
