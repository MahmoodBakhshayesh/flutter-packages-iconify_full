import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reuses [SvgPicture] instances to avoid parse/load flicker on parent rebuilds.
class IconifyPictureCache {
  IconifyPictureCache._();

  static final IconifyPictureCache instance = IconifyPictureCache._();

  final Map<String, Widget> _widgets = {};
  static const int _maxEntries = 256;

  String _key({
    required String source,
    String? package,
    double? width,
    double? height,
    Color? tint,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    String? semanticsLabel,
  }) {
    return [
      source,
      package ?? '',
      width?.toStringAsFixed(2) ?? '',
      height?.toStringAsFixed(2) ?? '',
      tint?.toARGB32() ?? '',
      fit?.name ?? '',
      alignment?.toString() ?? '',
      semanticsLabel ?? '',
    ].join('|');
  }

  Widget asset({
    required String assetPath,
    String? package,
    double? width,
    double? height,
    Color? tint,
    BoxFit? fit = BoxFit.contain,
    AlignmentGeometry? alignment = Alignment.center,
    String? semanticsLabel,
  }) {
    final key = _key(
      source: 'asset:$assetPath',
      package: package,
      width: width,
      height: height,
      tint: tint,
      fit: fit,
      alignment: alignment,
      semanticsLabel: semanticsLabel,
    );
    return _widgets.putIfAbsent(key, () {
      _evictIfNeeded();
      return SvgPicture.asset(
        assetPath,
        key: ValueKey(key),
        package: package,
        width: width,
        height: height,
        fit: fit ?? BoxFit.contain,
        alignment: alignment ?? Alignment.center,
        semanticsLabel: semanticsLabel,
        colorFilter:
            tint != null ? ColorFilter.mode(tint, BlendMode.srcIn) : null,
      );
    });
  }

  Widget string({
    required String svg,
    required String sourceId,
    double? width,
    double? height,
    Color? tint,
    BoxFit? fit = BoxFit.contain,
    AlignmentGeometry? alignment = Alignment.center,
    String? semanticsLabel,
  }) {
    final key = _key(
      source: 'string:$sourceId:${svg.hashCode}',
      width: width,
      height: height,
      tint: tint,
      fit: fit,
      alignment: alignment,
      semanticsLabel: semanticsLabel,
    );
    return _widgets.putIfAbsent(key, () {
      _evictIfNeeded();
      return SvgPicture.string(
        svg,
        key: ValueKey(key),
        width: width,
        height: height,
        fit: fit ?? BoxFit.contain,
        alignment: alignment ?? Alignment.center,
        semanticsLabel: semanticsLabel,
        colorFilter:
            tint != null ? ColorFilter.mode(tint, BlendMode.srcIn) : null,
      );
    });
  }

  void _evictIfNeeded() {
    if (_widgets.length <= _maxEntries) return;
    _widgets.remove(_widgets.keys.first);
  }
}
