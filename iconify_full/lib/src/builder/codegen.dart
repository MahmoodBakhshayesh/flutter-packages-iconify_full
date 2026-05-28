import 'dart:io';

import 'package:path/path.dart' as p;

import 'config.dart';
import 'icons_catalog_generator.dart';

/// Generates typed icon classes for every set in the offline cache.
Future<void> runIconifyCodegen({
  required Directory projectDir,
  Directory? cacheDir,
  String catalogDir = 'lib/generated/iconify_catalog',
  List<String>? onlyPrefixes,
  void Function(String message)? log,
}) async {
  void info(String msg) => log?.call(msg);

  final config = IconifyFullConfig.load(projectDir);
  final resolvedCache = cacheDir ?? config.resolveCacheDir(projectDir);
  final outDir = Directory(p.join(projectDir.path, catalogDir));

  info('Cache: ${resolvedCache.path}');
  info('Output: ${outDir.path}');

  final result = await generateIconifyCatalog(
    cacheDir: resolvedCache,
    outDir: outDir,
    onlyPrefixes: onlyPrefixes,
    log: info,
  );

  info('');
  info(
    'Generated ${result.iconCount} icons in ${result.setCount} sets.',
  );
  info('Import: import \'${catalogDir.replaceAll(r'\', '/')}/iconify_catalog.dart\';');
  info('Usage: const IconifyIcon.named(Mdi.home);');
  info('');
  info('Add lib/generated/iconify_catalog/ to .gitignore if the catalog is large.');
}
