import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/entities/expense_summary_entity.dart';
import 'package:netsales/features/expenses/domain/usecases/delete_expense_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/expense_document_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expense_summary_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expenses_use_case.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_card_actions.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم استعراض وإدارة المصروفات التشغيلية لمزود الشبكة (Network Operating Expenses)
class NetworkExpensesController extends GetxController {
  NetworkExpensesController({
    required this.getExpensesUseCase,
    required this.getExpenseSummaryUseCase,
    required this.deleteExpenseUseCase,
    this.expenseDocumentUseCase,
  });

  final GetExpensesUseCase getExpensesUseCase;
  final GetExpenseSummaryUseCase getExpenseSummaryUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;
  final ExpenseDocumentUseCase? expenseDocumentUseCase;

  final expenses = <ExpenseEntity>[].obs;
  final summary = Rxn<ExpenseSummaryEntity>();
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final isLoadingMore = false.obs;
  final loadMoreError = RxnString();
  final searchQuery = ''.obs;
  final searchController = TextEditingController();
  final expandedExpenseId = RxnInt();

  String? _nextCursor;

  bool get hasMore => _nextCursor != null && _nextCursor!.isNotEmpty;

  int? get activeNetworkId {
    if (Get.isRegistered<WorkspaceService>()) {
      return WorkspaceService.to.savedActiveNetworkId;
    }
    return null;
  }

  bool get canCreateExpense {
    if (Get.isRegistered<PermissionService>()) {
      return PermissionService.instance.can(AppPermissions.expensesCreate);
    }
    return false;
  }

  bool get canDeleteExpense {
    if (Get.isRegistered<PermissionService>()) {
      return PermissionService.instance.can(AppPermissions.expensesDelete);
    }
    return false;
  }

  bool get canEditExpense {
    if (Get.isRegistered<PermissionService>()) {
      return PermissionService.instance.can(AppPermissions.expensesEdit);
    }
    return false;
  }

  void onEditExpense(ExpenseEntity expense) {
    Get.toNamed<void>(
      AppRoutes.createOperatingExpense,
      arguments: {'expense': expense},
    );
  }

  String get pageTitle => 'المصروفات التشغيلية';

  String get pageSubtitle =>
      'سجل سندات الصرف، متابعة النفقات المباشرة، والخصم التلقائي من محفظة الشبكة.';

  IconData get pageIcon => Icons.receipt_long_rounded;

  Widget? get headerAction => canCreateExpense
      ? CustomButton.primary(
          text: 'تسجيل مصروف',
          icon: Icons.add_rounded,
          shape: AppButtonShape.rounded,
          size: AppButtonSize.small,
          onPressed: () => Get.toNamed<void>(AppRoutes.createOperatingExpense),
        )
      : null;

