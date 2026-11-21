import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/models/app_picked_file_model.dart';
import 'package:netsales/features/expenses/domain/entities/expense_attachment_entity.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/entities/expense_item_entity.dart';
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
import 'package:netsales/features/expenses/domain/usecases/update_expense_use_case.dart';
import 'package:netsales/features/expenses/presentation/controllers/expense_details_controller.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_expense_form_controller.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_expenses_controller.dart';

class MockExpenseRepository implements ExpenseRepository {
  List<ExpenseEntity> dummyExpenses = [];
  ExpenseSummaryEntity dummySummary = const ExpenseSummaryEntity(
    totalCount: 3,
    totalAmount: 15000.0,
    thisMonthAmount: 10000.0,
    todayAmount: 5000.0,
  );
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
          expenseTotalAmount: 2500.0,
          items: [
            ExpenseItemEntity(
              itemId: 1,
              expenseId: expenseId,
              itemStatement: 'صيانة شبكة',
              itemAmount: 2500.0,
            ),
          ],
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
    List<int>? deletedAttachmentIds,
  }) async {
    return ExpenseEntity(
      expenseId: expenseId,
      expenseUuid: 'EXP-$expenseId',
      networkId: 1,
      expenseTotalAmount:
          items?.fold<double>(0.0, (sum, i) => sum + i.itemAmount) ?? 2500.0,
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
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockExpenseRepository mockRepo;
  late MockExpenseDocumentRepository mockDocRepo;

  setUp(() {
    Get.reset();
    mockRepo = MockExpenseRepository();
    mockDocRepo = MockExpenseDocumentRepository();
  });

  tearDown(() {
    Get.reset();
  });

  group('NetworkExpensesController Tests', () {
    test('Initializes and loads expenses and summary accurately', () async {
      mockRepo.dummyExpenses = [
        const ExpenseEntity(
          expenseId: 10,
          expenseUuid: 'EXP-10',
          networkId: 1,
          expenseTotalAmount: 3000.0,
        ),
      ];

      final controller = NetworkExpensesController(
        getExpensesUseCase: GetExpensesUseCase(mockRepo),
        getExpenseSummaryUseCase: GetExpenseSummaryUseCase(mockRepo),
        deleteExpenseUseCase: DeleteExpenseUseCase(mockRepo),
        expenseDocumentUseCase: ExpenseDocumentUseCase(mockDocRepo),
      );

      Get.put(controller);

      await controller.loadExpenses();

      expect(controller.expenses.length, 1);
      expect(controller.expenses.first.expenseId, 10);
      expect(controller.summary.value?.totalAmount, 15000.0);

      controller.toggleExpenseExpansion(10);
      expect(controller.expandedExpenseId.value, 10);
      controller.toggleExpenseExpansion(10);
      expect(controller.expandedExpenseId.value, isNull);
    });

    test('Loads more expenses via cursor pagination', () async {
      mockRepo.dummyExpenses = [
        const ExpenseEntity(
          expenseId: 1,
          expenseUuid: 'EXP-1',
          networkId: 1,
          expenseTotalAmount: 1000.0,
        ),
      ];
      mockRepo.nextCursorValue = 'cursor-123';

      final controller = NetworkExpensesController(
        getExpensesUseCase: GetExpensesUseCase(mockRepo),
        getExpenseSummaryUseCase: GetExpenseSummaryUseCase(mockRepo),
        deleteExpenseUseCase: DeleteExpenseUseCase(mockRepo),
      );

      Get.put(controller);

      await controller.loadExpenses();
      expect(controller.hasMore, isTrue);

      mockRepo.dummyExpenses = [
        const ExpenseEntity(
          expenseId: 2,
          expenseUuid: 'EXP-2',
          networkId: 1,
          expenseTotalAmount: 2000.0,
        ),
      ];
      mockRepo.nextCursorValue = null;

      await controller.loadMoreExpenses();
      expect(controller.expenses.length, 2);
      expect(controller.hasMore, isFalse);
    });
  });

  group('ExpenseDetailsController Tests', () {
    test('Loads expense details and builds gallery items', () async {
      final controller = ExpenseDetailsController(
        getExpenseDetailsUseCase: GetExpenseDetailsUseCase(mockRepo),
        deleteExpenseUseCase: DeleteExpenseUseCase(mockRepo),
        expenseDocumentUseCase: ExpenseDocumentUseCase(mockDocRepo),
      );

      Get.put(controller);

      await controller.loadExpenseDetails(5);
      expect(controller.expense.value?.expenseId, 5);

      final items = controller.buildMediaGalleryItems();
      expect(items, isEmpty); // no attachments in dummyDetails

      await controller.printCurrentExpense();
      expect(mockDocRepo.printCalled, isTrue);

      await controller.shareCurrentExpense();
      expect(mockDocRepo.shareCalled, isTrue);

      await controller.saveCurrentExpense();
      expect(mockDocRepo.exportCalled, isTrue);
    });
  });

  group('NetworkExpenseFormController Tests', () {
    test('Manages item rows and recalculates total accurately', () {
      final controller = NetworkExpenseFormController(
        createExpenseUseCase: CreateExpenseUseCase(mockRepo),
        updateExpenseUseCase: UpdateExpenseUseCase(mockRepo),
      );

      Get.put(controller);

      expect(controller.statementControllers.length, 1);

      controller.statementControllers.first.text = 'إيجار المقر';
      controller.amountControllers.first.text = '5000.0';
      controller.recalculateTotal();

      expect(controller.totalAmount.value, 5000.0);

      controller.addItemRow();
      expect(controller.statementControllers.length, 2);

      controller.statementControllers[1].text = 'فاتورة كهرباء';
      controller.amountControllers[1].text = '1200.0';
      controller.recalculateTotal();

      expect(controller.totalAmount.value, 6200.0);

      controller.removeItemRow(1);
      expect(controller.statementControllers.length, 1);
      expect(controller.totalAmount.value, 5000.0);
    });

    test('Initializes with existing attachments and tracks deletions for atomic payload', () {
      final initialExpense = ExpenseEntity(
        expenseId: 42,
        expenseUuid: 'EXP-42',
        networkId: 1,
        expenseTotalAmount: 3000.0,
        attachments: const [
          ExpenseAttachmentEntity(
            attachmentId: 101,
            expenseId: 42,
            attachmentName: 'bill_oct.pdf',
            attachmentPath: 'expenses/bill_oct.pdf',
            attachmentSize: 10240,
            attachmentMime: 'application/pdf',
          ),
          ExpenseAttachmentEntity(
            attachmentId: 102,
            expenseId: 42,
            attachmentName: 'receipt.png',
            attachmentPath: 'expenses/receipt.png',
            attachmentSize: 20480,
            attachmentMime: 'image/png',
          ),
        ],
      );

      // Set arguments to mimic Get.arguments in edit mode
      final controller = NetworkExpenseFormController(
        createExpenseUseCase: CreateExpenseUseCase(mockRepo),
        updateExpenseUseCase: UpdateExpenseUseCase(mockRepo),
      );

      // Inject arguments before onInit
      Get.routing.args = initialExpense;
      controller.onInit();

      expect(controller.isEditMode, isTrue);
      expect(controller.editingExpenseId.value, 42);
      expect(controller.existingAttachments.length, 2);
      expect(controller.deletedAttachmentIds, isEmpty);

      // User marks the first attachment for deletion
      controller.removeExistingAttachment(101);

      expect(controller.existingAttachments.length, 1);
      expect(controller.existingAttachments.first.attachmentId, 102);
      expect(controller.deletedAttachmentIds, contains(101));
    });
  });
}
