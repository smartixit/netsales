import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/models/app_picked_file_model.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/entities/expense_summary_entity.dart';
import 'package:netsales/features/expenses/domain/entities/new_expense_item_input_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_document_repository.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';
import 'package:netsales/features/expenses/domain/usecases/create_expense_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/delete_expense_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/expense_document_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expense_details_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expense_summary_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expenses_use_case.dart';

class MockExpenseRepository implements ExpenseRepository {
  List<ExpenseEntity> dummyExpenses = [];
  ExpenseSummaryEntity dummySummary = const ExpenseSummaryEntity();
  ExpenseEntity? dummyDetails;
  String? nextCursorValue;
  bool deleteCalled = false;
  int? deletedExpenseId;

  @override
  String? get nextCursor => nextCursorValue;

  @override
  Future<List<ExpenseEntity>> getExpenses({
    int? networkId,
    String? fromDate,
    String? toDate,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    return dummyExpenses;
  }

  @override
  Future<ExpenseSummaryEntity> getExpenseSummary({
    int? networkId,
    String? fromDate,
    String? toDate,
  }) async {
    return dummySummary;
  }

  @override
  Future<ExpenseEntity> getExpenseDetails(int expenseId) async {
    return dummyDetails ??
        ExpenseEntity(
          expenseId: expenseId,
          expenseUuid: 'EXP-$expenseId',
          networkId: 1,
          expenseTotalAmount: 1000.0,
        );
  }

  @override
  Future<ExpenseEntity> createExpense({
    required int networkId,
    DateTime? expenseDate,
    required List<NewExpenseItemInputEntity> items,
    List<AppPickedFileModel>? attachments,
    String? idempotencyKey,
  }) async {
    return ExpenseEntity(
      expenseId: 999,
      expenseUuid: 'EXP-999',
      networkId: networkId,
      expenseTotalAmount: items.fold(0.0, (sum, i) => sum + i.itemAmount),
      expenseDate: expenseDate,
    );
  }

  @override
  Future<ExpenseEntity> updateExpense({
    required int expenseId,
    DateTime? expenseDate,
    List<NewExpenseItemInputEntity>? items,
    List<AppPickedFileModel>? attachments,
  }) async {
    return ExpenseEntity(
      expenseId: expenseId,
      expenseUuid: 'EXP-$expenseId',
      networkId: 1,
      expenseTotalAmount:
          items?.fold<double>(0.0, (sum, i) => sum + i.itemAmount) ?? 1000.0,
      expenseDate: expenseDate,
    );
  }

  @override
  Future<void> deleteExpense(int expenseId) async {
    deleteCalled = true;
    deletedExpenseId = expenseId;
  }
}

class MockExpenseDocumentRepository implements ExpenseDocumentRepository {
  bool printCalled = false;
  bool shareCalled = false;
  bool exportCalled = false;

  @override
  Future<bool> printExpense(ExpenseEntity expense) async {
    printCalled = true;
    return true;
  }

  @override
  Future<bool> shareExpense(ExpenseEntity expense) async {
    shareCalled = true;
    return true;
  }

  @override
  Future<bool> exportAndSaveExpense(ExpenseEntity expense) async {
    exportCalled = true;
    return true;
  }
}

void main() {
  late MockExpenseRepository mockRepository;
  late MockExpenseDocumentRepository mockDocRepository;

  setUp(() {
    mockRepository = MockExpenseRepository();
    mockDocRepository = MockExpenseDocumentRepository();
  });

  group('Expenses Use Cases Tests', () {
    test(
      'GetExpensesUseCase retrieves expenses list from repository',
      () async {
        mockRepository.dummyExpenses = [
          const ExpenseEntity(
            expenseId: 1,
            expenseUuid: 'EXP-1',
            networkId: 10,
            expenseTotalAmount: 500.0,
          ),
        ];

        final useCase = GetExpensesUseCase(mockRepository);
        final result = await useCase(networkId: 10);

        expect(result.length, 1);
        expect(result.first.expenseUuid, 'EXP-1');
      },
    );

    test('GetExpenseSummaryUseCase retrieves statistics', () async {
      mockRepository.dummySummary = const ExpenseSummaryEntity(
        totalCount: 15,
        totalAmount: 120000.0,
      );

      final useCase = GetExpenseSummaryUseCase(mockRepository);
      final summary = await useCase(networkId: 10);

      expect(summary.totalCount, 15);
      expect(summary.totalAmount, 120000.0);
    });

    test('GetExpenseDetailsUseCase retrieves specific expense', () async {
      final useCase = GetExpenseDetailsUseCase(mockRepository);
      final details = await useCase(42);

      expect(details.expenseId, 42);
      expect(details.expenseUuid, 'EXP-42');
    });

    test('CreateExpenseUseCase creates expense and returns entity', () async {
      final useCase = CreateExpenseUseCase(mockRepository);
      final result = await useCase(
        networkId: 7,
        items: const [
          NewExpenseItemInputEntity(
            itemStatement: 'وقود مولد',
            itemAmount: 3500.0,
          ),
        ],
        idempotencyKey: 'idemp-123',
      );

      expect(result.expenseId, 999);
      expect(result.expenseTotalAmount, 3500.0);
    });

    test('DeleteExpenseUseCase triggers deletion in repository', () async {
      final useCase = DeleteExpenseUseCase(mockRepository);
      await useCase(88);

      expect(mockRepository.deleteCalled, isTrue);
      expect(mockRepository.deletedExpenseId, 88);
    });

    test(
      'ExpenseDocumentUseCase delegates print, share, and save correctly',
      () async {
        const expense = ExpenseEntity(
          expenseId: 10,
          expenseUuid: 'EXP-10',
          networkId: 1,
          expenseTotalAmount: 500.0,
        );

        final useCase = ExpenseDocumentUseCase(mockDocRepository);

        final printRes = await useCase.printExpense(expense);
        expect(printRes, isTrue);
        expect(mockDocRepository.printCalled, isTrue);

        final shareRes = await useCase.shareExpense(expense);
        expect(shareRes, isTrue);
        expect(mockDocRepository.shareCalled, isTrue);

        final saveRes = await useCase.saveExpense(expense);
        expect(saveRes, isTrue);
        expect(mockDocRepository.exportCalled, isTrue);
      },
    );
  });
}
