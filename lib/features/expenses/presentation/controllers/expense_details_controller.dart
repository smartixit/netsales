import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/media_gallery_item_model.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/usecases/delete_expense_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/expense_document_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expense_details_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/media_gallery/media_gallery_viewer.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم تفاصيل المصروف التشغيلي ومرفقاته (ExpenseDetailsController)
///
/// يدير جلب بيانات المصروف، معاينة المستندات والمرفقات عبر المحرك الموحد [MediaGalleryViewer]،
/// والطباعة والمشاركة والحفظ في الجهاز والحذف المعتمد مع استرداد رصيد المحفظة.
class ExpenseDetailsController extends GetxController {
  ExpenseDetailsController({
    required this.getExpenseDetailsUseCase,
    required this.deleteExpenseUseCase,
    this.expenseDocumentUseCase,
  });

  final GetExpenseDetailsUseCase getExpenseDetailsUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;
  final ExpenseDocumentUseCase? expenseDocumentUseCase;

  final expense = Rxn<ExpenseEntity>();
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final isPrinting = false.obs;
  final isSharing = false.obs;
  final isExporting = false.obs;
  final isDeleting = false.obs;
  final isSaving = false.obs;
  final isAuditExpanded = false.obs;

  void toggleAuditExpanded() => isAuditExpanded.toggle();

  int? _expenseId;

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

  void onEditCurrentExpense() {
    if (!canEditExpense) return;
    final exp = expense.value;
    if (exp == null) return;
    Get.toNamed<void>(
      AppRoutes.createOperatingExpense,
      arguments: {'expense': exp},
    );
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      if (args['expense'] is ExpenseEntity) {
        expense.value = args['expense'] as ExpenseEntity;
        _expenseId = expense.value?.expenseId;
      }
      if (args['expense_id'] is int) {
        _expenseId = args['expense_id'] as int;
      }
    }

    if (_expenseId != null) {
      loadExpenseDetails(_expenseId!);
    } else if (expense.value != null) {
      _expenseId = expense.value!.expenseId;
    }
  }

  /// جلب تفاصيل المصروف وتحديث حالته
  Future<void> loadExpenseDetails(int id) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await getExpenseDetailsUseCase(id);
      expense.value = result;
    } catch (e) {
      errorMessage.value = AppException.sanitizeMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// بناء عناصر المعرض الموحد [MediaGalleryItemModel] من مرفقات المصروف
  List<MediaGalleryItemModel> buildMediaGalleryItems() {
    final exp = expense.value;
    if (exp == null || exp.attachments.isEmpty) return [];

    return exp.attachments.map((att) {
      return MediaGalleryItemModel(
        url: att.fileUrl ?? '',
        title: att.attachmentName,
        subtitle: att.formattedSize,
        heroTag: 'expense_att_${att.attachmentId}',
      );
    }).toList();
  }

  /// فتح المرفق في المعرض التفاعلي الموحد عبر [MediaGalleryViewer]
  void openAttachment(BuildContext context, int index) {
    final items = buildMediaGalleryItems();
    if (items.isEmpty) return;

    MediaGalleryViewer.show(
      context,
      items: items,
      initialIndex: index,
      defaultTitle: 'مرفقات سند المصروف',
    );
  }

  /// طباعة سند المصروف مباشرة
  Future<void> printCurrentExpense() async {
    final exp = expense.value;
    if (exp == null) return;

    if (expenseDocumentUseCase == null) {
      CustomSnackbar.show(
        title: 'طباعة السند',
        message: 'خدمة الطباعة غير متوفرة.',
        type: SnackType.warning,
      );
      return;
    }

    isPrinting.value = true;
    try {
      await expenseDocumentUseCase!.printExpense(exp);
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر الطباعة',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    } finally {
      isPrinting.value = false;
    }
  }

  /// مشاركة سند المصروف كملف PDF
  Future<void> shareCurrentExpense() async {
    final exp = expense.value;
    if (exp == null) return;

    if (expenseDocumentUseCase == null) {
      CustomSnackbar.show(
        title: 'مشاركة السند',
        message: 'خدمة المشاركة غير متوفرة.',
        type: SnackType.warning,
      );
      return;
    }

    isSharing.value = true;
    try {
      await expenseDocumentUseCase!.shareExpense(exp);
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر المشاركة',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    } finally {
      isSharing.value = false;
    }
  }

  /// تصدير وحفظ سند المصروف كملف PDF في ذاكرة الجهاز
  Future<void> saveCurrentExpense() async {
    final exp = expense.value;
    if (exp == null) return;

    if (expenseDocumentUseCase == null) {
      CustomSnackbar.show(
        title: 'حفظ السند',
        message: 'خدمة حفظ الملفات غير متوفرة.',
        type: SnackType.warning,
      );
      return;
    }

    isSaving.value = true;
    try {
      final success = await expenseDocumentUseCase!.saveExpense(exp);
      if (success) {
        CustomSnackbar.show(
          title: 'تم الحفظ بنجاح',
          message: 'تم حفظ ملف PDF لسند المصروف في جهازك بنجاح.',
          type: SnackType.success,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر حفظ السند',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    } finally {
      isSaving.value = false;
    }
  }

  /// تأكيد وحذف المصروف واسترداد مبلغه للمحفظة
  Future<void> confirmDelete(BuildContext context) async {
    if (!canDeleteExpense) return;
    final exp = expense.value;
    if (exp == null) return;

    final confirmed = await CustomDialog.show(
      type: DialogType.danger,
      title: 'حذف سند المصروف',
      message:
          'هل أنت متأكد من حذف سند المصروف رقم (${exp.displayReference}) بمبلغ ${AmountFormatter.formatValue(exp.expenseTotalAmount)} ر.ي؟\nسيتم استرداد المبلغ وإيداعه في محفظة الشبكة.',
      confirmLabel: 'نعم، حذف واسترداد',
      cancelLabel: 'إلغاء',
    );

    if (confirmed != true) return;

    isDeleting.value = true;
    try {
      await deleteExpenseUseCase(exp.expenseId);
      CustomSnackbar.show(
        title: 'تم الحذف بنجاح',
        message: 'تم حذف سند المصروف واسترداد مبلغه لمحفظة الشبكة بنجاح.',
        type: SnackType.success,
      );
      Get.back(result: true);
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر حذف المصروف',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    } finally {
      isDeleting.value = false;
    }
  }
}
