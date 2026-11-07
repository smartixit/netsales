import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/widgets/charts/charting.dart';

void main() {
  group('ChartLiveDataSource', () {
    test('notifies multiple independent chart bindings', () {
      final source = ChartLiveDataSource<int>(initialData: const [1, 2]);
      final first = <ChartDataSourceUpdate>[];
      final second = <ChartDataSourceUpdate>[];

      source.bindSyncfusion(
        ({
          addedDataIndexes,
          removedDataIndexes,
          updatedDataIndexes,
          addedDataIndex = -1,
          removedDataIndex = -1,
          updatedDataIndex = -1,
        }) {
          first.add(
            ChartDataSourceUpdate(
              addedDataIndexes: addedDataIndexes,
              removedDataIndexes: removedDataIndexes,
              updatedDataIndexes: updatedDataIndexes,
              addedDataIndex: addedDataIndex < 0 ? null : addedDataIndex,
              removedDataIndex: removedDataIndex < 0 ? null : removedDataIndex,
              updatedDataIndex: updatedDataIndex < 0 ? null : updatedDataIndex,
            ),
          );
        },
        bindingId: 'chart-a:series-a',
      );
      source.bindSyncfusion(
        ({
          addedDataIndexes,
          removedDataIndexes,
          updatedDataIndexes,
          addedDataIndex = -1,
          removedDataIndex = -1,
          updatedDataIndex = -1,
        }) {
          second.add(
            ChartDataSourceUpdate(
              addedDataIndexes: addedDataIndexes,
              removedDataIndexes: removedDataIndexes,
              updatedDataIndexes: updatedDataIndexes,
              addedDataIndex: addedDataIndex < 0 ? null : addedDataIndex,
              removedDataIndex: removedDataIndex < 0 ? null : removedDataIndex,
              updatedDataIndex: updatedDataIndex < 0 ? null : updatedDataIndex,
            ),
          );
        },
        bindingId: 'chart-b:series-a',
      );

      source.append(3);

      expect(source.data, [1, 2, 3]);
      expect(first, hasLength(1));
      expect(second, hasLength(1));
      expect(first.single.addedDataIndex, 2);
      expect(second.single.addedDataIndex, 2);

      source.unbind(bindingId: 'chart-a:series-a');
      source.append(4);

      expect(first, hasLength(1));
      expect(second, hasLength(2));
      expect(second.last.addedDataIndex, 3);
      source.dispose();
    });

    test('bounds appended data and reports removed and added indexes', () {
      final source = ChartLiveDataSource<int>(
        initialData: const [1, 2, 3],
        maxDataPoints: 3,
      );
      final changes = <ChartDataSourceUpdate>[];
      source.bind(changes.add);

      source.append(4);

      expect(source.data, [2, 3, 4]);
      expect(changes.single.removedDataIndexes, [0]);
      expect(changes.single.addedDataIndex, 2);

      source.appendAll([5, 6, 7, 8]);

      expect(source.data, [6, 7, 8]);
      expect(changes.last.removedDataIndexes, [0, 1, 2]);
      expect(changes.last.addedDataIndexes, [0, 1, 2]);
      source.dispose();
    });

    test('replaceAll respects the maximum and exposes immutable snapshots', () {
      final source = ChartLiveDataSource<int>(maxDataPoints: 2);

      source.replaceAll([1, 2, 3]);

      expect(source.data, [2, 3]);
      expect(source.snapshot, [2, 3]);
      expect(() => source.snapshot.add(4), throwsUnsupportedError);
      source.dispose();
    });

    test('replacing a stream cancels the previous subscription', () async {
      final source = ChartLiveDataSource<int>();
      final first = StreamController<int>();
      final second = StreamController<int>();

      await source.bindStream(first.stream);
      first.add(1);
      await Future<void>.delayed(Duration.zero);

      await source.bindStream(second.stream);
      first.add(2);
      second.add(3);
      await Future<void>.delayed(Duration.zero);

      expect(source.data, [1, 3]);

      await source.stopStream();
      await first.close();
      await second.close();
      source.dispose();
    });

    test('rejects mutations after disposal', () {
      final source = ChartLiveDataSource<int>();
      source.dispose();

      expect(() => source.append(1), throwsStateError);
    });
  });
}
