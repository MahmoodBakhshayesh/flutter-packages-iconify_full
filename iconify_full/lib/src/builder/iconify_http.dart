import 'package:http/http.dart' as http;

/// Iconify icon-sets on GitHub (same source as [runIconifyDownload]).
const String iconifyCollectionsUrl =
    'https://raw.githubusercontent.com/iconify/icon-sets/master/collections.json';

/// Base URL for per-set JSON: `$iconifyJsonBaseUrl/{prefix}.json`.
const String iconifyJsonBaseUrl =
    'https://raw.githubusercontent.com/iconify/icon-sets/master/json';

const int iconifyHttpMaxAttempts = 5;
const Duration iconifyHttpRetryDelay = Duration(seconds: 3);

/// GET with retries (used by download CLI and [FastCachedIconify]).
Future<http.Response> iconifyHttpGet(Uri url) async {
  Object? lastError;
  for (var attempt = 1; attempt <= iconifyHttpMaxAttempts; attempt++) {
    try {
      final response =
          await http.get(url).timeout(const Duration(minutes: 2));
      if (response.statusCode == 200) return response;
      lastError = Exception('HTTP ${response.statusCode} for $url');
    } on Exception catch (e) {
      lastError = e;
    }
    if (attempt < iconifyHttpMaxAttempts) {
      await Future<void>.delayed(iconifyHttpRetryDelay * attempt);
    }
  }
  throw lastError ?? StateError('Failed to GET $url');
}
