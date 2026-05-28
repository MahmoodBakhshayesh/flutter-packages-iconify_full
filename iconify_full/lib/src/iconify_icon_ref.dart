import 'builder/svg_export.dart';

/// Typed reference to an Iconify icon (`prefix:name`).
class IconifyIconRef {
  const IconifyIconRef(this.prefix, this.name);

  final String prefix;
  final String name;

  String get id => iconId(prefix, name);

  @override
  String toString() => id;

  @override
  bool operator ==(Object other) =>
      other is IconifyIconRef && other.prefix == prefix && other.name == name;

  @override
  int get hashCode => Object.hash(prefix, name);
}
