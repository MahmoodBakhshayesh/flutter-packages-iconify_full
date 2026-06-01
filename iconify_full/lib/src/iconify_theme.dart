import 'package:flutter/material.dart';

/// Inherited theme for [IconifyIcon] (color, size, semantics).
class IconifyTheme extends InheritedWidget {
  const IconifyTheme({
    required this.data,
    required super.child,
    super.key,
  });

  final IconifyThemeData data;

  static IconifyThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<IconifyTheme>()?.data;
  }

  static IconifyThemeData of(BuildContext context) {
    final theme = maybeOf(context);
    assert(theme != null, 'No IconifyTheme found in context');
    return theme!;
  }

  @override
  bool updateShouldNotify(IconifyTheme oldWidget) =>
      oldWidget.data != data;
}

/// Default styling for Iconify SVG icons.
@immutable
class IconifyThemeData {
  /// Creates default icon styling for descendants.
  const IconifyThemeData({
    this.color,
    this.size = 24,
    this.semanticLabel,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  /// Tint color applied to monochrome SVGs (`currentColor`).
  final Color? color;

  /// Width and height of the icon widget.
  final double size;

  /// Accessibility label for the SVG.
  final String? semanticLabel;

  /// How the SVG is fitted in its box.
  final BoxFit fit;

  /// Alignment of the SVG within its box.
  final AlignmentGeometry alignment;

  /// Merges this theme with [other], preferring non-null fields from [other].
  IconifyThemeData merge(IconifyThemeData? other) {
    if (other == null) return this;
    return IconifyThemeData(
      color: other.color ?? color,
      size: other.size,
      semanticLabel: other.semanticLabel ?? semanticLabel,
      fit: other.fit,
      alignment: other.alignment,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is IconifyThemeData &&
      other.color == color &&
      other.size == size &&
      other.semanticLabel == semanticLabel &&
      other.fit == fit &&
      other.alignment == alignment;

  @override
  int get hashCode => Object.hash(color, size, semanticLabel, fit, alignment);
}
