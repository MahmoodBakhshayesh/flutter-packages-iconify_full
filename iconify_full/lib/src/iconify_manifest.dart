/// Resolves bundled asset paths for Iconify ids.
///
/// Apps generate `lib/generated/iconify_manifest.g.dart` via
/// `dart run iconify_full:iconify_subset` and pass [iconifyAssetFor]
/// here with [registerIconifyManifest].
typedef IconifyAssetResolver = String? Function(String id);

IconifyAssetResolver _resolver = _defaultResolver;

/// Default resolver — override via [registerIconifyManifest].
String? iconifyAssetFor(String id) => _resolver(id);

/// Registers the generated `iconifyAssetFor` from the app manifest.
void registerIconifyManifest(IconifyAssetResolver resolver) {
  _resolver = resolver;
}

String? _defaultResolver(String id) => null;
