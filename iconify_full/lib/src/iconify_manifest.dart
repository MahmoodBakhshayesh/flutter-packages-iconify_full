/// Resolves a bundled asset path for an Iconify id, or `null` if not in the subset.
///
/// Typically the generated `iconifyAssetFor` from `iconify_manifest.g.dart`.
typedef IconifyAssetResolver = String? Function(String id);

IconifyAssetResolver _resolver = _defaultResolver;

/// Looks up the asset path for [id] using the registered [registerIconifyManifest].
String? iconifyAssetFor(String id) => _resolver(id);

/// Connects [iconifyAssetFor] to your generated manifest (call from `main()`).
void registerIconifyManifest(IconifyAssetResolver resolver) {
  _resolver = resolver;
}

String? _defaultResolver(String id) => null;
