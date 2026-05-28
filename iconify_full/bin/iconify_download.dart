import 'dart:io';

import 'package:args/args.dart';
import 'package:iconify_full/src/builder/download.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'cache',
      abbr: 'c',
      help: 'Cache directory',
      defaultsTo: '.iconify_cache',
    )
    ..addMultiOption(
      'prefix',
      abbr: 'p',
      help: 'Download only these icon set prefixes',
    )
    ..addFlag(
      'force',
      abbr: 'f',
      help: 'Re-download even if files exist',
      negatable: false,
    );

  final args = parser.parse(arguments);
  final cachePath = p.normalize(args['cache'] as String);

  stdout.writeln('Iconify download → $cachePath');
  await runIconifyDownload(
    cacheDir: Directory(cachePath),
    onlyPrefixes: (args['prefix'] as List<String>?)?.cast<String>(),
    skipExisting: args['force'] != true,
    log: stdout.writeln,
  );
}
