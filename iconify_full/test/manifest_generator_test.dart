import 'package:flutter_test/flutter_test.dart';
import 'package:iconify_full/src/builder/manifest_generator.dart';

void main() {
  test('starter manifest is valid dart', () {
    final code = generateStarterManifestDart();
    expect(code, contains('kIconifyManifest'));
    expect(code, contains('iconifyAssetFor'));
    expect(code, contains('iconify_init'));
  });

  test('subset manifest includes entries', () {
    final code = generateIconifyManifestDart({
      'mdi:home': 'assets/iconify/mdi/home.svg',
    });
    expect(code, contains("'mdi:home'"));
    expect(code, contains('assets/iconify/mdi/home.svg'));
  });
}
