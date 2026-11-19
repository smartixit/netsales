import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/entities/expense_summary_entity.dart';
import 'package:netsales/features/expenses/domain/usecases/delete_expense_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expense_summary_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expenses_use_case.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم قائمة المصروفات التشغيلية لمشغل الشبكة (Network Operating Expenses Controller)
class NetworkOperatingExpensesController extends GetxController {
  NetworkOperatingExpensesController({
    required this.getExpensesUseCase,
    required this.getExpenseSummaryUseCase,
    required this.deleteExpenseUseCase,
    this.getMyNetworksUseCase,
  });

  final GetExpensesUseCase getExpensesUseCase;
  final GetExpenseSummaryUseCase getExpenseSummaryUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;
  final GetMyNetworksUseCase? getMyNetworksUseCase;

  // ── الحالة الأساسية والترقيم ──
  final expenses = <ExpenseEntity>[].obs;
  final summary = Rxn<ExpenseSummaryEntity>();
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();
  final nextCursor = RxnString();

  // ── التوسيع الحصري للبطاقات ──
  final expandedExpenseId = RxnInt();

  // ── فلاتر البحث والتواريخ والشبكة ──
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final fromDate = RxnString();
  final toDate = RxnString();
  final selectedNetworkId = RxnInt();
  final authorizedNetworks = <NetworkEntity>[].obs;

  final Set<int> _expenseIds = {};
  int _requestIdCounter = 0;

  bool get hasMore => nextCursor.value != null;

  bool get canCreateExpense =>
      PermissionService.to.can(AppPermissions.expensesCreate);

  bool get canDeleteExpense =>
      PermissionService.to.can(AppPermissions.expensesDelete);

  @override
  void onInit() {
    super.onInit();

    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    debounce(
      searchQuery,
      (_) => loadExpenses(isRefresh: true),
      time: const Duration(milliseconds: 300),
    );

    loadNetworksAndExpenses();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// التوسيع أو الطي الحصري لبطاقة المصروف
  void toggleExpenseExpansion(int expenseId) {
    if (expandedExpenseId.value == expenseId) {
      expandedExpenseId.value = null;
    } else {
      expandedExpenseId.value = expenseId;
    }
  }

  /// تغيير فلتر الشبكة
  void onNetworkFilterChanged(int? networkId) {
    if (selectedNetworkId.value == networkId) return;
    selectedNetworkId.value = networkId;
    if (networkId != null) {
      WorkspaceService.to.saveActiveNetworkId(networkId);
    }
    loadExpenses(isRefresh: true);
    loadSummary();
  }

  /// تعيين مدى التواريخ
  void setDateRange(String? from, String? to) {
    fromDate.value = from;
    toDate.value = to;
    loadExpenses(isRefresh: true);
    loadSummary();
  }

  /// إعادة تعيين الفلاتر
  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    fromDate.value = null;
    toDate.value = null;
    loadExpenses(isRefresh: true);
    loadSummary();
  }

  /// تحديث القائمة والملخص
  Future<void> refreshExpenses() async {
    await Future.wait([
      loadExpenses(isRefresh: true),
      loadSummary(),
    ]);
  }

  /// تحميل الشبكات المرخصة والمصروفات
  Future<void> loadNetworksAndExpenses() async {
    if (getMyNetworksUseCase != null) {
      try {
        final networks = await getMyNetworksUseCase!();
        authorizedNetworks.assignAll(networks);
        final networkIds =
            networks.map((n) => n.networkId).toList(growable: false);
        final resolvedId = WorkspaceService.to.resolveActiveNetworkId(
          networkIds,
        );
        selectedNetworkId.value = resolvedId;
        if (resolvedId != null) {
          await WorkspaceService.to.saveActiveNetworkId(resolvedId);
        }
      } catch (_) {
        // الاعتماد على التحديد التلقائي للخادم
      }
    }
    await Future.wait([
      loadExpenses(isRefresh: true),
      loadSummary(),
    ]);
  }

