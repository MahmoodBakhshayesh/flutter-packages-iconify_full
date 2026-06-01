import 'icon_set_parser.dart';

/// Builds a standalone SVG string from resolved Iconify icon [data].
String iconDataToSvg(
  Map<String, dynamic> data, {
  required double defaultWidth,
  required double defaultHeight,
  bool forceCurrentColor = true,
}) {
  final width = _toDouble(data['width']) ?? defaultWidth;
  final height = _toDouble(data['height']) ?? defaultHeight;
  final left = _toDouble(data['left']) ?? 0;
  final top = _toDouble(data['top']) ?? 0;

  var body = data['body'] as String? ?? '';
  if (body.isEmpty) {
    throw StateError('Icon body is empty');
  }

  if (forceCurrentColor) {
    body = _applyCurrentColor(body);
    if (!RegExp(r'fill=', caseSensitive: false).hasMatch(body)) {
      body = '<g fill="currentColor">$body</g>';
    }
  }

  final transforms = <String>[];
  final rotate = data['rotate'];
  if (rotate is num && rotate != 0) {
    final deg = (rotate.toInt() % 4) * 90;
    if (deg != 0) {
      transforms.add('rotate($deg ${width / 2} ${height / 2})');
    }
  }
  if (data['hFlip'] == true) {
    transforms.add('translate($width 0) scale(-1 1)');
  }
  if (data['vFlip'] == true) {
    transforms.add('translate(0 $height) scale(1 -1)');
  }

  if (transforms.isNotEmpty) {
    body = '<g transform="${transforms.join(' ')}">$body</g>';
  }

  final viewBox = '$left $top $width $height';
  return '<svg xmlns="http://www.w3.org/2000/svg" '
      'width="$width" height="$height" viewBox="$viewBox">$body</svg>';
}

double? _toDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

/// Replaces solid fills/strokes with currentColor for theme tinting.
///
/// Skips `<mask>` blocks so luminance masks (e.g. Solar `#fff` / `#000`) keep working.
String _applyCurrentColor(String body) {
  final maskBlocks = <String>[];
  final withoutMasks = body.replaceAllMapped(
    RegExp(r'<mask\b[^>]*>[\s\S]*?</mask>', caseSensitive: false),
    (match) {
      maskBlocks.add(match.group(0)!);
      return '{{ICONIFY_MASK_${maskBlocks.length - 1}}}';
    },
  );

  var processed = _replacePaintWithCurrentColor(withoutMasks);
  for (var i = 0; i < maskBlocks.length; i++) {
    processed = processed.replaceFirst('{{ICONIFY_MASK_$i}}', maskBlocks[i]);
  }
  return processed;
}

String _replacePaintWithCurrentColor(String fragment) {
  return fragment
      .replaceAllMapped(
        RegExp(
          r'''fill="(?!none|currentColor)([^"]+)"''',
          caseSensitive: false,
        ),
        (_) => 'fill="currentColor"',
      )
      .replaceAllMapped(
        RegExp(
          r'''stroke="(?!none|currentColor)([^"]+)"''',
          caseSensitive: false,
        ),
        (_) => 'stroke="currentColor"',
      );
}

/// Exports every icon in [set] with [prefix] to SVG strings keyed by icon name.
Map<String, String> exportIconSet(
  Map<String, dynamic> set,
  String prefix, {
  bool forceCurrentColor = true,
}) {
  final (defaultWidth, defaultHeight) = defaultIconSize(set);
  final icons = set['icons'];
  if (icons is! Map) return {};

  final names = <String>{
    ...icons.keys.cast<String>(),
    ...(set['aliases'] is Map
        ? (set['aliases'] as Map).keys.cast<String>()
        : <String>[]),
  };

  final out = <String, String>{};
  for (final name in names) {
    final data = resolveIcon(set, name);
    if (data == null || data['hidden'] == true) continue;
    try {
      out[name] = iconDataToSvg(
        data,
        defaultWidth: defaultWidth,
        defaultHeight: defaultHeight,
        forceCurrentColor: forceCurrentColor,
      );
    } on StateError {
      continue;
    }
  }
  return out;
}

/// Parses an Iconify id such as `mdi:home` or `mdi/home`.
///
/// Returns `(prefix, name)` or `null` if the format is invalid.
(String prefix, String name)? parseIconId(String id) {
  final trimmed = id.trim();
  if (trimmed.isEmpty) return null;
  final sep = trimmed.contains(':')
      ? ':'
      : trimmed.contains('/')
          ? '/'
          : null;
  if (sep == null) return null;
  final parts = trimmed.split(sep);
  if (parts.length != 2) return null;
  final prefix = parts[0].trim();
  final name = parts[1].trim();
  if (prefix.isEmpty || name.isEmpty) return null;
  return (prefix, name);
}

/// Canonical Iconify id string: `prefix:name`.
String iconId(String prefix, String name) => '$prefix:$name';
