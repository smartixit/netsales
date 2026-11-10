import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/models/app_picked_file_model.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';
import 'package:netsales/features/expenses/domain/usecases/create_expense_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/delete_expense_attachment_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/delete_expense_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expense_details_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expenses_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/update_expense_use_case.dart';

class _FakeExpenseRepository implements ExpenseRepository {
  final List<ExpenseEntity> store = [];
  bool deleteExpenseCalled = false;
  int? lastDeletedExpenseId;
  bool deleteAttachmentCalled = false;
  int? lastDeletedAttachmentId;

  @override
  Future<PaginatedList<ExpenseEntity>> getExpenses({
    required int networkId,
    String? search,
    String? fromDate,
    String? toDate,
    String? cursor,
    int perPage = 20,
  }) async {
    final filtered = store.where((e) => e.networkId == networkId).toList();
    return PaginatedList<ExpenseEntity>(
      items: filtered,
      nextCursor: null,
      prevCursor: null,
      perPage: perPage,
    );
  }

  @override
  Future<ExpenseEntity> getExpense(int expenseId) async {
    return store.firstWhere(
      (e) => e.expenseId == expenseId,
      orElse: () => throw StateError('Expense not found'),
    );
  }

  @override
  Future<ExpenseEntity> createExpense({
    required int networkId,
    required String expenseDate,
    required List<Map<String, dynamic>> items,
    required List<AppPickedFileModel> attachments,
  }) async {
    final expense = ExpenseEntity(
      expenseId: store.length + 1,
      networkId: networkId,
      expenseUuid: 'exp-test-${store.length + 1}',
      totalAmount: items.fold<double>(
        0.0,
        (sum, i) => sum + (double.tryParse(i['item_amount'].toString()) ?? 0),
      ),
      expenseDate: expenseDate,
      networkName: 'Test Network',
      createdByName: 'Accountant',
      items: items.asMap().entries.map((entry) {
        return ExpenseItemEntity(
          itemId: entry.key + 1,
          statement: entry.value['item_statement'] as String? ?? '',
          amount: double.tryParse(entry.value['item_amount'].toString()) ?? 0,
        );
      }).toList(),
      attachments: const [],
    );
    store.add(expense);
    return expense;
  }

  @override
  Future<ExpenseEntity> updateExpense({
    required int expenseId,
    required String expenseDate,
    required List<Map<String, dynamic>> items,
    required List<AppPickedFileModel> attachments,
  }) async {
    final index = store.indexWhere((e) => e.expenseId == expenseId);
    final updated = ExpenseEntity(
      expenseId: expenseId,
      networkId: index >= 0 ? store[index].networkId : 1,
      expenseUuid: 'exp-updated-$expenseId',
      totalAmount: items.fold<double>(
        0.0,
        (sum, i) => sum + (double.tryParse(i['item_amount'].toString()) ?? 0),
      ),
      expenseDate: expenseDate,
      networkName: 'Test Network',
      createdByName: 'Accountant',
      items: items.asMap().entries.map((entry) {
        return ExpenseItemEntity(
          itemId: entry.key + 1,
          statement: entry.value['item_statement'] as String? ?? '',
          amount: double.tryParse(entry.value['item_amount'].toString()) ?? 0,
        );
      }).toList(),
      attachments: const [],
    );
    if (index >= 0) {
      store[index] = updated;
    } else {
      store.add(updated);
    }
    return updated;
  }

  @override
  Future<void> deleteAttachment({
    required int expenseId,
    required int attachmentId,
  }) async {
    deleteAttachmentCalled = true;
    lastDeletedAttachmentId = attachmentId;
  }

  @override
  Future<void> deleteExpense(int expenseId) async {
    deleteExpenseCalled = true;
    lastDeletedExpenseId = expenseId;
    store.removeWhere((e) => e.expenseId == expenseId);
  }
}