  /// جلب المصروفات التشغيلية
  Future<void> loadExpenses({bool isRefresh = false}) async {
    final currentRequestId = ++_requestIdCounter;

    if (isRefresh) {
      isLoading.value = true;
      errorMessage.value = null;
      nextCursor.value = null;
    } else {
      if (isLoadingMore.value || !hasMore) return;
      isLoadingMore.value = true;
    }

    try {
      final PaginatedList<ExpenseEntity> result = await getExpensesUseCase(
        networkId: selectedNetworkId.value,
        fromDate: fromDate.value,
        toDate: toDate.value,
        search: searchQuery.value.trim().isEmpty ? null : searchQuery.value.trim(),
        cursor: isRefresh ? null : nextCursor.value,
        perPage: 15,
      );

      if (currentRequestId != _requestIdCounter) return;

      if (isRefresh) {
        _expenseIds.clear();
        final List<ExpenseEntity> uniqueItems = [];
        for (final item in result.items) {
          if (_expenseIds.add(item.expenseId)) {
            uniqueItems.add(item);
          }
        }
        expenses.assignAll(uniqueItems);
      } else {
        final List<ExpenseEntity> newItems = [];
        for (final item in result.items) {
          if (_expenseIds.add(item.expenseId)) {
            newItems.add(item);
          }
        }
        expenses.addAll(newItems);
      }

      nextCursor.value = result.nextCursor;
      errorMessage.value = null;
    } catch (e) {
      if (currentRequestId != _requestIdCounter) return;
      final msg = AppException.sanitizeMessage(e.toString());
      if (isRefresh) {
        errorMessage.value = msg;
      } else {
        CustomSnackbar.show(
          title: 'خطأ أثناء تحميل المزيد',
          message: msg,
          type: SnackType.error,
        );
      }
    } finally {
      if (currentRequestId == _requestIdCounter) {
        isLoading.value = false;
        isLoadingMore.value = false;
      }
    }
  }

  /// جلب المزيد عند التمرير
  void loadMoreExpenses() {
    if (!isLoading.value && !isLoadingMore.value && hasMore) {
      loadExpenses(isRefresh: false);
    }
  }

  /// جلب ملخص المصروفات
  Future<void> loadSummary() async {
    try {
      final res = await getExpenseSummaryUseCase(
        networkId: selectedNetworkId.value,
        fromDate: fromDate.value,
        toDate: toDate.value,
      );
      summary.value = res;
    } catch (_) {
      // إهمال الخطأ للحفاظ على تجربة المستخدم
    }
  }

  /// حذف مصروف تشغيلي مع العكس المالي التلقائي
  Future<void> deleteExpense(int expenseId) async {
    try {
      await deleteExpenseUseCase(expenseId);
      expenses.removeWhere((e) => e.expenseId == expenseId);
      _expenseIds.remove(expenseId);
      CustomSnackbar.show(
        title: 'تم الحذف بنجاح',
        message: 'تم حذف المصروف واسترجاع المبلغ لمحفظة الشبكة.',
        type: SnackType.success,
      );
      await loadSummary();
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر حذف المصروف',
        message: AppException.sanitizeMessage(e.toString()),
        type: SnackType.error,
      );
    }
  }

  /// الانتقال إلى شاشة إضافة مصروف تشغيلي
  Future<void> navigateToCreate() async {
    final result = await Get.toNamed<dynamic>(AppRoutes.createOperatingExpense);
    if (result == true) {
      await refreshExpenses();
    }
  }

  /// الانتقال إلى شاشة تفاصيل المصروف
  Future<void> navigateToDetails(ExpenseEntity expense) async {
    final result = await Get.toNamed<dynamic>(
      AppRoutes.operatingExpenseDetails,
      arguments: expense.expenseId,
    );
    if (result == true) {
      await refreshExpenses();
    }
  }
}
