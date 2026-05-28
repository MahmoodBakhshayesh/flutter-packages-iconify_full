import 'package:flutter_test/flutter_test.dart';
import 'package:iconify_full/src/builder/icon_set_parser.dart';
import 'package:iconify_full/src/builder/svg_export.dart';

void main() {
  test('resolves alias and exports SVG', () {
    final set = <String, dynamic>{
      'prefix': 'test',
      'width': 24,
      'height': 24,
      'icons': {
        'parent': {
          'body': '<path d="M0 0"/>',
        },
      },
      'aliases': {
        'child': {'parent': 'parent', 'hFlip': true},
      },
    };

    final data = resolveIcon(set, 'child');
    expect(data, isNotNull);
    expect(data!['hFlip'], isTrue);

    final svg = iconDataToSvg(
      data,
      defaultWidth: 24,
      defaultHeight: 24,
    );
    expect(svg, contains('<svg'));
    expect(svg, contains('currentColor'));
  });

  test('parseIconId', () {
    expect(parseIconId('mdi:home'), ('mdi', 'home'));
    expect(parseIconId('mdi/home'), ('mdi', 'home'));
    expect(parseIconId('invalid'), isNull);
  });
}
