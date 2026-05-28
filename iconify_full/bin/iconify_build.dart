import 'dart:io';

import 'package:iconify_full/src/builder/auto_subset.dart';
import 'package:path/path.dart' as p;

/// Runs icon subset then forwards to `flutter` (useful for web / CI).
Future<void> main(List<String> arguments) async {
  final projectDir = Directory(p.normalize('.'));
  await runAutoSubset(
    projectDir: projectDir,
    log: stdout.writeln,
  );

  final flutter = Platform.isWindows ? 'flutter.bat' : 'flutter';
  final code = await Process.run(
    flutter,
    arguments,
    runInShell: Platform.isWindows,
  ).then((r) => r.exitCode);
  exit(code);
}
