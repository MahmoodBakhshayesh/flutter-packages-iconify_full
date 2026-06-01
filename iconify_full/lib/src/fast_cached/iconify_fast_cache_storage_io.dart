import 'dart:io';

import 'package:path/path.dart' as p;

Future<String?> readSvg(String? root, String prefix, String name) async {
  if (root == null) return null;
  final file = File(p.join(root, 'svg', prefix, '$name.svg'));
  if (!file.existsSync()) return null;
  return file.readAsString();
}

Future<void> writeSvg(
  String? root,
  String prefix,
  String name,
  String svg,
) async {
  if (root == null) return;
  final file = File(p.join(root, 'svg', prefix, '$name.svg'));
  await file.parent.create(recursive: true);
  await file.writeAsString(svg);
}

Future<String?> readJson(String? root, String prefix) async {
  if (root == null) return null;
  final file = File(p.join(root, 'json', '$prefix.json'));
  if (!file.existsSync()) return null;
  return file.readAsString();
}

Future<void> writeJson(String? root, String prefix, String body) async {
  if (root == null) return;
  final file = File(p.join(root, 'json', '$prefix.json'));
  await file.parent.create(recursive: true);
  await file.writeAsString(body);
}

Future<String?> readCollections(String? root) async {
  if (root == null) return null;
  final file = File(p.join(root, 'collections.json'));
  if (!file.existsSync()) return null;
  return file.readAsString();
}

Future<void> writeCollections(String? root, String body) async {
  if (root == null) return;
  final file = File(p.join(root, 'collections.json'));
  await file.parent.create(recursive: true);
  await file.writeAsString(body);
}
