import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iconify_full/src/builder/icon_identifiers.dart';
import 'package:iconify_full/src/builder/icons_catalog_generator.dart';
import 'package:path/path.dart' as p;

void main() {
  test('prefixToDartClassName and dartFieldName', () {
    expect(prefixToDartClassName('mdi'), 'Mdi');
    expect(prefixToDartClassName('material-symbols'), 'MaterialSymbols');
    expect(dartFieldName('star-bold'), 'star_bold');
    expect(dartFieldName('3d-scale'), 'i3d_scale');
    expect(dartFieldName('class'), 'class_');
  });

  test('generateIconifyCatalog writes per-set classes', () async {
    final tmp = await Directory.systemTemp.createTemp('iconify_cat_');
    addTearDown(() => tmp.deleteSync(recursive: true));

    final cache = Directory(p.join(tmp.path, 'cache'));
    final jsonDir = Directory(p.join(cache.path, 'json'));
    await jsonDir.create(recursive: true);
    await File(p.join(jsonDir.path, 'mdi.json')).writeAsString(jsonEncode({
      'icons': {
        'home': {'body': '<path d="M0 0"/>'},
        'heart': {'body': '<path d="M0 0"/>'},
      },
    }));

    final out = Directory(p.join(tmp.path, 'out'));
    final result = await generateIconifyCatalog(
      cacheDir: cache,
      outDir: out,
    );

    expect(result.setCount, 1);
    expect(result.iconCount, 2);

    final mdiFile = File(p.join(out.path, 'mdi.dart'));
    expect(mdiFile.existsSync(), isTrue);
    expect(mdiFile.readAsStringSync(), contains('class Mdi'));
    expect(mdiFile.readAsStringSync(), contains("IconifyIconRef('mdi', 'home')"));

    final map = loadCatalogIconRefMap(out);
    expect(map['Mdi.home'], 'mdi:home');
  });
}
