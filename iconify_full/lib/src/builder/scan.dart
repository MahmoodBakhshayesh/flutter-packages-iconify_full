import 'dart:io';

import 'icon_ref_registry.dart' show loadStaticIconRefMap;
import 'svg_export.dart';

export 'icon_ref_registry.dart' show loadStaticIconRefMap;

/// Finds Iconify icon ids referenced in Dart sources under [libDir].
Set<String> scanProjectForIconIds(
  Directory libDir, {
  Map<String, String> iconifiesMap = const {},
  Map<String, String> catalogMap = const {},
  Map<String, String> staticRefMap = const {},
}) {
  final ids = <String>{};
  if (!libDir.existsSync()) return ids;

  final resolvedStaticRefs = staticRefMap.isEmpty
      ? loadStaticIconRefMap(libDir)
      : staticRefMap;

  final patterns = <RegExp>[
    // IconifyIcon('mdi:home')
    RegExp(
      r'''IconifyIcon\s*\(\s*['"]([^'"]+)['"]''',
    ),
    // IconifyIcon.named(Iconifies.mdi_home) or IconifyIcon(Iconifies.mdi_home)
    RegExp(
      r'''IconifyIcon(?:\.named)?\s*\(\s*Iconifies\.([a-zA-Z0-9_]+)''',
    ),
    // IconifyIcon(SvgAssets.explore), IconifyIcon.named(Mdi.home)
    RegExp(
      r'''IconifyIcon(?:\.named)?\s*\(\s*([A-Z][a-zA-Z0-9]*)\.([a-zA-Z0-9_]+)''',
    ),
    // IconifyIconRef.mdi('home')
    RegExp(
      r'''IconifyIconRef\.([a-z0-9_-]+)\s*\(\s*['"]([^'"]+)['"]''',
    ),
    // const iconId = 'mdi:home' with nearby Iconify comment (optional)
    RegExp(
      r'''['"]([a-z0-9_-]+:[a-z0-9_.-]+)['"]''',
    ),
    // FastCachedIconify('mdi:home') or FastCachedIconify(SvgAssets.home)
    RegExp(
      r'''FastCachedIconify(?:\.named)?\s*\(\s*(?:['"]([^'"]+)['"]|([A-Z][a-zA-Z0-9]*)\.([a-zA-Z0-9_]+))''',
    ),
  ];

  for (final entity in libDir.listSync(recursive: true, followLinks: false)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (entity.path.contains(
      '${Platform.pathSeparator}generated${Platform.pathSeparator}',
    )) {
      continue;
    }
    final content = entity.readAsStringSync();

    for (final match in patterns[0].allMatches(content)) {
      final id = normalizeIconIdString(match.group(1)!);
      if (id != null) ids.add(id);
    }

    for (final match in patterns[1].allMatches(content)) {
      final field = match.group(1)!;
      final id = iconifiesMap[field];
      if (id != null) ids.add(id);
    }

    for (final match in patterns[2].allMatches(content)) {
      final key = '${match.group(1)!}.${match.group(2)!}';
      final id = catalogMap[key] ?? resolvedStaticRefs[key];
      if (id != null) ids.add(id);
    }

    for (final match in patterns[3].allMatches(content)) {
      final prefix = match.group(1)!;
      final name = match.group(2)!;
      ids.add(iconId(prefix, name));
    }

    if (content.contains('Iconify')) {
      for (final match in patterns[4].allMatches(content)) {
        final id = match.group(1)!;
        if (id.startsWith('dart:')) continue;
        final normalized = normalizeIconIdString(id);
        if (normalized != null) ids.add(normalized);
      }
    }

    for (final match in patterns[5].allMatches(content)) {
      final literal = match.group(1);
      if (literal != null) {
        final id = normalizeIconIdString(literal);
        if (id != null) ids.add(id);
        continue;
      }
      final key = '${match.group(2)!}.${match.group(3)!}';
      final id = catalogMap[key] ?? resolvedStaticRefs[key];
      if (id != null) ids.add(id);
    }
  }

  return ids;
}
