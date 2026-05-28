import 'dart:io';

import 'svg_export.dart';

/// Finds Iconify icon ids referenced in Dart sources under [libDir].
Set<String> scanProjectForIconIds(Directory libDir) {
  final ids = <String>{};
  if (!libDir.existsSync()) return ids;

  final patterns = <RegExp>[
  // IconifyIcon('mdi:home')
    RegExp(
      r'''IconifyIcon\s*\(\s*['"]([^'"]+)['"]''',
    ),
    // IconifyIcon.named(IconifyIconRef.mdi('home')) — ref helper
    RegExp(
      r'''IconifyIconRef\.([a-z0-9_-]+)\s*\(\s*['"]([^'"]+)['"]''',
    ),
    // const iconId = 'mdi:home' with nearby Iconify comment (optional)
    RegExp(
      r'''['"]([a-z0-9_-]+:[a-z0-9_.-]+)['"]''',
    ),
  ];

  for (final entity in libDir.listSync(recursive: true, followLinks: false)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final content = entity.readAsStringSync();

    for (final match in patterns[0].allMatches(content)) {
      final id = match.group(1)!;
      if (parseIconId(id) != null) ids.add(id);
    }

    for (final match in patterns[1].allMatches(content)) {
      final prefix = match.group(1)!;
      final name = match.group(2)!;
      ids.add(iconId(prefix, name));
    }

    // Only pick explicit prefix:name near Iconify widgets; skip dart: imports etc.
    if (content.contains('Iconify')) {
      for (final match in patterns[2].allMatches(content)) {
        final id = match.group(1)!;
        if (id.startsWith('dart:')) continue;
        if (parseIconId(id) != null) ids.add(id);
      }
    }
  }

  return ids;
}
