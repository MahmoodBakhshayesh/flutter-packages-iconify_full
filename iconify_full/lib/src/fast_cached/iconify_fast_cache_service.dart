import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../builder/iconify_http.dart';
import '../builder/icon_set_parser.dart';
import '../builder/svg_export.dart';
import 'iconify_fast_cache_storage.dart';

/// Singleton that downloads and caches Iconify SVGs for [FastCachedIconify].
///
/// Usually accessed via [IconifyFastCacheService.instance] after
/// [FastCachedIconify.ensureInitialized].
class IconifyFastCacheService {
  IconifyFastCacheService._();

  /// Shared cache service used by all [FastCachedIconify] widgets.
  static final IconifyFastCacheService instance = IconifyFastCacheService._();

  final Map<String, String> _memory = {};
  final Map<String, Future<String?>> _inFlight = {};
  Map<String, dynamic>? _collections;
  IconifyFastCacheStorage? _storage;
  bool _initialized = false;

  /// Whether [ensureInitialized] completed successfully.
  bool get isInitialized => _initialized;

  /// Root cache path (null on web or before init).
  String? get cacheRootPath => _storage?.rootPath;

  /// Prepare cache directory and optional custom [cachePath].
  ///
  /// On IO platforms without [cachePath], uses app support dir + `iconify_fast_cache`.
  Future<void> ensureInitialized({String? cachePath}) async {
    if (_initialized) return;

    String? root;
    if (cachePath != null && cachePath.isNotEmpty) {
      root = cachePath;
    } else if (!kIsWeb) {
      try {
        final dir = await getApplicationSupportDirectory();
        root = p.join(dir.path, 'iconify_fast_cache');
      } on Object {
        root = null;
      }
    }

    _storage = IconifyFastCacheStorage(root);
    _initialized = true;
  }

  /// Clears the in-memory SVG cache (disk files are kept).
  void clearMemory() => _memory.clear();

  /// Returns SVG XML for [iconId], downloading and caching on first use.
  ///
  /// Returns `null` if [iconId] is invalid or the icon does not exist.
  Future<String?> loadSvg(String iconId) {
    final id = iconId.trim();
    final cached = _memory[id];
    if (cached != null) return Future.value(cached);

    final future = _inFlight.putIfAbsent(id, () => _loadSvg(id));
    future.whenComplete(() => _inFlight.remove(id));
    return future;
  }

  Future<String?> _loadSvg(String iconId) async {
    if (!_initialized) {
      await ensureInitialized();
    }

    final parsed = parseIconId(iconId);
    if (parsed == null) return null;
    final (prefix, name) = parsed;

    final fromDisk = await _storage?.readSvg(prefix, name);
    if (fromDisk != null) {
      _memory[iconId] = fromDisk;
      return fromDisk;
    }

    final svg = await _fetchSvg(prefix, name);
    if (svg == null) return null;

    _memory[iconId] = svg;
    await _storage?.writeSvg(prefix, name, svg);
    return svg;
  }

  Future<String?> _fetchSvg(String prefix, String name) async {
    final setJson = await _loadIconSetJson(prefix);
    if (setJson == null) return null;

    final set = jsonDecode(setJson) as Map<String, dynamic>;
    final data = resolveIcon(set, name);
    if (data == null || data['hidden'] == true) return null;

    final palette = await _isPaletteSet(prefix);
    final (w, h) = defaultIconSize(set);
    try {
      return iconDataToSvg(
        data,
        defaultWidth: w,
        defaultHeight: h,
        forceCurrentColor: !palette,
      );
    } on StateError {
      return null;
    }
  }

  Future<String?> _loadIconSetJson(String prefix) async {
    final cached = await _storage?.readJson(prefix);
    if (cached != null) return cached;

    final url = Uri.parse('$iconifyJsonBaseUrl/$prefix.json');
    final response = await iconifyHttpGet(url);
    await _storage?.writeJson(prefix, response.body);
    return response.body;
  }

  Future<bool> _isPaletteSet(String prefix) async {
    _collections ??= await _loadCollections();
    final meta = _collections?[prefix];
    return meta is Map && meta['palette'] == true;
  }

  Future<Map<String, dynamic>?> _loadCollections() async {
    final cached = await _storage?.readCollections();
    if (cached != null) {
      return jsonDecode(cached) as Map<String, dynamic>;
    }
    final response = await iconifyHttpGet(Uri.parse(iconifyCollectionsUrl));
    await _storage?.writeCollections(response.body);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
