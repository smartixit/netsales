import 'package:flutter/foundation.dart';

/// Imperative controls for a mounted Cartesian chart.
class ChartController {
  Object? _owner;
  VoidCallback? _reset;
  VoidCallback? _zoomIn;
  VoidCallback? _zoomOut;
  void Function(String direction)? _pan;

  bool get isAttached => _owner != null;

  void resetZoom() => _reset?.call();
  void zoomIn() => _zoomIn?.call();
  void zoomOut() => _zoomOut?.call();
  void panLeft() => _pan?.call('left');
  void panRight() => _pan?.call('right');
  void panUp() => _pan?.call('top');
  void panDown() => _pan?.call('bottom');

  void attach({
    required Object owner,
    required VoidCallback reset,
    required VoidCallback zoomIn,
    required VoidCallback zoomOut,
    required void Function(String direction) pan,
  }) {
    _owner = owner;
    _reset = reset;
    _zoomIn = zoomIn;
    _zoomOut = zoomOut;
    _pan = pan;
  }

  void detach(Object owner) {
    if (!identical(_owner, owner)) return;
    _owner = null;
    _reset = null;
    _zoomIn = null;
    _zoomOut = null;
    _pan = null;
  }
}
