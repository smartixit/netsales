import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/expenses/domain/entities/expense_attachment_entity.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/entities/expense_item_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:netsales/features/expenses/domain/usecases/create_expense_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/delete_expense_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expense_details_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/get_network_expenses_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/update_expense_use_case.dart';

class _MockExpensesRepository implements ExpensesRepository {
  int getExpensesCalls = 0;
  int getDetailsCalls = 0;
  int createCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;

  int? lastRequestedExpenseId;
  int? lastDeletedExpenseId;

  final sampleExpense = const ExpenseEntity(
    expenseId: 101,
    networkId: 1,
    expenseReference: 'EXP-2026-001',
    expenseDate: '2026-11-20',
    totalAmount: 15000.0,
    itemsCount: 2,
    attachmentsCount: 1,
    creatorName: 'أحمد المحاسب',
    networkName: 'شبكة النور',
    items: [
      ExpenseItemEntity(
        itemId: 1,
        expenseId: 101,
        itemStatement: 'صيانة كابلات فايبر',
        itemAmount: 10000.0,
      ),
      ExpenseItemEntity(
        itemId: 2,
        expenseId: 101,
        itemStatement: 'وقود مولد كهرباء',
        itemAmount: 5000.0,
      ),
    ],
    attachments: [
      ExpenseAttachmentEntity(
        attachmentId: 1,
        expenseId: 101,
        attachmentName: 'فاتورة_ديزل.pdf',
        attachmentPath: 'expenses/101/doc.pdf',
        attachmentSize: 102400,
        attachmentMime: 'application/pdf',
        fileUrl: 'https://example.com/doc.pdf',
      ),
    ],
  );

  @override
  Future<PaginatedList<ExpenseEntity>> getNetworkExpenses({
    required int networkId,
    String? search,
    String? fromDate,
    String? toDate,
    String? cursor,
    int? perPage,
  }) async {
    getExpensesCalls++;
    return PaginatedList<ExpenseEntity>(
      items: [sampleExpense],
      nextCursor: null,
      prevCursor: null,
    );
  }

  @override
  Future<ExpenseEntity> getExpenseDetails(int expenseId) async {
    getDetailsCalls++;
    lastRequestedExpenseId = expenseId;
    return sampleExpense;
  }

  @override
  Future<ExpenseEntity> createExpense({
    required int networkId,
    required String expenseDate,
    required List<Map<String, dynamic>> items,
    List<String> attachmentPaths = const [],
  }) async {
    createCalls++;
    return sampleExpense;
  }

  @override
  Future<ExpenseEntity> updateExpense({
    required int expenseId,
    required String expenseDate,
    required List<Map<String, dynamic>> items,
    List<String> attachmentPaths = const [],
  }) async {
    updateCalls++;
    return sampleExpense;
  }

  @override
  Future<void> deleteExpense(int expenseId) async {
    deleteCalls++;
    lastDeletedExpenseId = expenseId;
  }
}

void main() {
  late _MockExpensesRepository repository;

  setUp(() {
    repository = _MockExpensesRepository();
  });

  group('Expenses Domain Use Cases Tests', () {
    test('GetNetworkExpensesUseCase calls repository and returns paginated list', () async {
      final useCase = GetNetworkExpensesUseCase(repository);

      final result = await useCase(networkId: 1);

      expect(repository.getExpensesCalls, 1);
      expect(result.items.length, 1);
      expect(result.items.first.expenseReference, 'EXP-2026-001');
      expect(result.items.first.totalAmount, 15000.0);
    });

    test('GetExpenseDetailsUseCase returns complete expense entity with items and attachments', () async {
      final useCase = GetExpenseDetailsUseCase(repository);

      final result = await useCase(101);

      expect(repository.getDetailsCalls, 1);
      expect(repository.lastRequestedExpenseId, 101);
      expect(result.items.length, 2);
      expect(result.attachments.length, 1);
      expect(result.attachments.first.formattedSize, isNotEmpty);
    });

    test('CreateExpenseUseCase executes creation with valid items and dates', () async {
      final useCase = CreateExpenseUseCase(repository);

      final result = await useCase(
        networkId: 1,
        expenseDate: '2026-11-20',
        items: [
          {'item_statement': 'أدوات مكتبية', 'item_amount': 2500.0},
        ],
      );

      expect(repository.createCalls, 1);
      expect(result.expenseId, 101);
    });

    test('DeleteExpenseUseCase delegates expense deletion to repository', () async {
      final useCase = DeleteExpenseUseCase(repository);

      await useCase(101);

      expect(repository.deleteCalls, 1);
      expect(repository.lastDeletedExpenseId, 101);
    });
  });

  group('Expense Entities and Props Verification', () {
    test('ExpenseEntity formatted date and items integrity', () {
      final expense = repository.sampleExpense;

      expect(expense.expenseId, 101);
      expect(expense.items.first.itemStatement, 'صيانة كابلات فايبر');
      expect(expense.items.first.itemAmount, 10000.0);
      expect(expense.attachments.first.attachmentName, 'فاتورة_ديزل.pdf');
    });
  });
}
