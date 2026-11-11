import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/app_picked_file_model.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/usecases/create_expense_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/delete_expense_attachment_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/delete_expense_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expense_details_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expenses_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/update_expense_use_case.dart';
import 'package:netsales/features/expenses/presentation/screens/network_expense_details_screen.dart';
import 'package:netsales/features/expenses/presentation/screens/network_expense_form_screen.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

class ExpenseFormItemEntry {
  ExpenseFormItemEntry({
    String initialStatement = '',
    String initialAmount = '',
  })  : statementController = TextEditingController(text: initialStatement),
        amountController = TextEditingController(text: initialAmount);

  final TextEditingController statementController;
  final TextEditingController amountController;

  void dispose() {
    statementController.dispose();
    amountController.dispose();
  }
}

class NetworkOperatingExpensesController extends GetxController {
  NetworkOperatingExpensesController({
    required this.getMyNetworksUseCase,
    required this.getExpensesUseCase,
    required this.getExpenseDetailsUseCase,
    required this.createExpenseUseCase,
    required this.updateExpenseUseCase,
    required this.deleteExpenseAttachmentUseCase,
    required this.deleteExpenseUseCase,
  });

  final GetMyNetworksUseCase getMyNetworksUseCase;
  final GetExpensesUseCase getExpensesUseCase;
  final GetExpenseDetailsUseCase getExpenseDetailsUseCase;
  final CreateExpenseUseCase createExpenseUseCase;
  final UpdateExpenseUseCase updateExpenseUseCase;
  final DeleteExpenseAttachmentUseCase deleteExpenseAttachmentUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;

  // ── القائمة والبحث والفلترة ──
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

  // ── شاشة التفاصيل ──
  final selectedExpense = Rxn<ExpenseEntity>();
  final isLoadingDetails = false.obs;

  // ── إدارة حالة الفورم التفاعلية ──
  final formKey = GlobalKey<FormState>();
  final editingExpenseId = RxnInt();
  final formDate = Rx<DateTime>(DateTime.now());
  final formItems = <ExpenseFormItemEntry>[].obs;
  final formAttachments = <AppPickedFileModel>[].obs;
  final isSaving = false.obs;

  String? _cursor;
  int _listVersion = 0;
  int _networkVersion = 0;
  int _detailVersion = 0;
  bool _loaded = false;
  Timer? _searchDebounce;

  bool get hasMore => _cursor?.trim().isNotEmpty ?? false;
  bool get hasSelectedNetwork => selectedNetworkId.value != null;
  bool get isEditingForm => editingExpenseId.value != null;

  bool get canCreate => PermissionService.to.can(AppPermissions.expensesCreate);
  bool get canEdit => PermissionService.to.can(AppPermissions.expensesEdit);
  bool get canDelete => PermissionService.to.can(AppPermissions.expensesDelete);
  bool get canDeleteAttachment =>
      PermissionService.to.can(AppPermissions.expensesDelete);

  @override
  void onInit() {
    super.onInit();
    initializeNetworks();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchTextController.dispose();
    for (final item in formItems) {
      item.dispose();
    }
    super.onClose();
  }

  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
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
      final unique = result
          .where((n) => n.networkId > 0 && ids.add(n.networkId))
          .toList();
      networks.assignAll(unique);

