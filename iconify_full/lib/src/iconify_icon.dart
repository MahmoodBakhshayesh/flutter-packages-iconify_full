import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'builder/svg_export.dart';
import 'iconify_icon_ref.dart';
import 'iconify_manifest.dart';
import 'iconify_theme.dart';

/// Renders an Iconify icon from a subsetted SVG asset with theme support.
class IconifyIcon extends StatelessWidget {
  const IconifyIcon(
    String id, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.fit,
    this.alignment,
    this.package,
  }) : _id = id,
       ref = null;

  const IconifyIcon.named(
    this.ref, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.fit,
    this.alignment,
    this.package,
  }) : _id = null;

  final String? _id;
  final IconifyIconRef? ref;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final BoxFit? fit;
  final AlignmentGeometry? alignment;

  /// Set when loading assets from a dependency package.
  final String? package;

  String get iconId => ref?.id ?? _id!;

  @override
  Widget build(BuildContext context) {
    final inherited = IconifyTheme.maybeOf(context);
    final resolved = IconifyThemeData(
      color: color ?? inherited?.color,
      size: size ?? inherited?.size ?? 24,
      semanticLabel: semanticLabel ?? inherited?.semanticLabel,
      fit: fit ?? inherited?.fit ?? BoxFit.contain,
      alignment: alignment ?? inherited?.alignment ?? Alignment.center,
    );

    final assetPath = iconifyAssetFor(iconId);
    if (assetPath == null) {
      return _missingIcon(context, resolved);
    }

    final iconSize = resolved.size;
    Widget svg = SvgPicture.asset(
      assetPath,
      package: package,
      width: iconSize,
      height: iconSize,
      fit: resolved.fit,
      alignment: resolved.alignment,
      semanticsLabel: resolved.semanticLabel,
    );

    final tint = resolved.color ??
        IconTheme.of(context).color ??
        DefaultTextStyle.of(context).style.color;

    if (tint != null) {
      svg = ColorFiltered(
        colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
        child: svg,
      );
    }

    return svg;
  }

  Widget _missingIcon(BuildContext context, IconifyThemeData resolved) {
    final parsed = parseIconId(iconId);
    final label = parsed != null ? '${parsed.$1}/${parsed.$2}' : iconId;
    return Semantics(
      label: resolved.semanticLabel ?? 'Missing icon $label',
      child: SizedBox(
        width: resolved.size,
        height: resolved.size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.error),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.broken_image_outlined,
            size: resolved.size * 0.6,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}
