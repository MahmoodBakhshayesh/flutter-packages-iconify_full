/// Parses IconifyJSON and resolves icon aliases.
library;

/// Merges [override] onto [base] (Iconify alias rules).
Map<String, dynamic> mergeIconData(
  Map<String, dynamic> base,
  Map<String, dynamic> override,
) {
  final merged = Map<String, dynamic>.from(base);
  for (final entry in override.entries) {
    if (entry.key == 'parent') continue;
    merged[entry.key] = entry.value;
  }
  return merged;
}

/// Resolves one icon from an IconifyJSON [set] by [name], following aliases.
Map<String, dynamic>? resolveIcon(
  Map<String, dynamic> set,
  String name, [
  Set<String>? visited,
]) {
  visited ??= <String>{};
  if (visited.contains(name)) return null;
  visited.add(name);

  final icons = set['icons'];
  if (icons is! Map) return null;
  final raw = icons[name];
  if (raw is Map<String, dynamic>) {
    return Map<String, dynamic>.from(raw);
  }
  if (raw is Map) {
    return Map<String, dynamic>.from(raw.cast<String, dynamic>());
  }

  final aliases = set['aliases'];
  if (aliases is! Map) return null;
  final alias = aliases[name];
  if (alias is! Map) return null;
  final parent = alias['parent'];
  if (parent is! String) return null;

  final resolved = resolveIcon(set, parent, visited);
  if (resolved == null) return null;
  return mergeIconData(
    resolved,
    Map<String, dynamic>.from(alias.cast<String, dynamic>()),
  );
}

/// Default width/height from collection metadata.
(double width, double height) defaultIconSize(Map<String, dynamic> set) {
  final info = set['info'];
  if (info is Map) {
    final w = _toDouble(info['width']);
    final h = _toDouble(info['height']);
    if (w != null && h != null) return (w, h);
  }
  final w = _toDouble(set['width']) ?? 16;
  final h = _toDouble(set['height']) ?? 16;
  return (w, h);
}

double? _toDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
