import 'dart:io';

import 'config.dart';
import 'subset.dart';

/// Runs subset for a Flutter app using [pubspec.yaml] `iconify_full:` config.
Future<void> runAutoSubset({
  required Directory projectDir,
  void Function(String message)? log,
}) async {
  final config = IconifyFullConfig.load(projectDir);
  if (!config.autoSubset) {
    log?.call('iconify_full: auto_subset is disabled in pubspec.yaml');
    return;
  }
  final cacheDir = config.resolveCacheDir(projectDir);
  if (!cacheDir.existsSync()) {
    log?.call(
      'iconify_full: cache not found at ${cacheDir.path} '
      '(run: dart run iconify_full:iconify_download)',
    );
    return;
  }
  await runIconifySubset(
    projectDir: projectDir,
    cacheDir: cacheDir,
    assetsSubdir: config.assetsDir,
    manifestPath: config.manifestPath,
    log: log,
  );
}
