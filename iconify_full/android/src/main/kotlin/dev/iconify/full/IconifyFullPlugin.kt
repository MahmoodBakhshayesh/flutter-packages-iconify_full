package dev.iconify.full

import io.flutter.embedding.engine.plugins.FlutterPlugin

/** Build-hook plugin; subset runs via Gradle before Android builds. */
class IconifyFullPlugin : FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {}

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {}
}
