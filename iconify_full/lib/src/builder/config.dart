import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Config from the app `pubspec.yaml` `iconify_full:` section.
class IconifyFullConfig {
  const IconifyFullConfig({
    this.cachePath = '.iconify_cache',
    this.assetsDir = 'assets/iconify',
    this.manifestPath = 'lib/generated/iconify_manifest.g.dart',
    this.autoSubset = true,
  });

  final String cachePath;
  final String assetsDir;
  final String manifestPath;
  final bool autoSubset;

  static IconifyFullConfig load(Directory projectDir) {
    final pubspecFile = File(p.join(projectDir.path, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      return const IconifyFullConfig();
    }
    final doc = loadYaml(pubspecFile.readAsStringSync());
    if (doc is! Map) return const IconifyFullConfig();
    final raw = doc['iconify_full'];
    if (raw is! Map) return const IconifyFullConfig();
    return IconifyFullConfig(
      cachePath: raw['cache']?.toString() ?? '.iconify_cache',
      assetsDir: raw['assets_dir']?.toString() ?? 'assets/iconify',
      manifestPath:
          raw['manifest']?.toString() ?? 'lib/generated/iconify_manifest.g.dart',
      autoSubset: raw['auto_subset'] != false,
    );
  }

  Directory resolveCacheDir(Directory projectDir) {
    if (p.isAbsolute(cachePath)) {
      return Directory(cachePath);
    }
    final candidates = [
      Directory(p.join(projectDir.path, cachePath)),
      if (cachePath == '.iconify_cache')
        Directory(p.join(projectDir.path, '..', '.iconify_cache')),
    ];
    for (final dir in candidates) {
      if (dir.existsSync()) return dir;
    }
    return candidates.first;
  }
}