void main() {
  group('Expense Domain Use Cases & Lifecycle', () {
    late _FakeExpenseRepository repository;

    setUp(() {
      repository = _FakeExpenseRepository();
    });

    test('CreateExpenseUseCase creates expense and records in repository', () async {
      final useCase = CreateExpenseUseCase(repository);
      final created = await useCase(
        networkId: 10,
        expenseDate: '2026-11-10',
        items: [
          {'item_statement': 'إيجار المقر', 'item_amount': '500.00'},
          {'item_statement': 'وقود المولد', 'item_amount': '250.50'},
        ],
        attachments: [],
      );

      expect(created.expenseId, equals(1));
      expect(created.networkId, equals(10));
      expect(created.totalAmount, equals(750.50));
      expect(created.items.length, equals(2));
      expect(repository.store.length, equals(1));
    });

    test('GetExpensesUseCase returns paginated list of expenses for network', () async {
      final createUseCase = CreateExpenseUseCase(repository);
      await createUseCase(
        networkId: 10,
        expenseDate: '2026-11-10',
        items: [{'item_statement': 'صيانة', 'item_amount': '100'}],
        attachments: [],
      );

      final getUseCase = GetExpensesUseCase(repository);
      final result = await getUseCase(networkId: 10);

      expect(result.items.length, equals(1));
      expect(result.items.first.networkId, equals(10));
    });

    test('GetExpenseDetailsUseCase returns detailed expense by ID', () async {
      final createUseCase = CreateExpenseUseCase(repository);
      final created = await createUseCase(
        networkId: 10,
        expenseDate: '2026-11-10',
        items: [{'item_statement': 'أدوات مكتبية', 'item_amount': '75.25'}],
        attachments: [],
      );

      final detailsUseCase = GetExpenseDetailsUseCase(repository);
      final details = await detailsUseCase(created.expenseId);

      expect(details.expenseId, equals(created.expenseId));
      expect(details.items.first.statement, equals('أدوات مكتبية'));
      expect(details.items.first.amount, equals(75.25));
    });

    test('UpdateExpenseUseCase modifies expense and updates total', () async {
      final createUseCase = CreateExpenseUseCase(repository);
      final created = await createUseCase(
        networkId: 10,
        expenseDate: '2026-11-10',
        items: [{'item_statement': 'بند قديم', 'item_amount': '50'}],
        attachments: [],
      );

      final updateUseCase = UpdateExpenseUseCase(repository);
      final updated = await updateUseCase(
        expenseId: created.expenseId,
        expenseDate: '2026-11-11',
        items: [{'item_statement': 'بند محدث', 'item_amount': '120'}],
        attachments: [],
      );

      expect(updated.expenseId, equals(created.expenseId));
      expect(updated.totalAmount, equals(120.0));
      expect(updated.items.first.statement, equals('بند محدث'));
      expect(repository.store.first.totalAmount, equals(120.0));
    });

    test('DeleteExpenseUseCase soft deletes expense from repository', () async {
      final createUseCase = CreateExpenseUseCase(repository);
      final created = await createUseCase(
        networkId: 10,
        expenseDate: '2026-11-10',
        items: [{'item_statement': 'بند للحذف', 'item_amount': '300'}],
        attachments: [],
      );

      final deleteUseCase = DeleteExpenseUseCase(repository);
      await deleteUseCase(created.expenseId);

      expect(repository.deleteExpenseCalled, isTrue);
      expect(repository.lastDeletedExpenseId, equals(created.expenseId));
      expect(repository.store.isEmpty, isTrue);
    });

    test('DeleteExpenseAttachmentUseCase delegates to repository with correct IDs', () async {
      final deleteAttachmentUseCase = DeleteExpenseAttachmentUseCase(repository);
      await deleteAttachmentUseCase(expenseId: 5, attachmentId: 42);

      expect(repository.deleteAttachmentCalled, isTrue);
      expect(repository.lastDeletedAttachmentId, equals(42));
    });
  });
}

