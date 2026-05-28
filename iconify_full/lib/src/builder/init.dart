import 'dart:io';

import 'package:path/path.dart' as p;

import 'config.dart';
import 'manifest_generator.dart';
import 'subset.dart' show mergePubspecAssets;

/// Creates [manifestPath] and optional assets entry for a new app.
Future<void> runIconifyInit({
  required Directory projectDir,
  bool updatePubspec = true,
  bool force = false,
  void Function(String message)? log,
}) async {
  void info(String msg) => log?.call(msg);

  final config = IconifyFullConfig.load(projectDir);
  final manifestFile = File(p.join(projectDir.path, config.manifestPath));

  if (manifestFile.existsSync() && !force) {
    info('Manifest already exists: ${manifestFile.path}');
    info('Use --force to overwrite with a fresh starter file.');
    _printNextSteps(info);
    return;
  }

  await manifestFile.parent.create(recursive: true);
  await manifestFile.writeAsString(generateStarterManifestDart());
  info('Created ${manifestFile.path}');

  if (updatePubspec) {
    await mergePubspecAssets(
      File(p.join(projectDir.path, 'pubspec.yaml')),
      config.assetsDir,
      assetPaths: const [],
    );
    info('Updated pubspec.yaml (run subset after adding icons)');
  }

  final assetsDir = Directory(p.join(projectDir.path, config.assetsDir));
  if (!assetsDir.existsSync()) {
    await assetsDir.create(recursive: true);
    // Placeholder so empty assets folder is tracked; subset replaces contents.
    await File(p.join(assetsDir.path, '.gitkeep')).writeAsString('');
    info('Created ${assetsDir.path}/');
  }

  info('');
  info('Add to lib/main.dart (before runApp):');
  info("  import '${_manifestImportPath(config.manifestPath)}' as iconify_manifest;");
  info('  registerIconifyManifest(iconify_manifest.iconifyAssetFor);');
  info('');
  _printNextSteps(info);
}

String _manifestImportPath(String manifestPath) {
  final normalized = manifestPath.replaceAll(r'\', '/');
  if (normalized.startsWith('lib/')) {
    return normalized.substring(4);
  }
  return normalized;
}

void _printNextSteps(void Function(String) info) {
  info('Next steps:');
  info('  1. Use IconifyIcon(\'mdi:home\') in lib/');
  info('  2. dart run iconify_full:iconify_download');
  info('  3. dart run iconify_full:iconify_subset');
  info('  4. flutter run');
}
