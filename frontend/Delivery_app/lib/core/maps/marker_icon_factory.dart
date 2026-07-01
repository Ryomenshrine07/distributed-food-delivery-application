import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// The cache key for a rendered puck marker: the four dimensions that fully
/// determine the produced bitmap — glyph code point, packed ARGB color, logical
/// size, and device pixel ratio (Req 1.8).
typedef _PuckKey = (int codePoint, int argb, double sizeDp, double dpr);

/// An immutable description of a single puck-marker rendering request.
///
/// It carries exactly the fields that make up the cache key, so equal requests
/// always map to equal keys.
@immutable
class PuckRequest {
  const PuckRequest({
    required this.icon,
    required this.color,
    required this.sizeDp,
    required this.devicePixelRatio,
  });

  final IconData icon;
  final Color color;
  final double sizeDp;
  final double devicePixelRatio;
}

/// A seam for turning a [PuckRequest] into a [BitmapDescriptor].
///
/// The production path ([MarkerIconFactory._renderToBitmap]) paints real pixels
/// on a [Canvas]; tests inject a fake renderer so the caching/keying behaviour
/// (Correctness Property 6) can be verified deterministically without a live
/// GPU or headless-render support.
typedef PuckRenderer = Future<BitmapDescriptor> Function(PuckRequest request);

/// Renders and caches circular vehicle "puck" map markers.
///
/// A puck is a filled disc in the requested [Color] with a thin white ring and
/// a white vehicle glyph, painted at the device pixel ratio so it stays
/// density-correct (Req 1.6, 1.7). Results are cached by
/// `(icon, color, sizeDp, devicePixelRatio)` so an already-produced marker is
/// returned instead of being re-rendered (Req 1.8): the underlying painter runs
/// at most once per distinct key.
///
/// The byte-rendering step is isolated behind an injectable [PuckRenderer] so
/// the cache/keying logic is unit- and property-testable without executing the
/// real `Canvas`/`toImage` path (which needs a rendering surface).
class MarkerIconFactory {
  /// Creates a factory. Pass [renderer] in tests to observe/count invocations;
  /// production code uses the default [_renderToBitmap] painter.
  MarkerIconFactory({PuckRenderer? renderer}) : _renderer = renderer;

  final PuckRenderer? _renderer;

  /// Caches the in-flight/completed render Future per distinct key. Caching the
  /// Future (not just its value) means concurrent requests for the same key
  /// share a single render, so the painter runs at most once per key even under
  /// races.
  final Map<_PuckKey, Future<BitmapDescriptor>> _cache =
      <_PuckKey, Future<BitmapDescriptor>>{};

  /// Returns a circular vehicle puck tinted [color] with a white [icon] glyph.
  ///
  /// Cached by `(icon, color, sizeDp, devicePixelRatio)`; a repeated request for
  /// the same key returns the cached descriptor without re-rendering (Req 1.8).
  Future<BitmapDescriptor> vehiclePuck({
    required Color color,
    IconData icon = Icons.two_wheeler,
    double sizeDp = 44,
    required double devicePixelRatio,
  }) {
    final request = PuckRequest(
      icon: icon,
      color: color,
      sizeDp: sizeDp,
      devicePixelRatio: devicePixelRatio,
    );
    final key = _keyOf(request);
    // putIfAbsent guarantees the render function is invoked at most once per
    // distinct key while an entry is cached.
    return _cache.putIfAbsent(key, () => _render(request, key));
  }

  /// Clears every cached marker so the next request re-renders.
  void clearCache() => _cache.clear();

  _PuckKey _keyOf(PuckRequest r) =>
      (r.icon.codePoint, r.color.toARGB32(), r.sizeDp, r.devicePixelRatio);

  Future<BitmapDescriptor> _render(PuckRequest request, _PuckKey key) async {
    try {
      final render = _renderer ?? _renderToBitmap;
      return await render(request);
    } catch (_) {
      // A transient encode failure should not permanently pin the default
      // marker: drop the failed entry so a later frame can retry (Req 1.9).
      _cache.remove(key);
      rethrow;
    }
  }

  /// Production painter: draws the puck on a [Canvas] and encodes it to a PNG
  /// [BitmapDescriptor] at [PuckRequest.devicePixelRatio].
  static Future<BitmapDescriptor> _renderToBitmap(PuckRequest request) async {
    final double dpr = request.devicePixelRatio;
    final double sizePx = request.sizeDp * dpr;
    final double center = sizePx / 2;
    final double ringWidth = sizePx * 0.06;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Filled disc in the requested color (Req 1.7).
    final discPaint = Paint()
      ..color = request.color
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center, center), center - ringWidth, discPaint);

    // Thin white ring for contrast against the map.
    final ringPaint = Paint()
      ..color = Colors.white
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth;
    canvas.drawCircle(
      Offset(center, center),
      center - ringWidth / 2,
      ringPaint,
    );

    // White vehicle glyph drawn from the MaterialIcons font via TextPainter.
    final glyph = String.fromCharCode(request.icon.codePoint);
    final painter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: glyph,
        style: TextStyle(
          fontSize: sizePx * 0.55,
          fontFamily: request.icon.fontFamily ?? 'MaterialIcons',
          package: request.icon.fontPackage,
          color: Colors.white,
        ),
      )
      ..layout();
    painter.paint(
      canvas,
      Offset(center - painter.width / 2, center - painter.height / 2),
    );

    final picture = recorder.endRecording();
    final int side = sizePx.ceil();
    final image = await picture.toImage(side, side);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();
    if (byteData == null) {
      throw StateError('Failed to encode rider marker bitmap.');
    }
    return BitmapDescriptor.bytes(
      byteData.buffer.asUint8List(),
      imagePixelRatio: dpr,
    );
  }
}

/// Builds the shared rider marker for the tracking/navigation maps.
///
/// While [puck] is null (not yet rendered, or a render failed) the [fallback]
/// default descriptor is used so the rider position is never blank (Req 1.3);
/// once [puck] is ready it replaces the default (Req 1.4). Rotation always uses
/// the live [bearing] and the anchor stays centered at (0.5, 0.5), preserving
/// the existing MarkerAnimator behaviour (Req 1.5, Req 11.4).
Marker buildRiderMarker({
  required LatLng position,
  required double bearing,
  required BitmapDescriptor fallback,
  BitmapDescriptor? puck,
  String infoWindowTitle = 'Rider',
}) {
  return Marker(
    markerId: const MarkerId('rider'),
    position: position,
    rotation: bearing,
    icon: puck ?? fallback,
    infoWindow: InfoWindow(title: infoWindowTitle),
    anchor: const Offset(0.5, 0.5),
  );
}
