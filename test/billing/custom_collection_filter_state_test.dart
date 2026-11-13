import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/widgets/lists/custom_collection_filter_state.dart';

void main() {
  group('CustomCollectionFilterState', () {
    late CustomCollectionFilterState state;

    setUp(() {
      state = CustomCollectionFilterState(
        statusValues: const ['ACTIVE', 'PAST_DUE'],
      );
    });

    tearDown(() {
      state.dispose();
    });

    test('trims search text and builds server query parameters', () {
      state.onSearchChanged('  invoice-102  ', () async {});

      expect(state.search, 'invoice-102');
      expect(state.queryParameters, {'search': 'invoice-102'});
    });

    test('combines search and status without losing either criterion', () async {
      state.onSearchChanged(' plan-pro ', () async {});
      await state.onStatusChanged('ACTIVE', () async {});

      expect(
        state.queryParameters,
        {'search': 'plan-pro', 'status': 'ACTIVE'},
      );
    });

    test('empty status clears status while preserving search', () async {
      state.onSearchChanged('customer-7', () async {});
      await state.onStatusChanged('PAST_DUE', () async {});
      await state.onStatusChanged('', () async {});

      expect(state.queryParameters, {'search': 'customer-7'});
    });

    test('reset clears text and status filters and cancels debounce', () {
      var reloadCount = 0;
      state.onSearchChanged('invoice', () async {
        reloadCount++;
      });
      state.selectedStatus.value = 'ACTIVE';

      state.reset();

      expect(state.searchController.text, isEmpty);
      expect(state.queryParameters, isEmpty);
      expect(reloadCount, 0);
    });
  });
}
