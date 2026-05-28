import 'dart:io';

import 'package:args/args.dart';
import 'package:iconify_full/src/builder/codegen.dart';
import 'package:iconify_full/src/builder/config.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'project',
      abbr: 'p',
      help: 'App root (pubspec.yaml)',
      defaultsTo: '.',
    )
    ..addOption(
      'cache',
      help: 'Icon cache (default from pubspec iconify_full.cache)',
    )
    ..addOption(
      'out',
      help: 'Output directory',
      defaultsTo: 'lib/generated/iconify_catalog',
    )
    ..addMultiOption(
      'prefix',
      abbr: 'P',
      help: 'Only these icon set prefixes (e.g. mdi, solar)',
    );

  final args = parser.parse(arguments);
  final projectDir = Directory(args['project'] as String).absolute;
  if (!File('${projectDir.path}/pubspec.yaml').existsSync()) {
    stderr.writeln('No pubspec.yaml in ${projectDir.path}');
    exit(1);
  }

  final config = IconifyFullConfig.load(projectDir);
  final cacheArg = args['cache'] as String?;
  final resolvedCache = cacheArg != null
      ? (p.isAbsolute(cacheArg)
          ? Directory(cacheArg)
          : Directory('${projectDir.path}/$cacheArg'))
      : config.resolveCacheDir(projectDir);

  stdout.writeln('iconify_codegen → ${projectDir.path}');
  await runIconifyCodegen(
    projectDir: projectDir,
    cacheDir: resolvedCache,
    catalogDir: args['out'] as String,
    onlyPrefixes: (args['prefix'] as List<String>?)?.cast<String>(),
    log: stdout.writeln,
  );
}
