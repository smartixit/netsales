import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/file_picker_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/usecases/create_expense_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expense_details_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/update_expense_use_case.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// سطر بند المصروف داخل نموذج الإدخال
class ExpenseFormLineItem {
  ExpenseFormLineItem({
    required this.id,
    String initialStatement = '',
    String initialAmount = '',
  })  : statementController = TextEditingController(text: initialStatement),
        amountController = TextEditingController(text: initialAmount);

  final String id;
  final TextEditingController statementController;
  final TextEditingController amountController;

  void dispose() {
    statementController.dispose();
    amountController.dispose();
  }
}

/// متحكم إنشاء وتعديل المصروف التشغيلي (Network Expense Form Controller)
class NetworkExpenseFormController extends GetxController {
  NetworkExpenseFormController({
    required this.createExpenseUseCase,
    required this.updateExpenseUseCase,
    required this.getExpenseDetailsUseCase,
    this.getMyNetworksUseCase,
  });

  final CreateExpenseUseCase createExpenseUseCase;
  final UpdateExpenseUseCase updateExpenseUseCase;
  final GetExpenseDetailsUseCase getExpenseDetailsUseCase;
  final GetMyNetworksUseCase? getMyNetworksUseCase;

  // ── وضع الشاشة (إنشاء أو تعديل) ──
  final isEditMode = false.obs;
  int? expenseId;

  // ── الحقول والتحكم ──
  final selectedNetworkId = RxnInt();
  final authorizedNetworks = <NetworkEntity>[].obs;
  final selectedDate = Rx<DateTime>(DateTime.now());

  // ── بنود المصروف الديناميكية ──
  final lineItems = <ExpenseFormLineItem>[].obs;

  // ── المرفقات المحلية الجديدة ──
  final attachmentPaths = <String>[].obs;