      final networkIds = unique.map((n) => n.networkId).toList(growable: false);
      final resolvedId = WorkspaceService.to.resolveActiveNetworkId(networkIds);
      if (resolvedId != null) {
        await selectNetwork(resolvedId);
      }
    } catch (e) {
      if (version == _networkVersion) {
        networkError.value = AppException.sanitizeMessage(
          e,
          fallback: 'تعذر تحميل الشبكات المصرح بها.',
        );
      }
    } finally {
      if (version == _networkVersion) isLoadingNetworks.value = false;
    }
  }

  Future<void> selectNetwork(int id) async {
    if (!networks.any((n) => n.networkId == id) ||
        selectedNetworkId.value == id) {
      return;
    }
    selectedNetworkId.value = id;
    await WorkspaceService.to.saveActiveNetworkId(id);
    expenses.clear();
    _cursor = null;
    _loaded = false;
    await loadExpenses(refresh: true);
  }

  Future<void> loadExpenses({bool refresh = false}) async {
    final networkId = selectedNetworkId.value;
    if (networkId == null) return;
    if (!refresh &&
        (isLoading.value || isLoadingMore.value || !_loaded || !hasMore)) {
      return;
    }
    final version = ++_listVersion;
    if (refresh) {
      _cursor = null;
      error.value = null;
      loadMoreError.value = null;
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
      loadMoreError.value = null;
    }
    try {
      final PaginatedList<ExpenseEntity> page = await getExpensesUseCase(
        networkId: networkId,
        search: searchQuery.value,
        fromDate: fromDate.value == null ? null : _date(fromDate.value!),
        toDate: toDate.value == null ? null : _date(toDate.value!),
        cursor: refresh ? null : _cursor,
      );
      if (version != _listVersion || selectedNetworkId.value != networkId) {
        return;
      }
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

  Future<void> applyFilters({
    String? search,
    DateTime? from,
    DateTime? to,
  }) async {
    searchQuery.value = search?.trim() ?? searchQuery.value;
    fromDate.value = from;
    toDate.value = to;
    await loadExpenses(refresh: true);
  }

  Future<void> loadDetails(int id) async {
    final version = ++_detailVersion;
    isLoadingDetails.value = true;
    selectedExpense.value = null;
    try {
      final result = await getExpenseDetailsUseCase(id);
      if (version == _detailVersion) {
        selectedExpense.value = result;
      }
    } catch (e) {
      if (version == _detailVersion) {
        CustomSnackbar.show(
          title: 'تعذر تحميل المصروف',
          message: AppException.sanitizeMessage(e, fallback: 'حاول مجدداً.'),
          type: SnackType.error,
        );
      }
    } finally {
      if (version == _detailVersion) {
        isLoadingDetails.value = false;
      }
    }
  }

  // ── تهيئة وإدارة نموذج المصروفات التفاعلي بالكامل (GetX) ──
  void navigateToCreateForm() {
    prepareCreateForm();
    Get.to<void>(() => const NetworkExpenseFormScreen());
  }

  void navigateToEditForm(ExpenseEntity expense) {
    prepareEditForm(expense);
    Get.to<void>(() => const NetworkExpenseFormScreen());
  }

  void navigateToDetails(int expenseId) {
    loadDetails(expenseId);
    Get.to<void>(
      () => NetworkExpenseDetailsScreen(expenseId: expenseId),
    );
  }

  Future<void> saveExpenseAndClose() async {
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      return;
    }
    final success = await submitExpenseForm();
    if (success) {
      Get.back<void>();
    }
  }

  void prepareCreateForm() {
    editingExpenseId.value = null;
    formDate.value = DateTime.now();
    for (final item in formItems) {
      item.dispose();
    }
    formItems.assignAll([ExpenseFormItemEntry()]);
    formAttachments.clear();
  }

  void prepareEditForm(ExpenseEntity expense) {
    editingExpenseId.value = expense.expenseId;
    formDate.value =
        DateTime.tryParse(expense.expenseDate ?? '') ?? DateTime.now();
    for (final item in formItems) {
      item.dispose();
    }
    if (expense.items.isEmpty) {
      formItems.assignAll([ExpenseFormItemEntry()]);
    } else {
      formItems.assignAll(
        expense.items.map(
          (i) => ExpenseFormItemEntry(
            initialStatement: i.statement,
            initialAmount: i.amount.toString(),
          ),
        ),
      );
    }
    formAttachments.clear();
  }

  void setFormDate(DateTime date) {
    formDate.value = date;
  }

  void addFormItem() {
    formItems.add(ExpenseFormItemEntry());
  }

  void removeFormItem(int index) {
    if (formItems.length > 1 && index >= 0 && index < formItems.length) {
      final item = formItems.removeAt(index);
      item.dispose();
    }
  }

  void setFormAttachments(List<AppPickedFileModel> files) {
    formAttachments.assignAll(files);
  }

  Future<bool> submitExpenseForm() async {
    final networkId = selectedNetworkId.value;
    if (networkId == null || isSaving.value) return false;

    if (formItems.isEmpty) {
      CustomSnackbar.show(
        title: 'بنود المصروف مفقودة',
        message: 'أضف بنداً واحداً على الأقل للمصروف.',
        type: SnackType.warning,
      );
      return false;
    }

    final hasInvalid = formItems.any((item) {
      final stmt = item.statementController.text.trim();
      final val = double.tryParse(item.amountController.text.trim()) ?? 0;
      return stmt.isEmpty || val <= 0;
    });

    if (hasInvalid) {
      CustomSnackbar.show(
        title: 'بيانات غير مكتملة',
        message: 'أدخل وصفاً ومبلغاً صالحاً أكبر من صفر لكل بند.',
        type: SnackType.warning,
      );
      return false;
    }

    final payload = formItems
        .map(
          (i) => {
            'item_statement': i.statementController.text.trim(),
            'item_amount': i.amountController.text.trim(),
          },
        )
        .toList();

    isSaving.value = true;
    final isEdit = isEditingForm;
    final expId = editingExpenseId.value;

    await CustomAnimationOverlay.showLoading(
      message: isEdit ? 'جاري تحديث المصروف...' : 'جاري تسجيل المصروف...',
    );

    try {
      if (isEdit && expId != null) {
        await updateExpenseUseCase(
          expenseId: expId,
          expenseDate: _date(formDate.value),
          items: payload,
          attachments: formAttachments.toList(),
        );
      } else {
        await createExpenseUseCase(
          networkId: networkId,
          expenseDate: _date(formDate.value),
          items: payload,
          attachments: formAttachments.toList(),
        );
      }

      formAttachments.clear();
      await loadExpenses(refresh: true);
      if (isEdit && expId != null) {
        await loadDetails(expId);
      }

      if (CustomAnimationOverlay.isShowing) await CustomAnimationOverlay.hide();
      await CustomAnimationOverlay.showSuccess(
        message: isEdit ? 'تم تحديث المصروف بنجاح' : 'تم تسجيل المصروف بنجاح',
      );
      return true;
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'تعذر حفظ المصروف',
        message: AppException.sanitizeMessage(e, fallback: 'حاول مجدداً.'),
        type: SnackType.error,
      );
      return false;
    } finally {
      isSaving.value = false;
      if (CustomAnimationOverlay.isShowing) await CustomAnimationOverlay.hide();
    }
  }

  // ── حذف المرفق المنفرد بعد التأكيد الصريح ──
  Future<void> confirmAndDeleteAttachment(ExpenseAttachmentEntity attachment) async {
    final expense = selectedExpense.value;
    if (expense == null || !canDeleteAttachment) return;

    final confirmed = await CustomDialog.show(
      type: DialogType.danger,
      title: 'حذف المرفق',
      message:
          'هل أنت متأكد من حذف المرفق "${attachment.name}"؟ هذه العملية لا يمكن التراجع عنها وستحذف الملف نهائياً.',
      confirmLabel: 'حذف المرفق',
      cancelLabel: 'إلغاء',
    );

    if (confirmed != true) return;

    await CustomAnimationOverlay.showLoading(message: 'جاري حذف المرفق...');
    try {
      await deleteExpenseAttachmentUseCase(
        expenseId: expense.expenseId,
        attachmentId: attachment.attachmentId,
      );
      await loadDetails(expense.expenseId);
      if (CustomAnimationOverlay.isShowing) await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'تم الحذف',
        message: 'تم حذف المرفق بنجاح.',
        type: SnackType.success,
      );
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'تعذر حذف المرفق',
        message: AppException.sanitizeMessage(e, fallback: 'حاول مجدداً.'),
        type: SnackType.error,
      );
    } finally {
      if (CustomAnimationOverlay.isShowing) await CustomAnimationOverlay.hide();
    }
  }

  // ── حذف المصروف مؤقتاً (Soft Delete) بعد التأكيد الصريح ──
  Future<void> confirmAndDeleteExpense(int expenseId) async {
    if (!canDelete) return;

    final confirmed = await CustomDialog.show(
      type: DialogType.danger,
      title: 'حذف المصروف',
      message:
          'هل أنت متأكد من حذف سند المصروف رقم #$expenseId؟ سيتم نقل السجل إلى المهملات مع إمكانية استرجاعه لاحقاً.',
      confirmLabel: 'نقل إلى المهملات',
      cancelLabel: 'إلغاء',
    );

    if (confirmed != true) return;

    await CustomAnimationOverlay.showLoading(message: 'جاري حذف المصروف...');
    try {
      await deleteExpenseUseCase(expenseId);
      expenses.removeWhere((e) => e.expenseId == expenseId);
      if (selectedExpense.value?.expenseId == expenseId) {
        selectedExpense.value = null;
      }
      if (CustomAnimationOverlay.isShowing) await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'تم الحذف',
        message: 'تم نقل المصروف إلى المهملات بنجاح.',
        type: SnackType.success,
      );
      if (Get.currentRoute.contains('details')) {
        Get.back<void>();
      }
    } catch (e) {
      if (CustomAnimationOverlay.isShowing) await CustomAnimationOverlay.hide();
      CustomSnackbar.show(
        title: 'تعذر حذف المصروف',
        message: AppException.sanitizeMessage(e, fallback: 'حاول مجدداً.'),
        type: SnackType.error,
      );
    } finally {
      if (CustomAnimationOverlay.isShowing) await CustomAnimationOverlay.hide();
    }
  }

  static String _date(DateTime date) => DateFormatter.iso(date);
}
