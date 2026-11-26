import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/app_picked_file_model.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/utils/idempotency_helper.dart';
import 'package:netsales/features/expenses/domain/entities/expense_attachment_entity.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/entities/new_expense_item_input_entity.dart';
import 'package:netsales/features/expenses/domain/usecases/create_expense_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/update_expense_use_case.dart';
import 'package:netsales/features/expenses/presentation/controllers/expense_details_controller.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_expenses_controller.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/pickers/models/custom_existing_file_item.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم نموذج تسجيل وتعديل المصروفات التشغيلية (NetworkExpenseFormController)
///
/// يدير قائمة بنود المصروف التفاعلية [items] عبر ورقة الإضافة/التعديل السفلية،
/// والمرفقات الموجودة والجديدة، وحساب الإجمالي، وإرسال الطلب للخادم.
class NetworkExpenseFormController extends GetxController {
  NetworkExpenseFormController({
    required this.createExpenseUseCase,
    required this.updateExpenseUseCase,
  });

  final CreateExpenseUseCase createExpenseUseCase;
  final UpdateExpenseUseCase updateExpenseUseCase;

  final formKey = GlobalKey<FormState>();
  final sheetFormKey = GlobalKey<FormState>();

  final sheetStatementController = TextEditingController();
  final sheetAmountController = TextEditingController();
  final editingItemIndex = RxnInt();

  // حالة وضع التعديل (Edit Mode)
  final isEditing = false.obs;
  final editingExpenseId = RxnInt();
  final initialExpense = Rxn<ExpenseEntity>();

  bool get isEditMode => isEditing.value;
  bool get isEditingSheetItem => editingItemIndex.value != null;

  bool get canCreateExpense =>
      PermissionService.to.can(AppPermissions.expensesCreate);
  bool get canEditExpense =>
      PermissionService.to.can(AppPermissions.expensesEdit);

  // بنود المصروف التفاعلية
  final items = <NewExpenseItemInputEntity>[].obs;

  // المرفقات والتاريخ وحالة الإرسال والإجمالي
  final attachments = <AppPickedFileModel>[].obs;
  final existingAttachments = <ExpenseAttachmentEntity>[].obs;
  final deletedAttachmentIds = <int>[].obs;
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

  List<CustomExistingFileItem> get existingAttachmentItems =>
      existingAttachments
          .map(
            (att) => CustomExistingFileItem(
              id: att.attachmentId,
              name: att.attachmentName,
              url: att.fileUrl?? '',
              isImage: att.isImage,
              isPdf: att.isPdf,
              sizeLabel: att.formattedSize,
            ),
          )
          .toList();

  bool get canSubmit {
    if (isSubmitting.value) return false;
    if (isEditing.value ? !canEditExpense : !canCreateExpense) return false;
    if (activeNetworkId == null) return false;
    if (items.isEmpty) return false;
    for (final item in items) {
      if (item.itemStatement.trim().isEmpty || item.itemAmount <= 0) {
        return false;
      }
    }
    return true;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ExpenseEntity) {
      if (!canEditExpense) {
        Get.offNamed<void>(AppRoutes.unauthorized);
        return;
      }
      _initFromExpense(args);
    } else if (args is Map && args['expense'] is ExpenseEntity) {
      if (!canEditExpense) {
        Get.offNamed<void>(AppRoutes.unauthorized);
        return;
      }
      _initFromExpense(args['expense'] as ExpenseEntity);
    }
  }

  void _initFromExpense(ExpenseEntity exp) {
    isEditing.value = true;
    editingExpenseId.value = exp.expenseId;
    initialExpense.value = exp;
    existingAttachments.assignAll(exp.attachments);
    deletedAttachmentIds.clear();
    if (exp.expenseDate != null) {
      selectedDate.value = exp.expenseDate!;
    }
    items.assignAll(
      exp.items.map(
        (item) => NewExpenseItemInputEntity(
          itemStatement: item.itemStatement,
          itemAmount: item.itemAmount,
        ),
      ),
    );
    recalculateTotal();
  }

  @override
  void onClose() {
    sheetStatementController.dispose();
    sheetAmountController.dispose();
    super.onClose();
  }

  /// تهيئة حقول الورقة السفلية لإضافة بند جديد
  void prepareAddItemSheet() {
    editingItemIndex.value = null;
    sheetStatementController.clear();
    sheetAmountController.clear();
  }

  /// تهيئة حقول الورقة السفلية لتعديل بند موجود
  void prepareEditItemSheet(int index) {
    if (index < 0 || index >= items.length) return;
    final item = items[index];
    editingItemIndex.value = index;
    sheetStatementController.text = item.itemStatement;
    sheetAmountController.text = item.itemAmount.toString();
  }

  /// التحقق وحفظ البند من الورقة السفلية
  bool saveSheetItem() {
    if (!(sheetFormKey.currentState?.validate() ?? false)) {
      return false;
    }

    final statement = sheetStatementController.text.trim();
    final amount = double.tryParse(sheetAmountController.text.trim()) ?? 0.0;
    if (statement.isEmpty || amount <= 0) {
      return false;
    }

    final newItem = NewExpenseItemInputEntity(
      itemStatement: statement,
      itemAmount: amount,
    );

    final editIndex = editingItemIndex.value;
    if (editIndex != null && editIndex >= 0 && editIndex < items.length) {
      items[editIndex] = newItem;
    } else {
      items.add(newItem);
    }

    recalculateTotal();
    return true;
  }

  /// إزالة بند محدد
  void removeItem(int index) {
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
    recalculateTotal();
  }

  /// إعادة احتساب إجمالي مبلغ المصروف
  void recalculateTotal() {
    double sum = 0.0;
    for (final item in items) {
      sum += item.itemAmount;
    }
    totalAmount.value = sum;
  }

  /// تحديث قائمة المرفقات من منتقي الملفات
  void onAttachmentsChanged(List<AppPickedFileModel> files) {
    attachments.assignAll(files);
  }

  /// تغيير تاريخ المصروف
  void setDate(DateTime date) {
    selectedDate.value = date;
  }

  /// إزالة مرفق حالي مسجل ووسمه للحذف عند حفظ التعديلات (Pattern 1)
  void removeExistingAttachment(int attachmentId) {
    if (!deletedAttachmentIds.contains(attachmentId)) {
      deletedAttachmentIds.add(attachmentId);
    }
    existingAttachments.removeWhere((att) => att.attachmentId == attachmentId);
  }

  /// إرسال وحفظ سند المصروف (إنشاء أو تعديل) مع تسوية المحفظة
  Future<void> submitExpense() async {
    if (isEditing.value ? !canEditExpense : !canCreateExpense) return;
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
        message: 'يرجى إضافة بند واحد على الأقل بمبلغ وبيان صحيحين.',
        type: SnackType.warning,
      );
      return;
    }

    isSubmitting.value = true;

    try {
      final inputItems = items.toList();

      if (isEditing.value) {
        final targetId =
            editingExpenseId.value ?? initialExpense.value!.expenseId;
        final updatedExpense = await updateExpenseUseCase(
          expenseId: targetId,
          expenseDate: selectedDate.value,
          items: inputItems,
          attachments: attachments.isNotEmpty ? attachments.toList() : null,
          deletedAttachmentIds: deletedAttachmentIds.isNotEmpty
              ? deletedAttachmentIds.toList()
              : null,
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
          message:
              'تم تحديث المصروف (${updatedExpense.displayReference}) بنجاح',
        );

        Get.back(result: true);
      } else {
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
