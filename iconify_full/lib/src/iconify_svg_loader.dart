import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'builder/svg_export.dart';
import 'iconify_debug_cache.dart';
import 'iconify_svg_loader_io.dart' if (dart.library.html) 'iconify_svg_loader_web.dart' as io;
import 'iconify_theme.dart';

/// Returns a themed SVG widget, or null if the icon cannot be resolved.
Widget? tryBuildIconifySvg({
  required String iconId,
  required IconifyThemeData resolved,
  required BuildContext context,
  String? assetPath,
  String? package,
}) {
  final tint = _resolveTint(resolved, context);

  if (assetPath != null) {
    return SvgPicture.asset(
      assetPath,
      package: package,
      width: resolved.size,
      height: resolved.size,
      fit: resolved.fit,
      alignment: resolved.alignment,
      semanticsLabel: resolved.semanticLabel,
      colorFilter: tint != null ? ColorFilter.mode(tint, BlendMode.srcIn) : null,
    );
  }

  if (iconifyDebugCacheEnabled) {
    final svg = io.readSvgFromDebugCache(iconId, iconifyDebugCachePath!);
    if (svg != null) {
      return SvgPicture.string(
        svg,
        width: resolved.size,
        height: resolved.size,
        fit: resolved.fit,
        alignment: resolved.alignment,
        semanticsLabel: resolved.semanticLabel,
        colorFilter: tint != null ? ColorFilter.mode(tint, BlendMode.srcIn) : null,
      );
    }
  }

  return null;
}

Color? _resolveTint(IconifyThemeData resolved, BuildContext context) {
  return resolved.color ??
      IconTheme.of(context).color ??
      DefaultTextStyle.of(context).style.color;
}

Widget buildIconifyMissing(
  BuildContext context,
  IconifyThemeData resolved,
  String iconId,
) {
  final parsed = parseIconId(iconId);
  final label = parsed != null ? '${parsed.$1}/${parsed.$2}' : iconId;
  final hint = kReleaseMode
      ? 'Run: dart run iconify_full:iconify_subset'
      : 'Check .iconify_cache or run iconify_subset before release';
  return Semantics(
    label: resolved.semanticLabel ?? 'Missing icon $label',
    child: SizedBox(
      width: resolved.size,
      height: resolved.size,
      child: Tooltip(
        message: hint,
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
    ),
  );
}
