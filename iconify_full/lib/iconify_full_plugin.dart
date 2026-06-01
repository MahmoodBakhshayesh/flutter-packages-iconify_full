/// Dart plugin registration for Linux, macOS, and Windows.
///
/// Native Android/iOS hooks live in platform folders; desktop subsetting uses
/// the app's CMake hooks (`iconify_apply_hooks`).
class IconifyFullPlugin {
  /// Called by the Flutter tool when the plugin is registered.
  static void registerWith() {}
}
