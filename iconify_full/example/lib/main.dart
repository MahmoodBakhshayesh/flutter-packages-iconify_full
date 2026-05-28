import 'package:example/generated/iconify_catalog/iconify_catalog.dart';
import 'package:example/generated/iconify_icons.g.dart';
import 'package:flutter/material.dart';
import 'package:iconify_full/iconify_full.dart';

import 'generated/iconify_manifest.g.dart' as manifest;

void main() {
  setupIconifyFull(
    manifest: manifest.iconifyAssetFor,
    // Debug: load SVGs from cache when not yet subset into assets.
    debugCachePath: '../../.iconify_cache',
  );
  runApp(const IconifyExampleApp());
}

class IconifyExampleApp extends StatefulWidget {
  const IconifyExampleApp({super.key});

  @override
  State<IconifyExampleApp> createState() => _IconifyExampleAppState();
}

class _IconifyExampleAppState extends State<IconifyExampleApp> {
  ThemeMode _mode = ThemeMode.light;
  Color _accent = Colors.deepPurple;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iconify Flutter',
      themeMode: _mode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _accent),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _accent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Iconify + themed SVG'),
              actions: [
                IconButton(
                  tooltip: 'Toggle theme',
                  onPressed: () {
                    setState(() {
                      _mode = _mode == ThemeMode.light
                          ? ThemeMode.dark
                          : ThemeMode.light;
                    });
                  },
                  icon: Icon(
                    _mode == ThemeMode.light
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                ),
              ],
            ),
            body: IconifyTheme(
              data: IconifyThemeData(
                color: Theme.of(context).colorScheme.primary,
                size: 40,
              ),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text(
                    'Debug: icons load from .iconify_cache without re-running subset. '
                    'Release builds bundle only subset assets.',
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [



                      IconifyIcon("solar:accumulator-bold"),
                      IconifyIcon.named(Solar.accumulator_bold,color: Colors.red,),
                      _labeled('mdi:home', IconifyIcon('mdi:home')),
                      _labeled(
                        'mdi:heart',
                        IconifyIcon('mdi:heart', color: Colors.red),
                      ),
                      _labeled(
                        'tabler:brand-flutter',
                        IconifyIcon('tabler:brand-flutter'),
                      ),
                      _labeled(
                        'solar:star-bold',
                        IconifyIcon('solar:star-bold', size: 56),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text('Accent', style: Theme.of(context).textTheme.titleMedium),
                  Slider(
                    value: HSVColor.fromColor(_accent).hue,
                    max: 360,
                    onChanged: (v) => setState(() {
                      _accent = HSVColor.fromAHSV(1, v, 0.7, 0.9).toColor();
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _labeled(String id, Widget icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(height: 8),
        Text(id, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
