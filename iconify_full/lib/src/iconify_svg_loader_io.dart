import 'dart:io';

import 'package:path/path.dart' as p;

import 'builder/svg_export.dart';

/// Reads SVG from `.iconify_cache/svg/{prefix}/{name}.svg`.
String? readSvgFromDebugCache(String id, String cachePath) {
  final parsed = parseIconId(id);
  if (parsed == null) return null;
  final (prefix, name) = parsed;
  final file = File(p.join(cachePath, 'svg', prefix, '$name.svg'));
  if (!file.existsSync()) return null;
  return file.readAsStringSync();
}
