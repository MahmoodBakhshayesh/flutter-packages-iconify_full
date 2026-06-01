import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'iconify_http.dart';
import 'svg_export.dart';

/// Downloads Iconify JSON from GitHub and writes SVGs into [cacheDir].
///
/// Run via: `dart run iconify_full:iconify_download`
///
/// Use [onlyPrefixes] to limit sets (e.g. `mdi`, `solar`) for faster downloads.
Future<void> runIconifyDownload({
  required Directory cacheDir,
  List<String>? onlyPrefixes,
  bool skipExisting = true,
  void Function(String message)? log,
}) async {
  void info(String msg) => log?.call(msg);

  info('Fetching collections list…');
  final collectionsResponse =
      await iconifyHttpGet(Uri.parse(iconifyCollectionsUrl));

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
      final url = '$iconifyJsonBaseUrl/$prefix.json';
      try {
        final response = await iconifyHttpGet(Uri.parse(url));
        set = jsonDecode(response.body) as Map<String, dynamic>;
        await jsonFile.writeAsString(response.body);
      } on Exception catch (e) {
        info('  skip: $e');
        continue;
      }
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
