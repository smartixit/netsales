import 'dart:async';

import 'package:flutter/foundation.dart';

/// Incremental change passed to a Syncfusion series controller.
@immutable
class ChartDataSourceUpdate {
  const ChartDataSourceUpdate({
    this.addedDataIndexes,
    this.removedDataIndexes,
    this.updatedDataIndexes,
    this.addedDataIndex,
    this.removedDataIndex,
    this.updatedDataIndex,
  });

  final List<int>? addedDataIndexes;
  final List<int>? removedDataIndexes;
  final List<int>? updatedDataIndexes;
  final int? addedDataIndex;
  final int? removedDataIndex;
  final int? updatedDataIndex;

  bool get isEmpty =>
      (addedDataIndexes?.isEmpty ?? true) &&
      (removedDataIndexes?.isEmpty ?? true) &&
      (updatedDataIndexes?.isEmpty ?? true) &&
      addedDataIndex == null &&
      removedDataIndex == null &&
      updatedDataIndex == null;
}

typedef ChartSeriesUpdateHandler = void Function(ChartDataSourceUpdate update);
typedef ChartSyncfusionUpdateCallback = void Function({
  List<int>? addedDataIndexes,
  List<int>? removedDataIndexes,
  List<int>? updatedDataIndexes,
  int? addedDataIndex,
  int? removedDataIndex,
  int? updatedDataIndex,
});

/// Mutable, bounded and stream-capable data source for real-time charts.
///
/// Cartesian, circular, funnel and pyramid renderers bind this source to the
/// matching Syncfusion series controller and call its documented
/// updateDataSource API. Spark charts listen to this source and rebuild their
/// compact renderer because the Spark chart controls do not expose the same
/// per-series controller contract.
class ChartLiveDataSource<T> extends ChangeNotifier {
  ChartLiveDataSource({
    Iterable<T> initialData = const <Never>[],
    this.maxDataPoints,
  }) : _data = List<T>.of(initialData) {
    if (maxDataPoints != null && maxDataPoints! < 1) {
      throw ArgumentError.value(maxDataPoints, 'maxDataPoints', 'Must be >= 1.');
    }
    _trimInitialData();
  }

  final List<T> _data;
  final int? maxDataPoints;
  ChartSeriesUpdateHandler? _updateHandler;
  StreamSubscription<T>? _subscription;
  bool _disposed = false;

  /// The mutable list bound to Syncfusion. Mutate it only through this class.
  List<T> get data => _data;

  int get length => _data.length;
  bool get isEmpty => _data.isEmpty;
  bool get isNotEmpty => _data.isNotEmpty;

  void bind(ChartSeriesUpdateHandler handler) {
    _ensureActive();
    _updateHandler = handler;
  }

  void unbind() {
    _updateHandler = null;
  }

  /// Convenience bridge for controller.updateDataSource(...).
  void bindSyncfusion(ChartSyncfusionUpdateCallback updateDataSource) {
    bind((change) {
      if (change.isEmpty) {
        return;
      }
      updateDataSource(
        addedDataIndexes: change.addedDataIndexes,
        removedDataIndexes: change.removedDataIndexes,
        updatedDataIndexes: change.updatedDataIndexes,
        addedDataIndex: change.addedDataIndex,
        removedDataIndex: change.removedDataIndex,
        updatedDataIndex: change.updatedDataIndex,
      );
    });
  }

  void append(T value) {
    _ensureActive();
    var removed = 0;
    if (maxDataPoints != null && _data.length >= maxDataPoints!) {
      removed = _data.length - maxDataPoints! + 1;
      _data.removeRange(0, removed);
    }
    _data.add(value);
    _notifyChange(
      ChartDataSourceUpdate(
        addedDataIndex: _data.length - 1,
        removedDataIndexes: removed == 0
            ? null
            : List<int>.generate(removed, (index) => index),
      ),
    );
  }

  void appendAll(Iterable<T> values) {
    _ensureActive();
    final incoming = List<T>.of(values);
    if (incoming.isEmpty) {
      return;
    }

    var removed = 0;
    if (maxDataPoints != null) {
      final overflow = _data.length + incoming.length - maxDataPoints!;
      if (overflow > 0) {
        removed = overflow.clamp(0, _data.length);
        if (removed > 0) {
          _data.removeRange(0, removed);
        }
      }
      if (incoming.length > maxDataPoints!) {
        incoming.removeRange(0, incoming.length - maxDataPoints!);
      }
    }

    final startIndex = _data.length;
    _data.addAll(incoming);
    _notifyChange(
      ChartDataSourceUpdate(
        addedDataIndexes: List<int>.generate(
          incoming.length,
          (index) => startIndex + index,
        ),
        removedDataIndexes: removed == 0
            ? null
            : List<int>.generate(removed, (index) => index),
      ),
    );
  }

  void updateAt(int index, T value) {
    _ensureActive();
    RangeError.checkValidIndex(index, _data, 'index');
    _data[index] = value;
    _notifyChange(ChartDataSourceUpdate(updatedDataIndex: index));
  }

  T removeAt(int index) {
    _ensureActive();
    RangeError.checkValidIndex(index, _data, 'index');
    final removed = _data.removeAt(index);
    _notifyChange(ChartDataSourceUpdate(removedDataIndex: index));
    return removed;
  }

  /// Replace all points. This notifies listeners and reports complete index
  /// ranges to Syncfusion so the renderer can refresh its internal data.
  void replaceAll(Iterable<T> values) {
    _ensureActive();
    final previousLength = _data.length;
    _data
      ..clear()
      ..addAll(values);
    _trimInitialData();
    final nextLength = _data.length;
    _notifyChange(
      ChartDataSourceUpdate(
        removedDataIndexes: previousLength == 0
            ? null
            : List<int>.generate(previousLength, (index) => index),
        addedDataIndexes: nextLength == 0
            ? null
            : List<int>.generate(nextLength, (index) => index),
      ),
    );
  }

  /// Connect a transport stream (WebSocket, SSE, polling stream, etc.).
  /// The host controller owns the transport and should cancel it by calling
  /// [stopStream] or disposing this source.
  Future<void> bindStream(
    Stream<T> stream, {
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function()? onDone,
  }) async {
    _ensureActive();
    await stopStream();
    _subscription = stream.listen(
      append,
      onError: onError,
      onDone: onDone,
      cancelOnError: false,
    );
  }

  Future<void> stopStream() async {
    final subscription = _subscription;
    _subscription = null;
    await subscription?.cancel();
  }

  void _notifyChange(ChartDataSourceUpdate update) {
    if (_disposed) {
      return;
    }
    _updateHandler?.call(update);
    notifyListeners();
  }

  void _trimInitialData() {
    if (maxDataPoints != null && _data.length > maxDataPoints!) {
      _data.removeRange(0, _data.length - maxDataPoints!);
    }
  }

  void _ensureActive() {
    if (_disposed) {
      throw StateError('ChartLiveDataSource has been disposed.');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _updateHandler = null;
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
  }
}
