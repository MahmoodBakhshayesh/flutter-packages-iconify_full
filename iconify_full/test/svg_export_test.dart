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

  test('mask icons keep #fff/#000 inside mask', () {
    final svg = iconDataToSvg(
      {
        'body':
            '<defs><mask id="m"><g fill="none">'
            '<path fill="#fff" d="M10 10"/>'
            '<path fill="#000" fill-rule="evenodd" d="M12 12"/>'
            '</g></mask></defs>'
            '<path fill="#000" d="M0 0h24v24H0z" mask="url(#m)"/>',
      },
      defaultWidth: 24,
      defaultHeight: 24,
    );
    expect(svg, contains('fill="#fff"'));
    expect(svg, contains('fill="#000"'));
    expect(svg, contains('fill="currentColor"'));
    expect(svg, isNot(contains('mask id="m"><g fill="none"><path fill="currentColor"')));
  });

  test('parseIconId', () {
    expect(parseIconId('mdi:home'), ('mdi', 'home'));
    expect(parseIconId('mdi/home'), ('mdi', 'home'));
    expect(parseIconId('ph--coffee'), ('ph', 'coffee'));
    expect(parseIconId('invalid'), isNull);
  });

  test('normalizeIconIdString', () {
    expect(normalizeIconIdString('mdi:home'), 'mdi:home');
    expect(normalizeIconIdString('ph--coffee'), 'ph:coffee');
    expect(normalizeIconIdString('fluent--people-32-regular'), 'fluent:people-32-regular');
    expect(normalizeIconIdString('invalid'), isNull);
  });
}
