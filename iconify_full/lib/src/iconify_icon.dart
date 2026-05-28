import 'package:flutter/material.dart';

import 'iconify_icon_ref.dart';
import 'iconify_manifest.dart';
import 'iconify_svg_loader.dart';
import 'iconify_theme.dart';

/// Renders an Iconify icon from bundled assets (release) or the offline cache (debug).
class IconifyIcon extends StatelessWidget {
  /// String id: `mdi:home` (not a const constructor — use [IconifyIcon.named] for `const`).
  IconifyIcon(
    String id, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.fit,
    this.alignment,
    this.package,
  }) : ref = IconifyIconRef.fromId(id);

  /// Typed ref: `const IconifyIcon.named(Iconifies.mdi_home)`
  const IconifyIcon.named(
    this.ref, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.fit,
    this.alignment,
    this.package,
  });

  final IconifyIconRef ref;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final BoxFit? fit;
  final AlignmentGeometry? alignment;

  /// Set when loading assets from a dependency package.
  final String? package;

  String get iconId => ref.id;

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

    return tryBuildIconifySvg(
          iconId: iconId,
          resolved: resolved,
          context: context,
          assetPath: iconifyAssetFor(iconId),
          package: package,
        ) ??
        buildIconifyMissing(context, resolved, iconId);
  }
}
