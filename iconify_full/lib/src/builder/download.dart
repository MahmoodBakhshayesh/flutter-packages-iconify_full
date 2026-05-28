import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'svg_export.dart';

const _collectionsUrl =
    'https://raw.githubusercontent.com/iconify/icon-sets/master/collections.json';
const _jsonBaseUrl =
    'https://raw.githubusercontent.com/iconify/icon-sets/master/json';
const _maxAttempts = 5;
const _retryDelay = Duration(seconds: 3);

Future<http.Response> _getWithRetry(Uri url) async {
  Object? lastError;
  for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
    try {
      final response = await http.get(url).timeout(const Duration(minutes: 2));
      if (response.statusCode == 200) return response;
      lastError = HttpException('HTTP ${response.statusCode} for $url');
    } on Exception catch (e) {
      lastError = e;
    }
    if (attempt < _maxAttempts) {
      await Future<void>.delayed(_retryDelay * attempt);
    }
  }
  throw lastError ?? StateError('Failed to GET $url');
}

/// Downloads all Iconify collections and exports SVGs into [cacheDir].
Future<void> runIconifyDownload({
  required Directory cacheDir,
  List<String>? onlyPrefixes,
  bool skipExisting = true,
  void Function(String message)? log,
}) async {
  void info(String msg) => log?.call(msg);

  info('Fetching collections list…');
  final collectionsResponse = await _getWithRetry(Uri.parse(_collectionsUrl));

  final collections =
      jsonDecode(collectionsResponse.body) as Map<String, dynamic>;
  var prefixes = collections.keys.toList()..sort();
  if (onlyPrefixes != null && onlyPrefixes.isNotEmpty) {
    final allow = onlyPrefixes.toSet();
    prefixes = prefixes.where(allow.contains).toList();
  }

  final jsonDir = Directory(p.join(cacheDir.path, 'json'));
  final svgDir = Directory(p.join(cacheDir.path, 'svg'));
  await jsonDir.create(recursive: true);
  await svgDir.create(recursive: true);

  var totalIcons = 0;
  for (var i = 0; i < prefixes.length; i++) {
    final prefix = prefixes[i];
    final meta = collections[prefix];
    final total = meta is Map ? meta['total'] : null;
    info('[${i + 1}/${prefixes.length}] $prefix ($total icons)…');

    final jsonFile = File(p.join(jsonDir.path, '$prefix.json'));
    Map<String, dynamic> set;

    if (skipExisting && jsonFile.existsSync()) {
      set = jsonDecode(await jsonFile.readAsString()) as Map<String, dynamic>;
    } else {
      final url = '$_jsonBaseUrl/$prefix.json';
      late final http.Response response;
      try {
        response = await _getWithRetry(Uri.parse(url));
      } on Exception catch (e) {
        info('  skip: $e');
        continue;
      }
      set = jsonDecode(response.body) as Map<String, dynamic>;
      await jsonFile.writeAsString(response.body);
    }

    final palette = meta is Map && meta['palette'] == true;
    final exported = exportIconSet(
      set,
      prefix,
      forceCurrentColor: palette != true,
    );

    final prefixSvgDir = Directory(p.join(svgDir.path, prefix));
    await prefixSvgDir.create(recursive: true);

    var written = 0;
    for (final entry in exported.entries) {
      final outFile = File(p.join(prefixSvgDir.path, '${entry.key}.svg'));
      if (skipExisting && outFile.existsSync()) {
        written++;
        continue;
      }
      await outFile.writeAsString(entry.value);
      written++;
    }
    totalIcons += written;
    info('  wrote $written SVG files');
  }

  await File(p.join(cacheDir.path, 'manifest.json')).writeAsString(
    jsonEncode({
      'prefixes': prefixes,
      'downloadedAt': DateTime.now().toUtc().toIso8601String(),
      'totalSvgFiles': totalIcons,
    }),
  );
  info('Done. Cache at ${cacheDir.path}');
}
