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

  test('scan resolves static const icon refs like SvgAssets.explore', () async {
    final tmp = await Directory.systemTemp.createTemp('iconify_scan_');
    addTearDown(() => tmp.deleteSync(recursive: true));

    final lib = Directory(p.join(tmp.path, 'lib'));
    await lib.create(recursive: true);
    await File(p.join(lib.path, 'svg_assets.dart')).writeAsString('''
class SvgAssets {
  const SvgAssets._();

  static const String coffee = 'ph--coffee';
  static const String explore = 'solar:compass-broken';
  static const String home = 'solar--home-2-broken';
}
''');
    await File(p.join(lib.path, 'page.dart')).writeAsString('''
import 'package:iconify_full/iconify_full.dart';
import 'svg_assets.dart';

class Page {
  Widget build() => IconifyIcon(SvgAssets.explore);
}
''');

    final ids = scanProjectForIconIds(lib);

    expect(ids, {'solar:compass-broken'});
  });

  test('loadStaticIconRefMap normalizes const icon ids', () async {
    final tmp = await Directory.systemTemp.createTemp('iconify_scan_');
    addTearDown(() => tmp.deleteSync(recursive: true));

    final lib = Directory(p.join(tmp.path, 'lib'));
    await lib.create(recursive: true);
    await File(p.join(lib.path, 'svg_assets.dart')).writeAsString('''
class SvgAssets {
  static const String coffee = 'ph--coffee';
  static const String explore = 'solar:compass-broken';
}
''');

    final map = loadStaticIconRefMap(lib);

    expect(map['SvgAssets.coffee'], 'ph:coffee');
    expect(map['SvgAssets.explore'], 'solar:compass-broken');
  });

  test('scan resolves static const refs inside conditional IconifyIcon args', () async {
    final tmp = await Directory.systemTemp.createTemp('iconify_scan_');
    addTearDown(() => tmp.deleteSync(recursive: true));

    final lib = Directory(p.join(tmp.path, 'lib'));
    await lib.create(recursive: true);
    await File(p.join(lib.path, 'svg_assets.dart')).writeAsString('''
class SvgAssets {
  static const String bookmark = 'solar--bookmark-broken';
  static const String bookmarked = 'solar:bookmark-bold';
}

class AppColors {
  static const honeyBrown = 0;
  static const mediumBrown = 1;
}
''');
    await File(p.join(lib.path, 'page.dart')).writeAsString('''
import 'package:iconify_full/iconify_full.dart';
import 'svg_assets.dart';

class Page {
  Widget build(CoffeeDetails coffeeDetails) => IconifyIcon(
    coffeeDetails.isSavedByMe ? SvgAssets.bookmarked : SvgAssets.bookmark,
    color: coffeeDetails.isSavedByMe ? AppColors.honeyBrown : AppColors.mediumBrown,
  );
}

class CoffeeDetails {
  bool get isSavedByMe => false;
}
''');

    final ids = scanProjectForIconIds(lib);

    expect(ids, {'solar:bookmark-bold', 'solar:bookmark-broken'});
  });

  test('generateIconifyIconsDart emits IconifyIconRef constants', () {
    final dart = generateIconifyIconsDart([
      'mdi:home',
      'solar:star-bold',
      'fluent-emoji-high-contrast:pouring-liquid',
    ]);
    expect(dart, contains("static const mdi_home = IconifyIconRef('mdi', 'home');"));
    expect(
      dart,
      contains("static const solar_star_bold = IconifyIconRef('solar', 'star-bold');"),
    );
    expect(
      dart,
      contains(
        "static const fluent_emoji_high_contrast_pouring_liquid = "
        "IconifyIconRef('fluent-emoji-high-contrast', 'pouring-liquid');",
      ),
    );
  });
}
