import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'iconify_full_plugin.dart';

/// Web plugin registration for [iconify_full].
class IconifyFullPluginWeb {
  /// Called by the Flutter tool when the plugin is registered on web.
  static void registerWith(Registrar registrar) {
    IconifyFullPlugin.registerWith();
  }
}
