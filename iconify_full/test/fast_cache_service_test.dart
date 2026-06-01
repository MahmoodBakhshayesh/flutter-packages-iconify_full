import 'package:flutter_test/flutter_test.dart';
import 'package:iconify_full/src/builder/icon_set_parser.dart';
import 'package:iconify_full/src/builder/svg_export.dart';

void main() {
  test('iconDataToSvg exports mdi-style icon from json shape', () {
    final set = <String, dynamic>{
      'width': 24,
      'height': 24,
      'icons': {
        'home': {'body': '<path d="M10 20v-6h4v6h5v-8h3L12 3L2 12h3v8z"/>'},
      },
    };
    final data = resolveIcon(set, 'home');
    expect(data, isNotNull);
    final svg = iconDataToSvg(
      data!,
      defaultWidth: 24,
      defaultHeight: 24,
    );
    expect(svg, contains('<svg'));
    expect(svg, contains('currentColor'));
  });
}
