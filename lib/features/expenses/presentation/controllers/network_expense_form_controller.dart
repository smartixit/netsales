import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/app_picked_file_model.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/utils/idempotency_helper.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/entities/new_expense_item_input_entity.dart';
import 'package:netsales/features/expenses/domain/usecases/create_expense_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/update_expense_use_case.dart';
import 'package:netsales/features/expenses/presentation/controllers/expense_details_controller.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_expenses_controller.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم نموذج تسجيل وتعديل المصروفات التشغيلية (NetworkExpenseFormController)
///
/// يدير بنود المصروف ومرفقاته مباشرة عبر وحدات التحكم النصية [statementControllers] و [amountControllers]
/// بدون أي كلاسات إضافية، متوافقاً تماماً مع أسلوب متحكمات الطلبات والفواتير.
class NetworkExpenseFormController extends GetxController {
  NetworkExpenseFormController({
    required this.createExpenseUseCase,
    required this.updateExpenseUseCase,
  });

  final CreateExpenseUseCase createExpenseUseCase;
  final UpdateExpenseUseCase updateExpenseUseCase;

  final formKey = GlobalKey<FormState>();

  // حالة وضع التعديل (Edit Mode)
  final isEditing = false.obs;
  final editingExpenseId = RxnInt();
  final initialExpense = Rxn<ExpenseEntity>();

  bool get isEditMode => isEditing.value;

  // وحدات التحكم النصية لبنود المصروف (Statement & Amount Controllers)
  final statementControllers = <TextEditingController>[].obs;
  final amountControllers = <TextEditingController>[].obs;

  // المرفقات والتاريخ وحالة الإرسال والإجمالي
  final attachments = <AppPickedFileModel>[].obs;
  final selectedDate = DateTime.now().obs;
  final isSubmitting = false.obs;
  final totalAmount = 0.0.obs;

  int? get activeNetworkId {
    if (initialExpense.value != null) {
      return initialExpense.value!.networkId;
    }
    if (Get.isRegistered<WorkspaceService>()) {
      return WorkspaceService.to.savedActiveNetworkId;
    }
    return null;
  }