  // ── حالات التحميل ──
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  // ── الحساب اللحظي الإرشادي ──
  final estimatedTotal = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is int) {
      expenseId = args;
      isEditMode.value = true;
    } else if (args is ExpenseEntity) {
      expenseId = args.expenseId;
      isEditMode.value = true;
    }

    _initForm();
  }

  @override
  void onClose() {
    for (final item in lineItems) {
      item.dispose();
    }
    super.onClose();
  }

  Future<void> _initForm() async {
    isLoading.value = true;

    // 1. جلب الشبكات المرخصة
    if (getMyNetworksUseCase != null) {
      try {
        final networks = await getMyNetworksUseCase!();
        authorizedNetworks.assignAll(networks);
        final networkIds =
            networks.map((n) => n.networkId).toList(growable: false);
        final resolvedId =
            WorkspaceService.to.resolveActiveNetworkId(networkIds);
        selectedNetworkId.value = resolvedId;
      } catch (_) {
        // الاستمرار
      }
    }

    // 2. إذا كان في وضع التعديل، تحميل بيانات المصروف القائم
    if (isEditMode.value && expenseId != null) {
      try {
        final expense = await getExpenseDetailsUseCase(expenseId!);
        selectedNetworkId.value = expense.networkId;
        if (expense.expenseDate != null) {
          selectedDate.value = expense.expenseDate!;
        }

        lineItems.clear();
        for (final it in expense.items) {
          _addLineItem(
            statement: it.itemStatement,
            amount: it.itemAmount > 0 ? it.itemAmount.toStringAsFixed(2) : '',
          );
        }
      } catch (e) {
        CustomSnackbar.show(
          title: 'تعذر تحميل بيانات المصروف',
          message: AppException.sanitizeMessage(e.toString()),
          type: SnackType.error,
        );
      }
    }

    // إذا لم يكن هناك بنود بعد، أضف بنداً فارغاً افتراضياً
    if (lineItems.isEmpty) {
      _addLineItem();
    }

    _calculateTotal();
    isLoading.value = false;
  }

  void _addLineItem({String statement = '', String amount = ''}) {
    final line = ExpenseFormLineItem(
      id: UniqueKey().toString(),
      initialStatement: statement,
      initialAmount: amount,
    );

    line.amountController.addListener(_calculateTotal);
    lineItems.add(line);
  }

  /// إضافة سطر بند مصروف جديد
  void addItem() {
    _addLineItem();
    _calculateTotal();
  }

  /// حذف سطر بند
  void removeItem(int index) {
    if (lineItems.length <= 1) {
      CustomSnackbar.show(
        title: 'تنبيه',
        message: 'يجب أن يحتوي المصروف على بند واحد على الأقل.',
        type: SnackType.warning,
      );
      return;
    }

    final removed = lineItems.removeAt(index);
    removed.amountController.removeListener(_calculateTotal);
    removed.dispose();
    _calculateTotal();
  }

  /// حساب الإجمالي اللحظي التقديري
  void _calculateTotal() {
    double sum = 0.0;
    for (final line in lineItems) {
      final val = double.tryParse(line.amountController.text.trim()) ?? 0.0;
      sum += val;
    }
    estimatedTotal.value = sum;
  }

  /// اختيار تاريخ المصروف
  void setDate(DateTime date) {
    selectedDate.value = date;
  }

  /// اختيار مرفقات محلية من الذاكرة
  Future<void> pickAttachments() async {
    try {
      final pickedFiles = await FilePickerService.instance.pickMultiFiles();
      if (pickedFiles.isNotEmpty) {
        final paths = pickedFiles
            .map((f) => f.path)
            .whereType<String>()
            .where((p) => p.isNotEmpty)
            .toList();
        for (final p in paths) {
          if (!attachmentPaths.contains(p)) {
            attachmentPaths.add(p);
          }
        }
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'فشل اختيار المرفق',
        message: e.toString(),
        type: SnackType.error,
      );
    }
  }

  /// إزالة مرفق محدد من القائمة المحلية
  void removeAttachment(String path) {
    attachmentPaths.remove(path);
  }

  /// إرسال النموذج وحفظ المصروف
  Future<void> submit() async {
    final netId = selectedNetworkId.value;
    if (netId == null) {
      CustomSnackbar.show(
        title: 'بيانات غير مكتملة',
        message: 'يرجى اختيار الشبكة التابع لها المصروف.',
        type: SnackType.warning,
      );
      return;
    }

    final itemsPayload = <Map<String, dynamic>>[];
    for (var i = 0; i < lineItems.length; i++) {
      final line = lineItems[i];
      final st = line.statementController.text.trim();
      final am = double.tryParse(line.amountController.text.trim());

      if (st.isEmpty && (am == null || am == 0)) {
        continue;
      }

      if (st.isEmpty) {
        CustomSnackbar.show(
          title: 'بيان البند مفقود',
          message: 'يرجى إدخال بيان المصروف للبند رقم ${i + 1}.',
          type: SnackType.warning,
        );
        return;
      }

      if (am == null || am <= 0) {
        CustomSnackbar.show(
          title: 'مبلغ غير صحيح',
          message: 'يرجى إدخال مبلغ صحيح وأكبر من الصفر للبند رقم ${i + 1}.',
          type: SnackType.warning,
        );
        return;
      }

      itemsPayload.add({
        'item_statement': st,
        'item_amount': am,
      });
    }

    if (itemsPayload.isEmpty) {
      CustomSnackbar.show(
        title: 'البنود فارغة',
        message: 'يرجى إدخال بند واحد على الأقل مع البيان والمبلغ.',
        type: SnackType.warning,
      );
      return;
    }

    final dateStr =
        '${selectedDate.value.year}-${selectedDate.value.month.toString().padLeft(2, '0')}-${selectedDate.value.day.toString().padLeft(2, '0')}';

    isSubmitting.value = true;
    try {
      if (isEditMode.value && expenseId != null) {
        await updateExpenseUseCase(
          expenseId: expenseId!,
          expenseDate: dateStr,
          items: itemsPayload,
          attachmentPaths: attachmentPaths,
        );
        CustomSnackbar.show(
          title: 'تم التحديث بنجاح',
          message: 'تم تحديث بيانات المصروف وتسوية المحفظة بنجاح.',
          type: SnackType.success,
        );
      } else {
        await createExpenseUseCase(
          networkId: netId,
          expenseDate: dateStr,
          items: itemsPayload,
          attachmentPaths: attachmentPaths,
        );
        CustomSnackbar.show(
          title: 'تم تسجيل المصروف بنجاح',
          message: 'تم تسجيل المصروف وخصم المبلغ من محفظة الشبكة بنجاح.',
          type: SnackType.success,
        );
      }

      Get.back(result: true);
    } catch (e) {
      CustomSnackbar.show(
        title: isEditMode.value ? 'فشل تحديث المصروف' : 'فشل تسجيل المصروف',
        message: AppException.sanitizeMessage(e.toString()),
        type: SnackType.error,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
