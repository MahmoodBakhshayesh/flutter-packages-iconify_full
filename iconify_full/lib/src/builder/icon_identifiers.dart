/// Dart-safe names for generated icon catalog classes and fields.
library;

const _dartKeywords = {
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'function',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'sealed',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'typedef',
  'var',
  'void',
  'when',
  'while',
  'with',
  'yield',
};

/// `material-symbols` → `MaterialSymbols`, `mdi` → `Mdi`.
String prefixToDartClassName(String prefix) {
  final parts = prefix.split('-').where((p) => p.isNotEmpty);
  return parts.map((p) => p[0].toUpperCase() + p.substring(1)).join();
}

/// `star-bold` → `star_bold`, `3d-scale` → `i3d_scale`.
String dartFieldName(String iconName) {
  var safe = iconName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
  if (safe.isEmpty) safe = 'icon';
  if (RegExp(r'^\d').hasMatch(safe)) safe = 'i$safe';
  if (_dartKeywords.contains(safe)) safe = '${safe}_';
  return safe;
}

/// Legacy flat name used by subset `Iconifies` (`mdi_home`).
String iconRefFieldName(String prefix, String name) =>
    '${dartFieldName(prefix)}_${dartFieldName(name)}';
