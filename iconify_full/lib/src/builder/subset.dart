import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'manifest_generator.dart';
import 'scan.dart';
import 'svg_export.dart';

/// Copies used icons from [cacheDir] into [projectDir] and generates manifest.
Future<void> runIconifySubset({
  required Directory projectDir,
  required Directory cacheDir,
  String assetsSubdir = 'assets/iconify',
  String manifestPath = 'lib/generated/iconify_manifest.g.dart',
  bool updatePubspec = true,
  void Function(String message)? log,
}) async {
  void info(String msg) => log?.call(msg);

  final libDir = Directory(p.join(projectDir.path, 'lib'));
  final ids = scanProjectForIconIds(libDir);
  if (ids.isEmpty) {
    info('No Iconify icon references found under lib/.');
    final manifestFile = File(p.join(projectDir.path, manifestPath));
    await manifestFile.parent.create(recursive: true);
    await manifestFile.writeAsString(
      generateIconifyManifestDart(
        {},
        extraHeaderComment:
            'No icons found. Add IconifyIcon(\'prefix:name\') in lib/ then re-run subset.',
      ),
    );
    info('Wrote empty manifest: ${manifestFile.path}');
    info('First-time setup: dart run iconify_full:iconify_init');
    if (updatePubspec) {
      await mergePubspecAssets(
        File(p.join(projectDir.path, 'pubspec.yaml')),
        assetsSubdir,
        assetPaths: const [],
      );
    }
    return;
  }
  info('Found ${ids.length} icon(s): ${ids.join(', ')}');

  final cacheSvg = Directory(p.join(cacheDir.path, 'svg'));
  final assetsDir = Directory(p.join(projectDir.path, assetsSubdir));
  if (assetsDir.existsSync()) {
    await assetsDir.delete(recursive: true);
  }
  await assetsDir.create(recursive: true);

  final manifest = <String, String>{};
  final missing = <String>[];

  for (final id in ids) {
    final parsed = parseIconId(id);
    if (parsed == null) continue;
    final (prefix, name) = parsed;
    final source = File(p.join(cacheSvg.path, prefix, '$name.svg'));
    if (!source.existsSync()) {
      missing.add(id);
      continue;
    }
    final relPath = p.join(assetsSubdir, prefix, '$name.svg')
        .replaceAll(r'\', '/');
    final dest = File(p.join(projectDir.path, relPath));
    await dest.parent.create(recursive: true);
    await source.copy(dest.path);
    manifest[id] = relPath;
  }

  if (missing.isNotEmpty) {
    info(
      'Missing ${missing.length} icon(s) in cache (run iconify_download): '
      '${missing.join(', ')}',
    );
  }

  final manifestFile = File(p.join(projectDir.path, manifestPath));
  await manifestFile.parent.create(recursive: true);
  await manifestFile.writeAsString(generateIconifyManifestDart(manifest));
  info('Wrote ${manifestFile.path}');

  if (updatePubspec) {
    await mergePubspecAssets(
      File(p.join(projectDir.path, 'pubspec.yaml')),
      assetsSubdir,
      assetPaths: manifest.values.toList(),
    );
    info('Updated pubspec.yaml assets (${manifest.length} files)');
  }

  info('Subset complete (${manifest.length} assets).');
}

const _assetsBegin = '# >>> iconify_full assets';
const _assetsEnd = '# <<< iconify_full assets';

/// Registers subsetted SVG paths in pubspec (explicit paths — required for subfolders).
Future<void> mergePubspecAssets(
  File pubspecFile,
  String assetsDir, {
  List<String> assetPaths = const [],
}) async {
  var lines = await pubspecFile.readAsLines();
  lines = _removeGeneratedAssetBlock(lines);

  final flutterIdx = lines.indexWhere((l) => l == 'flutter:');
  if (flutterIdx == -1) {
    throw StateError('pubspec.yaml has no flutter: section');
  }

  var assetsIdx = -1;
  for (var i = flutterIdx + 1; i < lines.length; i++) {
    if (lines[i].trim() == 'assets:') {
      assetsIdx = i;
      break;
    }
    if (lines[i].isNotEmpty &&
        !lines[i].startsWith(' ') &&
        !lines[i].startsWith('\t')) {
      break;
    }
  }

  final block = <String>[
    _assetsBegin,
    ...assetPaths.map((p) => '    - $p'),
    _assetsEnd,
  ];

  if (assetsIdx == -1) {
    lines.insert(flutterIdx + 1, '  assets:');
    lines.insertAll(flutterIdx + 2, block);
  } else {
    lines.insertAll(assetsIdx + 1, block);
  }

  await pubspecFile.writeAsString('${lines.join('\n')}\n');
  loadYaml(await pubspecFile.readAsString());
}

List<String> _removeGeneratedAssetBlock(List<String> lines) {
  final out = <String>[];
  var skip = false;
  for (final line in lines) {
    if (line.trim() == _assetsBegin) {
      skip = true;
      continue;
    }
    if (line.trim() == _assetsEnd) {
      skip = false;
      continue;
    }
    if (!skip) out.add(line);
  }
  return out;
}
