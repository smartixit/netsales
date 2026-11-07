import 'dart:async';

import 'package:flutter/foundation.dart';

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
  int addedDataIndex,
  int removedDataIndex,
  int updatedDataIndex,
});

/// Mutable, bounded source for multiple live Syncfusion charts.
///
/// Each renderer must bind with its own unique bindingId and detach only that
/// binding. The source remains owned by the host feature/controller.
class ChartLiveDataSource<T> extends ChangeNotifier {
  ChartLiveDataSource({
    Iterable<T> initialData = const <Never>[],
    this.maxDataPoints,
  }) : _data = List<T>.of(initialData) {
    if (maxDataPoints != null && maxDataPoints! < 1) {
      throw ArgumentError.value(
        maxDataPoints,
        'maxDataPoints',
        'Must be >= 1.',
      );
    }
    _trimInitialData();
  }

  final List<T> _data;
  final int? maxDataPoints;
  final Map<String, ChartSeriesUpdateHandler> _syncfusionBindings =
      <String, ChartSeriesUpdateHandler>{};
  ChartSeriesUpdateHandler? _defaultUpdateHandler;
  StreamSubscription<T>? _subscription;
  bool _disposed = false;

  /// Exact mutable list instance bound to Syncfusion; mutate through this class.
  List<T> get data => _data;

  /// Immutable snapshot for consumers that do not own a chart binding.
  List<T> get snapshot => List<T>.unmodifiable(_data);

  int get length => _data.length;
  bool get isEmpty => _data.isEmpty;
  bool get isNotEmpty => _data.isNotEmpty;
  bool get hasActiveStream => _subscription != null;

  /// Compatibility binding for one non-Syncfusion consumer.
  void bind(ChartSeriesUpdateHandler handler) {
    _ensureActive();
    _defaultUpdateHandler = handler;
  }

  /// Detaches one renderer. Without an id, all bindings are cleared.
  void unbind({String? bindingId}) {
    if (bindingId == null) {
      _syncfusionBindings.clear();
      _defaultUpdateHandler = null;
    } else {
      _syncfusionBindings.remove(bindingId);
    }
  }

  /// Binds a Syncfusion series controller without replacing other charts.
  void bindSyncfusion(
    ChartSyncfusionUpdateCallback updateDataSource, {
    String bindingId = 'default',
  }) {
    _ensureActive();
    _syncfusionBindings[bindingId] = (change) {
      if (change.isEmpty) {
        return;
      }
      updateDataSource(
        addedDataIndexes: change.addedDataIndexes,
        removedDataIndexes: change.removedDataIndexes,
        updatedDataIndexes: change.updatedDataIndexes,
        addedDataIndex: change.addedDataIndex ?? -1,
        removedDataIndex: change.removedDataIndex ?? -1,
        updatedDataIndex: change.updatedDataIndex ?? -1,
      );
    };
  }

  void append(T value) {
    _ensureActive();
    var removedCount = 0;
    if (maxDataPoints != null && _data.length >= maxDataPoints!) {
      removedCount = _data.length - maxDataPoints! + 1;
      _data.removeRange(0, removedCount);
    }
    _data.add(value);
    _notifyChange(
      ChartDataSourceUpdate(
        addedDataIndex: _data.length - 1,
        removedDataIndexes: removedCount == 0
            ? null
            : List<int>.generate(removedCount, (index) => index),
      ),
    );
  }

  void appendAll(Iterable<T> values) {
    _ensureActive();
    final incoming = List<T>.of(values);
    if (incoming.isEmpty) {
      return;
    }

    var removedCount = 0;
    if (maxDataPoints != null) {
      final overflow = _data.length + incoming.length - maxDataPoints!;
      if (overflow > 0) {
        removedCount = overflow.clamp(0, _data.length).toInt();
        if (removedCount > 0) {
          _data.removeRange(0, removedCount);
        }
      }
      if (incoming.length > maxDataPoints!) {
        incoming.removeRange(0, incoming.length - maxDataPoints!);
      }
    }

    final firstAddedIndex = _data.length;
    _data.addAll(incoming);
    _notifyChange(
      ChartDataSourceUpdate(
        addedDataIndexes: List<int>.generate(
          incoming.length,
          (index) => firstAddedIndex + index,
        ),
        removedDataIndexes: removedCount == 0
            ? null
            : List<int>.generate(removedCount, (index) => index),
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

  /// Replaces all points and reports the affected indexes.
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

  /// Connects a WebSocket, SSE, polling, or other transport stream.
  /// Rebinding cancels the previous subscription before listening to the new one.
  Future<void> bindStream(
    Stream<T> stream, {
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function()? onDone,
  }) async {
    _ensureActive();
    await stopStream();
    _ensureActive();
    _subscription = stream.listen(
      append,
      onError: onError,
      onDone: () {
        _subscription = null;
        onDone?.call();
      },
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
    final handlers = List<ChartSeriesUpdateHandler>.of(
      _syncfusionBindings.values,
    );
    for (final handler in handlers) {
      handler(update);
    }
    _defaultUpdateHandler?.call(update);
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
    _syncfusionBindings.clear();
    _defaultUpdateHandler = null;
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
  }
}
