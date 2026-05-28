import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

const _begin = '# >>> iconify_full';
const _end = '# <<< iconify_full';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('project', abbr: 'j', defaultsTo: '.');
  final args = parser.parse(arguments);

  final project = Directory(p.normalize(args['project'] as String));

  _patchPlatformCmake(File(p.join(project.path, 'windows', 'CMakeLists.txt')));
  _patchPlatformCmake(File(p.join(project.path, 'linux', 'CMakeLists.txt')));
  _stripRunnerHook(File(p.join(project.path, 'windows', 'runner', 'CMakeLists.txt')));
  _stripRunnerHook(File(p.join(project.path, 'linux', 'runner', 'CMakeLists.txt')));

  stdout.writeln('iconify_full: desktop hooks applied under ${project.path}');
  stdout.writeln('Subset runs before flutter_assemble (assets are bundled correctly).');
}

String get _subsetTargetBlock => r'''
set(ICONIFY_APP_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/..")
set(ICONIFY_CACHE_DIR "${ICONIFY_APP_ROOT}/../iconify_full/.iconify_cache")
if(NOT EXISTS "${ICONIFY_CACHE_DIR}")
  set(ICONIFY_CACHE_DIR "${ICONIFY_APP_ROOT}/../.iconify_cache")
endif()
if(NOT EXISTS "${ICONIFY_CACHE_DIR}")
  set(ICONIFY_CACHE_DIR "${ICONIFY_APP_ROOT}/.iconify_cache")
endif()
if(NOT TARGET iconify_subset)
  add_custom_target(iconify_subset
    COMMAND dart run iconify_full:iconify_subset
      --project "${ICONIFY_APP_ROOT}"
      --cache "${ICONIFY_CACHE_DIR}"
      --no-pubspec
    WORKING_DIRECTORY "${ICONIFY_APP_ROOT}"
    COMMENT "Subsetting Iconify SVG assets (iconify_full)"
    VERBATIM
  )
endif()
'''.trim();

const _assembleDep = 'add_dependencies(flutter_assemble iconify_subset)';

void _patchPlatformCmake(File file) {
  if (!file.existsSync()) {
    stdout.writeln('skip (missing): ${file.path}');
    return;
  }
  var content = file.readAsStringSync();

  // Upgrade: remove runner-only hooks from parent if present.
  if (content.contains(_begin)) {
    _stripBlock(file);
    content = file.readAsStringSync();
  }

  final projectLine = _findProjectLine(content);
  if (projectLine == null) {
    stdout.writeln('warn: no project() in ${file.path}');
    return;
  }

  if (!content.contains('add_custom_target(iconify_subset')) {
    _insertAfter(file, content, projectLine, _subsetTargetBlock);
    content = file.readAsStringSync();
  }

  // CMake variable — must be raw string (not Dart interpolation).
  const flutterSubdir = r'add_subdirectory(${FLUTTER_MANAGED_DIR})';
  if (content.contains(_assembleDep)) {
    stdout.writeln('already patched: ${file.path}');
    return;
  }
  if (content.contains(flutterSubdir)) {
    _insertAfter(file, content, flutterSubdir, _assembleDep);
  } else if (content.contains('add_subdirectory("flutter")')) {
    _insertAfter(file, content, 'add_subdirectory("flutter")', _assembleDep);
  } else {
    stdout.writeln('warn: flutter subdirectory anchor missing in ${file.path}');
  }
}

void _stripRunnerHook(File file) {
  if (!file.existsSync()) return;
  final content = file.readAsStringSync();
  if (content.contains(_begin)) {
    _stripBlock(file);
    stdout.writeln('removed runner hook (use parent CMake): ${file.path}');
  }
}

String? _findProjectLine(String content) {
  for (final line in content.split('\n')) {
    final t = line.trim();
    if (t.startsWith('project(') && t.contains('LANGUAGES')) {
      return line;
    }
  }
  return null;
}

void _stripBlock(File file) {
  var content = file.readAsStringSync();
  if (!content.contains(_begin)) return;
  final pattern = RegExp(
    r'# >>> iconify_full\r?\n.*?# <<< iconify_full\r?\n?',
    dotAll: true,
  );
  content = content.replaceAll(pattern, '');
  content = content.replaceAll(
    RegExp(r'\n*add_dependencies\(flutter_assemble iconify_subset\)\r?\n?'),
    '\n',
  );
  file.writeAsStringSync(content);
}

void _insertAfter(
  File file,
  String content,
  String after,
  String insert,
) {
  final idx = content.indexOf(after);
  if (idx == -1) return;
  final insertAt = idx + after.length;
  final block = insert == _assembleDep
      ? '\n# iconify_full: subset before asset bundle\n$insert\n'
      : '\n$_begin\n$insert\n$_end\n';
  final updated =
      content.substring(0, insertAt) + block + content.substring(insertAt);
  file.writeAsStringSync(updated);
  stdout.writeln('patched: ${file.path}');
}
