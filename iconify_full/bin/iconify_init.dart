import 'dart:io';

import 'package:args/args.dart';
import 'package:iconify_full/src/builder/init.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'project',
      abbr: 'j',
      help: 'Flutter app root (pubspec.yaml)',
      defaultsTo: '.',
    )
    ..addFlag(
      'force',
      abbr: 'f',
      help: 'Overwrite existing manifest',
      negatable: false,
    )
    ..addFlag(
      'no-pubspec',
      help: 'Do not modify pubspec.yaml',
      negatable: false,
    );

  final args = parser.parse(arguments);
  final projectDir = Directory(p.normalize(args['project'] as String));

  stdout.writeln('iconify_init → ${projectDir.path}');
  await runIconifyInit(
    projectDir: projectDir,
    force: args['force'] == true,
    updatePubspec: args['no-pubspec'] != true,
    log: stdout.writeln,
  );
}
