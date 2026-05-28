import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iconify_full/src/builder/icons_generator.dart';
import 'package:iconify_full/src/builder/scan.dart';
import 'package:path/path.dart' as p;

void main() {
  test('scan finds string and Iconifies references', () async {
    final tmp = await Directory.systemTemp.createTemp('iconify_scan_');
    addTearDown(() => tmp.deleteSync(recursive: true));

    final lib = Directory(p.join(tmp.path, 'lib'));
    await lib.create(recursive: true);
    await File(p.join(lib.path, 'home.dart')).writeAsString('''
import 'package:iconify_full/iconify_full.dart';
import 'generated/iconify_icons.g.dart';

class Page {
  Widget build() => Column(
    children: [
      const IconifyIcon('mdi:home'),
      const IconifyIcon.named(Iconifies.mdi_heart),
    ],
  );
}
''');

    final generated = Directory(p.join(lib.path, 'generated'));
    await generated.create(recursive: true);
    await File(p.join(generated.path, 'iconify_icons.g.dart')).writeAsString('''
class Iconifies {
  static const mdi_heart = IconifyIconRef('mdi', 'heart');
}
''');

    final map = loadIconifiesConstMap(tmp);
    final ids = scanProjectForIconIds(lib, iconifiesMap: map);

    expect(ids, containsAll(['mdi:home', 'mdi:heart']));
  });

  test('generateIconifyIconsDart emits IconifyIconRef constants', () {
    final dart = generateIconifyIconsDart(['mdi:home', 'solar:star-bold']);
    expect(dart, contains("static const mdi_home = IconifyIconRef('mdi', 'home');"));
    expect(
      dart,
      contains("static const solar_star_bold = IconifyIconRef('solar', 'star-bold');"),
    );
  });
}
