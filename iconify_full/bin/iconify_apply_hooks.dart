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

  // Uses dart run so it works with path or pub.dev dependencies.
  final cmakeInclude = r'''
set(ICONIFY_APP_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/..")
set(ICONIFY_CACHE_DIR "${ICONIFY_APP_ROOT}/../.iconify_cache")
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
  _patchFile(
    File(p.join(project.path, 'windows', 'CMakeLists.txt')),
    after: 'project(example LANGUAGES CXX)',
    insert: cmakeInclude,
  );
  _patchFile(
    File(p.join(project.path, 'linux', 'CMakeLists.txt')),
    after: 'project(runner LANGUAGES CXX)',
    insert: cmakeInclude,
  );
  _patchFile(
    File(p.join(project.path, 'windows', 'runner', 'CMakeLists.txt')),
    after: r'apply_standard_settings(${BINARY_NAME})',
    insert: r'add_dependencies(${BINARY_NAME} iconify_subset)',
  );
  _patchFile(
    File(p.join(project.path, 'linux', 'runner', 'CMakeLists.txt')),
    after: r'apply_standard_settings(${BINARY_NAME})',
    insert: r'add_dependencies(${BINARY_NAME} iconify_subset)',
  );

  stdout.writeln('iconify_full: desktop CMake hooks applied under ${project.path}');
  stdout.writeln('Android/iOS subset runs automatically via the iconify_full plugin.');
}

void _patchFile(File file, {required String after, required String insert}) {
  if (!file.existsSync()) {
    stdout.writeln('skip (missing): ${file.path}');
    return;
  }
  var content = file.readAsStringSync();
  if (content.contains(_begin)) {
    stdout.writeln('already patched: ${file.path}');
    return;
  }
  final idx = content.indexOf(after);
  if (idx == -1) {
    stdout.writeln('warn: anchor not found in ${file.path}');
    return;
  }
  final insertAt = idx + after.length;
  final block = '\n$_begin\n$insert\n$_end\n';
  content = content.substring(0, insertAt) + block + content.substring(insertAt);
  file.writeAsStringSync(content);
  stdout.writeln('patched: ${file.path}');
}
