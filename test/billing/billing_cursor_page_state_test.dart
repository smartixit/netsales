import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_cursor_page_state.dart';

void main() {
  group('BillingCursorPageState', () {
    test('replaces the first page and extracts the next cursor', () {
      final state = BillingCursorPageState(identityKey: 'invoice_id');

      state.replace({
        'data': [
          {'invoice_id': 1},
          {'invoice_id': 2},
        ],
        'links': {
          'next': 'https://api.example.test/invoices?cursor=cursor-one',
        },
      });

      expect(state.items.map((row) => row['invoice_id']), [1, 2]);
      expect(state.nextCursor, 'cursor-one');
      expect(state.hasMore, isTrue);
    });

    test('tracks first-page errors without discarding the prior rows', () {
      final state = BillingCursorPageState(identityKey: 'invoice_id');
      state.replace({
        'data': [
          {'invoice_id': 11},
        ],
        'links': {'next': '/invoices?cursor=cursor-old'},
      });

      final revision = state.beginRefresh();
      state.failFirstPage('تعذر التحديث', revision: revision);

      expect(state.items.single['invoice_id'], 11);
      expect(state.nextCursor, 'cursor-old');
      expect(state.hasMore, isTrue);
      expect(state.isLoadingFirstPage.value, isFalse);
      expect(state.firstPageError.value, 'تعذر التحديث');
    });

    test('clears first-page errors after a successful replacement', () {
      final state = BillingCursorPageState(identityKey: 'invoice_id');
      final revision = state.beginRefresh();
      state.failFirstPage('تعذر التحديث', revision: revision);

      state.replace({
        'data': [
          {'invoice_id': 12},
        ],
      });

      expect(state.items.single['invoice_id'], 12);
      expect(state.firstPageError.value, isNull);
      expect(state.isLoadingFirstPage.value, isFalse);
    });

    test('preserves the current cursor and rows when a refresh starts', () {
      final state = BillingCursorPageState(identityKey: 'invoice_id');
      state.replace({
        'data': [
          {'invoice_id': 1},
        ],
        'links': {'next': '/invoices?cursor=cursor-one'},
      });

      final revision = state.beginRefresh(clearItems: false);

      expect(state.items.single['invoice_id'], 1);
      expect(state.nextCursor, 'cursor-one');
      expect(state.hasMore, isTrue);
      expect(state.revision, revision);
      expect(state.isLoadingMore.value, isFalse);
    });

    test('appends unique rows and advances the cursor', () {
      final state = BillingCursorPageState(identityKey: 'invoice_id');
      state.replace({
        'data': [
          {'invoice_id': 1},
          {'invoice_id': 2},
        ],
        'links': {'next': '/invoices?cursor=cursor-one'},
      });
      final revision = state.revision;

      state.append(
        {
          'data': [
            {'invoice_id': 2},
            {'invoice_id': 3},
          ],
          'links': {'next': '/invoices?cursor=cursor-two'},
        },
        revision: revision,
        requestedCursor: 'cursor-one',
      );

      expect(state.items.map((row) => row['invoice_id']), [1, 2, 3]);
      expect(state.nextCursor, 'cursor-two');
      expect(state.loadMoreError.value, isNull);
    });

    test('rejects repeated cursors without appending a duplicate page', () {
      final state = BillingCursorPageState(identityKey: 'invoice_id');
      state.replace({
        'data': [
          {'invoice_id': 1},
        ],
        'links': {'next': '/invoices?cursor=cursor-one'},
      });
      final revision = state.revision;

      expect(
        () => state.append(
          {
            'data': [
              {'invoice_id': 2},
            ],
            'links': {'next': '/invoices?cursor=cursor-one'},
          },
          revision: revision,
          requestedCursor: 'cursor-one',
        ),
        throwsStateError,
      );

      expect(state.items.map((row) => row['invoice_id']), [1]);
      expect(state.nextCursor, 'cursor-one');
    });

    test('ignores responses from an invalidated page generation', () {
      final state = BillingCursorPageState(identityKey: 'payment_id');
      state.replace({
        'data': [
          {'payment_id': 1},
        ],
        'links': {'next': '/payments?cursor=cursor-one'},
      });
      final oldRevision = state.revision;
      state.beginRefresh(clearItems: true);

      state.append(
        {
          'data': [
            {'payment_id': 2},
          ],
        },
        revision: oldRevision,
        requestedCursor: 'cursor-one',
      );

      expect(state.items, isEmpty);
      expect(state.hasMore, isFalse);
    });

    test('extracts rows and cursor from a nested resource payload', () {
      final state = BillingCursorPageState(identityKey: 'refund_id');

      state.replace({
        'data': {
          'data': [
            {'refund_id': 7},
          ],
          'links': {
            'next': '/refunds?cursor=nested-cursor',
          },
        },
      });

      expect(state.items.single['refund_id'], 7);
      expect(state.nextCursor, 'nested-cursor');
    });
  });
}
