import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/app_picked_file_model.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/usecases/expense_use_cases.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class NetworkOperatingExpensesController extends GetxController {
  NetworkOperatingExpensesController({
    required this.getMyNetworksUseCase,
    required this.getExpensesUseCase,
    required this.getExpenseDetailsUseCase,
    required this.createExpenseUseCase,
    required this.updateExpenseUseCase,
    required this.deleteExpenseAttachmentUseCase,
  });
  final GetMyNetworksUseCase getMyNetworksUseCase;
  final GetExpensesUseCase getExpensesUseCase;
  final GetExpenseDetailsUseCase getExpenseDetailsUseCase;
  final CreateExpenseUseCase createExpenseUseCase;
  final UpdateExpenseUseCase updateExpenseUseCase;
  final DeleteExpenseAttachmentUseCase deleteExpenseAttachmentUseCase;

  final searchTextController = TextEditingController();
  final networks = <NetworkEntity>[].obs;
  final selectedNetworkId = RxnInt();
  final isLoadingNetworks = false.obs;
  final networkError = RxnString();
  final expenses = <ExpenseEntity>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final error = RxnString();
  final loadMoreError = RxnString();
  final searchQuery = ''.obs;
  final fromDate = Rxn<DateTime>();
  final toDate = Rxn<DateTime>();
  final selectedExpense = Rxn<ExpenseEntity>();
  final isLoadingDetails = false.obs;
  final isSaving = false.obs;
  final formAttachments = <AppPickedFileModel>[].obs;

  String? _cursor;
  int _listVersion = 0;
  int _networkVersion = 0;
  int _detailVersion = 0;
  bool _loaded = false;
  Timer? _searchDebounce;
  bool get hasMore => _cursor?.trim().isNotEmpty ?? false;
  bool get hasSelectedNetwork => selectedNetworkId.value != null;
  bool get canCreate => PermissionService.to.can(AppPermissions.expensesCreate);
  bool get canEdit => PermissionService.to.can(AppPermissions.expensesEdit);
  bool get canDeleteAttachment => PermissionService.to.can(AppPermissions.expensesDelete);

  @override
  void onInit() {
    super.onInit();
    initializeNetworks();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchTextController.dispose();
    super.onClose();
  }

  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      searchQuery.value = value.trim();
      loadExpenses(refresh: true);
    });
  }

  Future<void> initializeNetworks() async {
    final version = ++_networkVersion;
    ++_listVersion;
    isLoadingNetworks.value = true;
    networkError.value = null;
    try {
      final result = await getMyNetworksUseCase();
      if (version != _networkVersion) return;
      final ids = <int>{};
      final unique = result.where((n) => n.networkId > 0 && ids.add(n.networkId)).toList();
      networks.assignAll(unique);
      if (unique.length == 1) {
      await selectNetwork(unique.single.networkId);
    }
    } catch (e) {
      if (version == _networkVersion) {
        networkError.value = AppException.sanitizeMessage(e, fallback: 'تعذر تحميل الشبكات المصرح بها.');
      }
    } finally {
      if (version == _networkVersion) isLoadingNetworks.value = false;
    }
  }

  Future<void> selectNetwork(int id) async {
    if (!networks.any((n) => n.networkId == id) || selectedNetworkId.value == id) return;
    selectedNetworkId.value = id;
    expenses.clear(); _cursor = null; _loaded = false;
    await loadExpenses(refresh: true);
  }

  Future<void> loadExpenses({bool refresh = false}) async {
    final networkId = selectedNetworkId.value;
    if (networkId == null) return;
    if (!refresh && (isLoading.value || isLoadingMore.value || !_loaded || !hasMore)) return;
    final version = ++_listVersion;
    if (refresh) {
      _cursor = null; error.value = null; loadMoreError.value = null; isLoading.value = true;
    } else {
      isLoadingMore.value = true; loadMoreError.value = null;
    }
    try {
      final PaginatedList<ExpenseEntity> page = await getExpensesUseCase(
        networkId: networkId,
        search: searchQuery.value,
        fromDate: fromDate.value == null ? null : _date(fromDate.value!),
        toDate: toDate.value == null ? null : _date(toDate.value!),
        cursor: refresh ? null : _cursor,
      );
      if (version != _listVersion || selectedNetworkId.value != networkId) return;
      if (refresh) {
        expenses.assignAll(page.items);
      } else {
        final ids = expenses.map((e) => e.expenseId).toSet();
        expenses.addAll(page.items.where((e) => ids.add(e.expenseId)));
      }
      _cursor = page.nextCursor;
      _loaded = true;
    } catch (e) {
      if (version != _listVersion) return;
      final message = AppException.sanitizeMessage(
        e,
        fallback: 'تعذر تحميل المصروفات.',
      );
      if (refresh) {
        error.value = message;
      } else {
        loadMoreError.value = message;
      }
    } finally {
      if (version == _listVersion) {
        isLoading.value = false;
        isLoadingMore.value = false;
      }
    }
  }

  Future<void> applyFilters({String? search, DateTime? from, DateTime? to}) async {
    searchQuery.value = search?.trim() ?? searchQuery.value;
    fromDate.value = from; toDate.value = to;
    await loadExpenses(refresh: true);
  }

  Future<void> loadDetails(int id) async {
    final version = ++_detailVersion;
    isLoadingDetails.value = true; selectedExpense.value = null;
    try {
      final result = await getExpenseDetailsUseCase(id);
      if (version == _detailVersion) {
        selectedExpense.value = result;
      }
    } catch (e) {
      if (version == _detailVersion) {
        CustomSnackbar.show(
          title: 'تعذر تحميل المصروف',
          message: AppException.sanitizeMessage(
            e,
            fallback: 'حاول مجدداً.',
          ),
          type: SnackType.error,
        );
      }
    } finally {
      if (version == _detailVersion) {
        isLoadingDetails.value = false;
      }
    }
  }

  Future<bool> saveExpense({int? expenseId, required DateTime date, required List<Map<String, dynamic>> items}) async {
    final networkId = selectedNetworkId.value;
    if (networkId == null || isSaving.value) return false;
    if (items.isEmpty || items.any((i) => (i['item_statement'] as String? ?? '').trim().isEmpty || (double.tryParse(i['item_amount'].toString()) ?? 0) <= 0)) {
      CustomSnackbar.show(title: 'بيانات غير مكتملة', message: 'أدخل وصفاً ومبلغاً صحيحاً لكل بند.', type: SnackType.warning);
      return false;
    }
    isSaving.value = true;
    await CustomAnimationOverlay.showLoading(message: expenseId == null ? 'جاري تسجيل المصروف...' : 'جاري تحديث المصروف...');
    try {
      if (expenseId == null) {
        await createExpenseUseCase(networkId: networkId, expenseDate: _date(date), items: items, attachments: formAttachments.toList());
      } else {
        await updateExpenseUseCase(expenseId: expenseId, networkId: networkId, expenseDate: _date(date), items: items, attachments: formAttachments.toList());
      }
      formAttachments.clear();
      await loadExpenses(refresh: true);
      if (CustomAnimationOverlay.isShowing) await CustomAnimationOverlay.hide();
      await CustomAnimationOverlay.showSuccess(message: expenseId == null ? 'تم تسجيل المصروف بنجاح' : 'تم تحديث المصروف بنجاح');
      return true;
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) await CustomAnimationOverlay.hide();
      CustomSnackbar.show(title: 'تعذر حفظ المصروف', message: AppException.sanitizeMessage(e, fallback: 'حاول مجدداً.'), type: SnackType.error);
      return false;
    } finally {
      isSaving.value = false;
      if (CustomAnimationOverlay.isShowing) await CustomAnimationOverlay.hide();
    }
  }

  Future<void> deleteAttachment(int attachmentId) async {
    final expense = selectedExpense.value;
    if (expense == null || !canDeleteAttachment) return;
    try {
      await deleteExpenseAttachmentUseCase(expenseId: expense.expenseId, attachmentId: attachmentId);
      await loadDetails(expense.expenseId);
    } catch (e) {
      CustomSnackbar.show(title: 'تعذر حذف المرفق', message: AppException.sanitizeMessage(e, fallback: 'حاول مجدداً.'), type: SnackType.error);
    }
  }

  static String _date(DateTime date) => '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
