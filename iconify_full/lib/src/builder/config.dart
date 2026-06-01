import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Settings read from the app `pubspec.yaml` `iconify_full:` section.
///
/// Used by CLI tools ([runIconifyDownload], [runIconifySubset], etc.).
/// Load with [IconifyFullConfig.load] from your project root.
class IconifyFullConfig {
  /// Creates config with optional overrides (defaults match package README).
  const IconifyFullConfig({
    this.cachePath = '.iconify_cache',
    this.assetsDir = 'assets/iconify',
    this.manifestPath = 'lib/generated/iconify_manifest.g.dart',
    this.autoSubset = true,
  });

  /// Directory for downloaded Iconify JSON/SVG (relative to app root or absolute).
  final String cachePath;

  /// Where subset copies SVG files into the Flutter app.
  final String assetsDir;

  /// Generated Dart manifest path (`iconifyAssetFor` map).
  final String manifestPath;

  /// Whether native build hooks should run subset automatically.
  final bool autoSubset;

  /// Reads `iconify_full:` from [projectDir]/`pubspec.yaml`, or defaults.
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

  /// Resolves [cachePath] to an existing directory when possible.
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
