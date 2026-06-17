import 'dart:io';

import 'svg_export.dart';

final _classDecl = RegExp(r'^\s*class\s+(\w+)');
final _staticConst = RegExp(
  r'''static\s+const(?:\s+String)?\s+(\w+)\s*=\s*['"]([^'"]+)['"]\s*;''',
);

/// Loads `ClassName.field` → normalized `prefix:name` from static const strings.
Map<String, String> loadStaticIconRefMap(Directory libDir) {
  final map = <String, String>{};
  if (!libDir.existsSync()) return map;

  for (final entity in libDir.listSync(recursive: true, followLinks: false)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (entity.path.contains(
      '${Platform.pathSeparator}generated${Platform.pathSeparator}',
    )) {
      continue;
    }

    String? currentClass;
    for (final line in entity.readAsLinesSync()) {
      final classMatch = _classDecl.firstMatch(line);
      if (classMatch != null) {
        currentClass = classMatch.group(1);
      }

      final constMatch = _staticConst.firstMatch(line);
      if (constMatch == null || currentClass == null) continue;

      final normalized = normalizeIconIdString(constMatch.group(2)!);
      if (normalized != null) {
        map['$currentClass.${constMatch.group(1)}'] = normalized;
      }
    }
  }

  return map;
}
