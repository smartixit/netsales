import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/widgets/charts/charting.dart';

void main() {
  group('ChartLiveDataSource', () {
    test('notifies independent chart bindings for the same source', () {
      final source = ChartLiveDataSource<int>(initialData: const [1, 2]);
      final firstUpdates = <ChartDataSourceUpdate>[];
      final secondUpdates = <ChartDataSourceUpdate>[];

      void firstHandler({
        List<int>? addedDataIndexes,
        List<int>? removedDataIndexes,
        List<int>? updatedDataIndexes,
        int addedDataIndex = -1,
        int removedDataIndex = -1,
        int updatedDataIndex = -1,
      }) {
        firstUpdates.add(
          ChartDataSourceUpdate(
            addedDataIndexes: addedDataIndexes,
            removedDataIndexes: removedDataIndexes,
            updatedDataIndexes: updatedDataIndexes,
            addedDataIndex: addedDataIndex < 0 ? null : addedDataIndex,
            removedDataIndex: removedDataIndex < 0 ? null : removedDataIndex,
            updatedDataIndex: updatedDataIndex < 0 ? null : updatedDataIndex,
          ),
        );
      }

      void secondHandler({
        List<int>? addedDataIndexes,
        List<int>? removedDataIndexes,
        List<int>? updatedDataIndexes,
        int addedDataIndex = -1,
        int removedDataIndex = -1,
        int updatedDataIndex = -1,
      }) {
        secondUpdates.add(
          ChartDataSourceUpdate(
            addedDataIndexes: addedDataIndexes,
            removedDataIndexes: removedDataIndexes,
            updatedDataIndexes: updatedDataIndexes,
            addedDataIndex: addedDataIndex < 0 ? null : addedDataIndex,
            removedDataIndex: removedDataIndex < 0 ? null : removedDataIndex,
            updatedDataIndex: updatedDataIndex < 0 ? null : updatedDataIndex,
          ),
        );
      }

      source.bindSyncfusion(firstHandler, bindingId: 'chart-a:series-a');
      source.bindSyncfusion(secondHandler, bindingId: 'chart-b:series-a');

      source.append(3);

      expect(source.data, [1, 2, 3]);
      expect(firstUpdates, hasLength(1));
      expect(secondUpdates, hasLength(1));
      expect(firstUpdates.single.addedDataIndex, 2);
      expect(secondUpdates.single.addedDataIndex, 2);

      source.unbind(bindingId: 'chart-a:series-a');
      source.append(4);

      expect(firstUpdates, hasLength(1));
      expect(secondUpdates, hasLength(2));
      expect(secondUpdates.last.addedDataIndex, 3);
      source.dispose();
    });

    test('bounds appended data and reports removed and added indexes', () {
      final source = ChartLiveDataSource<int>(
        initialData: const [1, 2, 3],
        maxDataPoints: 3,
      );
      final updates = <ChartDataSourceUpdate>[];
      source.bind(updates.add);

      source.append(4);

      expect(source.data, [2, 3, 4]);
      expect(updates.single.removedDataIndexes, [0]);
      expect(updates.single.addedDataIndex, 2);

      source.appendAll([5, 6, 7, 8]);

      expect(source.data, [6, 7, 8]);
      expect(updates.last.removedDataIndexes, [0, 1, 2]);
      expect(updates.last.addedDataIndexes, [0, 1, 2]);
      source.dispose();
    });

    test('supports point update, point removal, and full replacement', () {
      final source = ChartLiveDataSource<int>(initialData: const [1, 2, 3]);
      final updates = <ChartDataSourceUpdate>[];
      source.bind(updates.add);

      source.updateAt(1, 20);
      expect(updates.last.updatedDataIndex, 1);

      expect(source.removeAt(0), 1);
      expect(updates.last.removedDataIndex, 0);

      source.replaceAll([7, 8]);
      expect(source.data, [7, 8]);
      expect(updates.last.removedDataIndexes, [0, 1]);
      expect(updates.last.addedDataIndexes, [0, 1]);
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

    test('replaceAll safely accepts its own live data list', () {
      final source = ChartLiveDataSource<int>(initialData: const [1, 2, 3]);
      source.replaceAll(source.data);
      expect(source.snapshot, [1, 2, 3]);
      source.dispose();
    });

    test('replacing a stream cancels the previous subscription', () async {
      final source = ChartLiveDataSource<int>();
      final firstStream = StreamController<int>();
      final secondStream = StreamController<int>();

      await source.bindStream(firstStream.stream);
      firstStream.add(1);
      await Future<void>.delayed(Duration.zero);

      await source.bindStream(secondStream.stream);
      firstStream.add(2);
      secondStream.add(3);
      await Future<void>.delayed(Duration.zero);

      expect(source.data, [1, 3]);

      await source.stopStream();
      await firstStream.close();
      await secondStream.close();
      source.dispose();
    });

    test('rejects mutations after disposal', () {
      final source = ChartLiveDataSource<int>();
      source.dispose();

      expect(() => source.append(1), throwsStateError);
    });
  });
}