  bool get canSubmit {
    if (isSubmitting.value) return false;
    if (activeNetworkId == null) return false;
    if (statementControllers.isEmpty) return false;
    for (int i = 0; i < statementControllers.length; i++) {
      if (statementControllers[i].text.trim().isEmpty) return false;
      final amt = double.tryParse(amountControllers[i].text.trim()) ?? 0.0;
      if (amt <= 0) return false;
    }
    return true;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ExpenseEntity) {
      _initFromExpense(args);
    } else if (args is Map) {
      if (args['expense'] is ExpenseEntity) {
        _initFromExpense(args['expense'] as ExpenseEntity);
      }
    } else {
      addItemRow();
    }
  }

  void _initFromExpense(ExpenseEntity exp) {
    isEditing.value = true;
    editingExpenseId.value = exp.expenseId;
    initialExpense.value = exp;
    if (exp.expenseDate != null) {
      selectedDate.value = exp.expenseDate!;
    }
    if (exp.items.isNotEmpty) {
      for (final item in exp.items) {
        addItemRow(
          statement: item.itemStatement,
          amount: item.itemAmount.toString(),
        );
      }
    } else {
      addItemRow();
    }
  }

  @override
  void onClose() {
    for (final ctrl in statementControllers) {
      ctrl.dispose();
    }
    for (final ctrl in amountControllers) {
      ctrl.dispose();
    }
    super.onClose();
  }

  /// إضافة سطر بند جديد للنموذج
  void addItemRow({String statement = '', String amount = ''}) {
    final sCtrl = TextEditingController(text: statement);
    final aCtrl = TextEditingController(text: amount);
    sCtrl.addListener(() => statementControllers.refresh());
    aCtrl.addListener(recalculateTotal);
    statementControllers.add(sCtrl);
    amountControllers.add(aCtrl);
    recalculateTotal();
  }

  /// إزالة سطر بند محدد
  void removeItemRow(int index) {
    if (statementControllers.length <= 1) return;
    statementControllers.removeAt(index).dispose();
    amountControllers.removeAt(index).dispose();
    recalculateTotal();
  }

  /// إعادة احتساب إجمالي مبلغ المصروف
  void recalculateTotal() {
    double sum = 0.0;
    for (final ctrl in amountControllers) {
      sum += double.tryParse(ctrl.text.trim()) ?? 0.0;
    }
    totalAmount.value = sum;
    statementControllers.refresh();
  }

  /// تحديث قائمة المرفقات من منتقي الملفات
  void onAttachmentsChanged(List<AppPickedFileModel> files) {
    attachments.assignAll(files);
  }

  /// تغيير تاريخ المصروف
  void setDate(DateTime date) {
    selectedDate.value = date;
  }

  /// إرسال وحفظ سند المصروف (إنشاء أو تعديل) مع تسوية المحفظة
  Future<void> submitExpense() async {
    final networkId = activeNetworkId;
    if (networkId == null) {
      CustomSnackbar.show(
        title: 'خطأ',
        message: 'لم يتم العثور على سياق شبكة نشط لإتمام عملية الصرف.',
        type: SnackType.error,
      );
      return;
    }

    if (!canSubmit) {
      CustomSnackbar.show(
        title: 'بيانات غير مكتملة',
        message: 'يرجى التأكد من ملء بيان ومبلغ صحيح لكافة بنود المصروف.',
        type: SnackType.warning,
      );
      return;
    }

    isSubmitting.value = true;

    try {
      final inputItems = <NewExpenseItemInputEntity>[];
      for (int i = 0; i < statementControllers.length; i++) {
        inputItems.add(
          NewExpenseItemInputEntity(
            itemStatement: statementControllers[i].text.trim(),
            itemAmount: double.tryParse(amountControllers[i].text.trim()) ?? 0.0,
          ),
        );
      }

      if (isEditing.value) {
        // وضع التعديل (Update Expense)
        final targetId =
            editingExpenseId.value ?? initialExpense.value!.expenseId;
        final updatedExpense = await updateExpenseUseCase(
          expenseId: targetId,
          expenseDate: selectedDate.value,
          items: inputItems,
          attachments: attachments.isNotEmpty ? attachments.toList() : null,
        );

        if (Get.isRegistered<ExpenseDetailsController>()) {
          await Get.find<ExpenseDetailsController>().loadExpenseDetails(
            updatedExpense.expenseId,
          );
        }

        if (Get.isRegistered<NetworkExpensesController>()) {
          await Get.find<NetworkExpensesController>().loadExpenses(
            isRefresh: true,
          );
        }

        await CustomAnimationOverlay.showSuccess(
          message: 'تم تحديث المصروف (${updatedExpense.displayReference}) بنجاح',
        );

        Get.back(result: true);
      } else {
        // وضع الإنشاء الجديد (Create Expense)
        final idempotencyKey = IdempotencyHelper.forExpense(networkId);

        final createdExpense = await createExpenseUseCase(
          networkId: networkId,
          expenseDate: selectedDate.value,
          items: inputItems,
          attachments: attachments.isNotEmpty ? attachments.toList() : null,
          idempotencyKey: idempotencyKey,
        );

        if (Get.isRegistered<NetworkExpensesController>()) {
          await Get.find<NetworkExpensesController>().loadExpenses(
            isRefresh: true,
          );
        }

        await CustomAnimationOverlay.showSuccess(
          message: 'تم تسجيل المصروف (${createdExpense.displayReference})',
        );

        Get.back(result: true);
      }
    } catch (e) {
      CustomSnackbar.show(
        title: isEditing.value ? 'تعذر تحديث المصروف' : 'تعذر تسجيل المصروف',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
