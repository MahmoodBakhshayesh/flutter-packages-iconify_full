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

  _patchParentCmake(File(p.join(project.path, 'windows', 'CMakeLists.txt')));
  _patchParentCmake(File(p.join(project.path, 'linux', 'CMakeLists.txt')));
  _patchRunnerCmake(File(p.join(project.path, 'windows', 'runner', 'CMakeLists.txt')));
  _patchRunnerCmake(File(p.join(project.path, 'linux', 'runner', 'CMakeLists.txt')));

  stdout.writeln('iconify_full: desktop CMake hooks applied under ${project.path}');
  stdout.writeln('Android/iOS subset runs automatically via the iconify_full plugin.');
}

/// Top-level windows/linux CMakeLists — app root is one level up.
String get _parentHookBlock => r'''
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

/// runner/CMakeLists — app root is two levels up; defines target if parent did not.
String get _runnerHookBlock => r'''
set(ICONIFY_APP_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../..")
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
add_dependencies(${BINARY_NAME} iconify_subset)
'''.trim();

void _patchParentCmake(File file) {
  if (!file.existsSync()) {
    stdout.writeln('skip (missing): ${file.path}');
    return;
  }
  var content = file.readAsStringSync();
  if (content.contains(_begin)) {
    _stripOldBlock(file);
    content = file.readAsStringSync();
  }
  if (content.contains('add_custom_target(iconify_subset')) {
    stdout.writeln('already has iconify_subset target: ${file.path}');
    return;
  }
  final projectLine = _findProjectLine(content);
  if (projectLine == null) {
    stdout.writeln('warn: no project() line in ${file.path}');
    return;
  }
  _insertAfter(file, content, projectLine, _parentHookBlock);
}

void _patchRunnerCmake(File file) {
  if (!file.existsSync()) {
    stdout.writeln('skip (missing): ${file.path}');
    return;
  }
  var content = file.readAsStringSync();
  if (content.contains(_begin)) {
    // Upgrade old hooks that only had add_dependencies.
    if (!content.contains('add_custom_target(iconify_subset')) {
      stdout.writeln('upgrading runner hook: ${file.path}');
      _stripOldBlock(file);
      content = file.readAsStringSync();
    } else {
      stdout.writeln('already patched: ${file.path}');
      return;
    }
  }
  const anchor = r'apply_standard_settings(${BINARY_NAME})';
  if (!content.contains(anchor)) {
    stdout.writeln('warn: anchor not found in ${file.path}');
    return;
  }
  _insertAfter(file, content, anchor, _runnerHookBlock);
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

void _stripOldBlock(File file) {
  var content = file.readAsStringSync();
  if (!content.contains(_begin)) return;
  final pattern = RegExp(
    r'# >>> iconify_full\r?\n.*?# <<< iconify_full\r?\n?',
    dotAll: true,
  );
  file.writeAsStringSync(content.replaceAll(pattern, ''));
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
  final block = '\n$_begin\n$insert\n$_end\n';
  final updated =
      content.substring(0, insertAt) + block + content.substring(insertAt);
  file.writeAsStringSync(updated);
  stdout.writeln('patched: ${file.path}');
}
