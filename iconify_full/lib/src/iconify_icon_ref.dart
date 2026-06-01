import 'builder/svg_export.dart';

/// Typed reference to an Iconify icon (`prefix:name`).
class IconifyIconRef {
  /// Creates a ref for [prefix] and icon [name] within that set.
  const IconifyIconRef(this.prefix, this.name);

  /// Parses [id] or throws [ArgumentError] if not `prefix:name`.
  factory IconifyIconRef.fromId(String id) {
    final ref = IconifyIconRef.tryParse(id);
    if (ref == null) {
      throw ArgumentError('Invalid Iconify id: $id (expected prefix:name)');
    }
    return ref;
  }

  /// Returns null when [id] is not `prefix:name`.
  static IconifyIconRef? tryParse(String id) {
    final parsed = parseIconId(id);
    if (parsed == null) return null;
    return IconifyIconRef(parsed.$1, parsed.$2);
  }

  /// Icon set id (e.g. `mdi`, `solar`).
  final String prefix;

  /// Icon name within the set (e.g. `home`, `star-bold`).
  final String name;

  /// Canonical id: `prefix:name`.
  String get id => iconId(prefix, name);

  @override
  String toString() => id;

  @override
  bool operator ==(Object other) =>
      other is IconifyIconRef && other.prefix == prefix && other.name == name;

  @override
  int get hashCode => Object.hash(prefix, name);
}