  String get searchHint => 'بحث برقم السند، المعرف، أو بيان البنود...';

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      final value = searchController.text.trim();
      if (searchQuery.value != value) {
        searchQuery.value = value;
      }
    });

    debounce<String>(searchQuery, (_) {
      loadExpenses(isRefresh: true);
    }, time: const Duration(milliseconds: 350));

    loadExpenses();
    _loadSummary();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> _loadSummary() async {
    try {
      final res = await getExpenseSummaryUseCase(networkId: activeNetworkId);
      summary.value = res;
    } catch (_) {
      // الملخص اختياري ولا يعيق تحميل القائمة
    }
  }

  Future<void> loadExpenses({bool isRefresh = false}) async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await getExpensesUseCase(
        networkId: activeNetworkId,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      _nextCursor = getExpensesUseCase.nextCursor;
      expenses.assignAll(result);

      if (isRefresh) {
        await _loadSummary();
      }
    } catch (e) {
      errorMessage.value = AppException.sanitizeMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreExpenses() async {
    if (isLoadingMore.value || !hasMore) return;

    isLoadingMore.value = true;
    loadMoreError.value = null;

    try {
      final result = await getExpensesUseCase(
        networkId: activeNetworkId,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        cursor: _nextCursor,
      );

      _nextCursor = getExpensesUseCase.nextCursor;
      expenses.addAll(result);
    } catch (e) {
      loadMoreError.value = AppException.sanitizeMessage(e);
    } finally {
      isLoadingMore.value = false;
    }
  }

  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    loadExpenses(isRefresh: true);
  }

  void toggleExpenseExpansion(int expenseId) {
    if (expandedExpenseId.value == expenseId) {
      expandedExpenseId.value = null;
    } else {
      expandedExpenseId.value = expenseId;
    }
  }

  void openExpenseDetails(ExpenseEntity expense) {
    Get.toNamed<void>(
      AppRoutes.operatingExpenseDetails,
      arguments: {'expense_id': expense.expenseId, 'expense': expense},
    );
  }

  Future<void> printExpense(ExpenseEntity expense) async {
    if (expenseDocumentUseCase == null) {
      CustomSnackbar.show(
        title: 'طباعة السند',
        message: 'خدمة الطباعة غير مهيأة حالياً.',
        type: SnackType.warning,
      );
      return;
    }

    try {
      await expenseDocumentUseCase!.printExpense(expense);
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر الطباعة',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    }
  }

  Future<void> shareExpense(ExpenseEntity expense) async {
    if (expenseDocumentUseCase == null) {
      CustomSnackbar.show(
        title: 'مشاركة السند',
        message: 'خدمة المشاركة غير مهيأة حالياً.',
        type: SnackType.warning,
      );
      return;
    }

    try {
      await expenseDocumentUseCase!.shareExpense(expense);
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر المشاركة',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    }
  }

  Future<void> saveExpense(ExpenseEntity expense) async {
    if (expenseDocumentUseCase == null) {
      CustomSnackbar.show(
        title: 'حفظ السند',
        message: 'خدمة حفظ الملفات غير مهيأة حالياً.',
        type: SnackType.warning,
      );
      return;
    }

    try {
      final success = await expenseDocumentUseCase!.saveExpense(expense);
      if (success) {
        CustomSnackbar.show(
          title: 'تم الحفظ بنجاح',
          message: 'تم حفظ سند المصروف في جهازك بنجاح.',
          type: SnackType.success,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر الحفظ',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    }
  }

  Future<void> confirmDeleteExpense(
    BuildContext context,
    ExpenseEntity expense,
  ) async {
    final confirmed = await CustomDialog.show(
      type: DialogType.danger,
      title: 'حذف سند المصروف',
      message:
          'هل أنت متأكد من حذف سند المصروف رقم (${expense.displayReference}) بمبلغ ${AmountFormatter.formatValue(expense.expenseTotalAmount)} ر.ي؟\nسيتم استرداد المبلغ وإيداعه في محفظة الشبكة.',
      confirmLabel: 'نعم، حذف واسترداد',
      cancelLabel: 'إلغاء',
    );

    if (confirmed != true) return;

    try {
      await deleteExpenseUseCase(expense.expenseId);
      expenses.removeWhere((e) => e.expenseId == expense.expenseId);
      await _loadSummary();

      CustomSnackbar.show(
        title: 'تم الحذف بنجاح',
        message: 'تم حذف سند المصروف واسترداد مبلغه لمحفظة الشبكة بنجاح.',
        type: SnackType.success,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر حذف المصروف',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    }
  }

  List<CustomKpiCardData> buildKpiCards(BuildContext context) {
    final colors = context.colors;
    final s = summary.value;

    return [
      CustomKpiCardData(
        label: 'إجمالي المصروفات',
        count: s?.totalCount ?? expenses.length,
        icon: Icons.account_balance_wallet_rounded,
        accentColor: colors.primary,
      ),
      CustomKpiCardData(
        label: 'مصروفات الشهر',
        count: (s?.thisMonthAmount ?? 0).toInt(),
        icon: Icons.calendar_month_rounded,
        accentColor: colors.secondary,
      ),
      CustomKpiCardData(
        label: 'صرف اليوم',
        count: (s?.todayAmount ?? 0).toInt(),
        icon: Icons.today_rounded,
        accentColor: colors.primary,
      ),
    ];
  }

  List<CustomSearchFilterOption<String?>> buildFilterOptions(
    BuildContext context,
  ) {
    return [
      const CustomSearchFilterOption(
        value: null,
        label: 'جميع المصروفات',
        icon: Icons.list_alt_rounded,
      ),
    ];
  }

  Widget buildCardActions(BuildContext context, ExpenseEntity expense) {
    return ExpenseCardActions(
      expense: expense,
      onDetails: () => openExpenseDetails(expense),
      onEdit: canEditExpense ? () => onEditExpense(expense) : null,
      onPrint: () => printExpense(expense),
      onShare: () => shareExpense(expense),
      onDelete: canDeleteExpense
          ? () => confirmDeleteExpense(context, expense)
          : null,
    );
  }
}
