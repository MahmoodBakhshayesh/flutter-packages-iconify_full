import 'package:flutter/material.dart';

import '../iconify_icon_ref.dart';
import '../iconify_picture_cache.dart';
import '../iconify_theme.dart';
import 'iconify_fast_cache_service.dart';

/// Reason [FastCachedIconify] may show [errorWidget] (for custom error handling).
enum FastCachedIconifyError {
  /// Id is not `prefix:name`.
  invalidId,

  /// Network or parse failure while fetching the set/icon.
  downloadFailed,

  /// Set loaded but icon name does not exist.
  notFound,
}

/// Iconify icon that **downloads on first use** and reuses a local + memory cache.
///
/// Pass [placeholder] while loading and [errorWidget] when the id is invalid or
/// the icon could not be loaded (similar to `CachedNetworkImage`).
class FastCachedIconify extends StatefulWidget {
  FastCachedIconify(
    String id, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.fit,
    this.alignment,
    this.cachePath,
    this.placeholder,
    this.errorWidget,
  })  : rawId = id.trim(),
        ref = IconifyIconRef.tryParse(id);

  const FastCachedIconify.named(
    this.ref, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.fit,
    this.alignment,
    this.cachePath,
    this.placeholder,
    this.errorWidget,
  }) : rawId = null;

  /// Original id string (for invalid ids).
  final String? rawId;

  /// Parsed ref, or null if the id string was invalid.
  final IconifyIconRef? ref;

  final double? size;
  final Color? color;
  final String? semanticLabel;
  final BoxFit? fit;
  final AlignmentGeometry? alignment;

  /// Optional disk cache root (otherwise app support dir / memory-only on web).
  final String? cachePath;

  /// Shown while the icon is downloading (first load).
  final Widget? placeholder;

  /// Shown for invalid id, network error, or unknown icon name.
  final Widget? errorWidget;

  bool get hasValidId => ref != null;

  String get iconId => ref?.id ?? rawId ?? '';

  /// One-time setup; safe to call multiple times.
  static Future<void> ensureInitialized({String? cachePath}) =>
      IconifyFastCacheService.instance.ensureInitialized(cachePath: cachePath);

  @override
  State<FastCachedIconify> createState() => _FastCachedIconifyState();
}

class _FastCachedIconifyState extends State<FastCachedIconify> {
  bool _loading = false;
  String? _svg;
  Object? _loadError;
  FastCachedIconifyError? _invalidReason;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _hydrateFromMemoryCache();
    if (!_hasRenderableSvg && _invalidReason == null) {
      _startLoad();
    }
  }

  @override
  void didUpdateWidget(FastCachedIconify oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.iconId != widget.iconId ||
        oldWidget.cachePath != widget.cachePath) {
      _hydrateFromMemoryCache();
      if (!_hasRenderableSvg && _invalidReason == null) {
        _startLoad();
      }
    }
  }

  bool get _hasRenderableSvg => _svg != null && _svg!.isNotEmpty;

  void _hydrateFromMemoryCache() {
    if (!widget.hasValidId) {
      _invalidReason = FastCachedIconifyError.invalidId;
      _loading = false;
      _svg = null;
      _loadError = null;
      return;
    }

    _invalidReason = null;
    _loadError = null;
    final cached = IconifyFastCacheService.instance.peekSvg(widget.iconId);
    if (cached != null) {
      _svg = cached;
      _loading = false;
      return;
    }

    _svg = null;
    _loading = true;
  }

  void _startLoad() {
    if (!widget.hasValidId) return;

    final cached = IconifyFastCacheService.instance.peekSvg(widget.iconId);
    if (cached != null) {
      if (!_hasRenderableSvg || _svg != cached) {
        setState(() {
          _svg = cached;
          _loading = false;
          _loadError = null;
        });
      }
      return;
    }

    final generation = ++_loadGeneration;
    if (!_loading) {
      setState(() => _loading = true);
    }

    final service = IconifyFastCacheService.instance;
    () async {
      try {
        await service.ensureInitialized(cachePath: widget.cachePath);
        final svg = await service.loadSvg(widget.iconId);
        if (!mounted || generation != _loadGeneration) return;
        setState(() {
          _loading = false;
          _svg = svg;
          _loadError = null;
        });
      } on Object catch (error) {
        if (!mounted || generation != _loadGeneration) return;
        setState(() {
          _loading = false;
          _svg = null;
          _loadError = error;
        });
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    final inherited = IconifyTheme.maybeOf(context);
    final resolved = IconifyThemeData(
      color: widget.color ?? inherited?.color,
      size: widget.size ?? inherited?.size ?? 24,
      semanticLabel: widget.semanticLabel ?? inherited?.semanticLabel,
      fit: widget.fit ?? inherited?.fit ?? BoxFit.contain,
      alignment: widget.alignment ?? inherited?.alignment ?? Alignment.center,
    );

    if (_invalidReason == FastCachedIconifyError.invalidId) {
      return _slot(
        widget.errorWidget ?? _defaultError(context, resolved),
        resolved.size,
      );
    }

    if (_loading && !_hasRenderableSvg) {
      return _slot(
        widget.placeholder ?? _defaultPlaceholder(resolved.size),
        resolved.size,
      );
    }

    if (_loadError != null) {
      return _slot(
        widget.errorWidget ??
            _defaultError(context, resolved, _loadError),
        resolved.size,
      );
    }

    final svg = _svg;
    if (svg == null || svg.isEmpty) {
      return _slot(
        widget.errorWidget ?? _defaultError(context, resolved),
        resolved.size,
      );
    }

    final tint = _resolveTint(resolved, context);
    return RepaintBoundary(
      child: IconifyPictureCache.instance.string(
        svg: svg,
        sourceId: widget.iconId,
        width: resolved.size,
        height: resolved.size,
        tint: tint,
        fit: resolved.fit,
        alignment: resolved.alignment,
        semanticsLabel: resolved.semanticLabel,
      ),
    );
  }

  Widget _slot(Widget child, double? size) {
    if (size == null) return child;
    return SizedBox(
      width: size,
      height: size,
      child: Center(child: child),
    );
  }

  Widget _defaultPlaceholder(double? size) {
    final side = size ?? 24;
    return SizedBox(
      width: side,
      height: side,
      child: Center(
        child: SizedBox(
          width: side * 0.65,
          height: side * 0.65,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _defaultError(
    BuildContext context,
    IconifyThemeData resolved, [
    Object? error,
  ]) {
    return Semantics(
      label: resolved.semanticLabel ?? 'Icon failed to load',
      child: Icon(
        Icons.broken_image_outlined,
        size: resolved.size * 0.75,
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Color? _resolveTint(IconifyThemeData resolved, BuildContext context) {
    return resolved.color ??
        IconTheme.of(context).color ??
        DefaultTextStyle.of(context).style.color;
  }
}
