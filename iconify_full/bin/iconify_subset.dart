import 'dart:io';

import 'package:args/args.dart';
import 'package:iconify_full/src/builder/auto_subset.dart';
import 'package:iconify_full/src/builder/config.dart';
import 'package:iconify_full/src/builder/subset.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'project',
      abbr: 'j',
      help: 'Flutter app root',
      defaultsTo: '.',
    )
    ..addOption(
      'cache',
      abbr: 'c',
      help: 'Icon cache (default from pubspec iconify_full.cache)',
    )
    ..addOption(
      'assets-dir',
      help: 'Assets output folder under project',
    )
    ..addFlag(
      'no-pubspec',
      help: 'Do not modify pubspec.yaml',
      negatable: false,
    )
    ..addFlag(
      'use-config',
      help: 'Use pubspec iconify_full section for all defaults',
      negatable: false,
      defaultsTo: true,
    );

  final args = parser.parse(arguments);
  final projectDir = Directory(p.normalize(args['project'] as String));
  final config = IconifyFullConfig.load(projectDir);

  if (args['use-config'] == true && args['cache'] == null) {
    stdout.writeln('Iconify subset (auto) → ${projectDir.path}');
    await runAutoSubset(projectDir: projectDir, log: stdout.writeln);
    return;
  }

  final cachePath = p.normalize(
    args['cache'] as String? ?? config.cachePath,
  );
  final cacheDir = p.isAbsolute(cachePath)
      ? Directory(cachePath)
      : Directory(p.join(projectDir.path, cachePath));

  stdout.writeln('Iconify subset ← ${cacheDir.path} → ${projectDir.path}');
  await runIconifySubset(
    projectDir: projectDir,
    cacheDir: cacheDir,
    assetsSubdir: args['assets-dir'] as String? ?? config.assetsDir,
    manifestPath: config.manifestPath,
    updatePubspec: args['no-pubspec'] != true,
    log: stdout.writeln,
  );
}
