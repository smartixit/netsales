import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/usecases/delete_expense_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/expense_document_use_case.dart';
import 'package:netsales/features/expenses/domain/usecases/get_expense_details_use_case.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم شاشة تفاصيل المصروف التشغيلي (Network Expense Details Controller)
class NetworkExpenseDetailsController extends GetxController {
  NetworkExpenseDetailsController({
    required this.getExpenseDetailsUseCase,
    required this.deleteExpenseUseCase,
    required this.expenseDocumentUseCase,
  });

  final GetExpenseDetailsUseCase getExpenseDetailsUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;
  final ExpenseDocumentUseCase expenseDocumentUseCase;

  final expense = Rxn<ExpenseEntity>();
  final isLoading = true.obs;
  final isExporting = false.obs;
  final errorMessage = RxnString();

  int? expenseId;

  bool get canDeleteExpense =>
      PermissionService.to.can(AppPermissions.expensesDelete);

  bool get canEditExpense =>
      PermissionService.to.can(AppPermissions.expensesEdit);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is int) {
      expenseId = args;
    } else if (args is ExpenseEntity) {
      expenseId = args.expenseId;
      expense.value = args;
      isLoading.value = false;
    }

    if (expenseId != null) {
      loadDetails();
    } else {
      isLoading.value = false;
      errorMessage.value = 'لم يتم تحديد معرف المصروف المطلوب.';
    }
  }

  /// إعادة تحميل بيانات التفاصيل
  Future<void> refreshDetails() => loadDetails();

  /// جلب تفاصيل المصروف من الخادم
  Future<void> loadDetails() async {
    if (expenseId == null) return;
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await getExpenseDetailsUseCase(expenseId!);
      expense.value = result;
    } catch (e) {
      errorMessage.value = AppException.sanitizeMessage(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// تصدير وحفظ سند الصرف كـ PDF
  Future<void> exportPdf() async {
    final exp = expense.value;
    if (exp == null) return;

    isExporting.value = true;
    try {
      final success = await expenseDocumentUseCase.exportAndSave(exp);
      if (success) {
        CustomSnackbar.show(
          title: 'تم التصدير بنجاح',
          message: 'تم حفظ سند صرف المصروف في مجلد المستندات.',
          type: SnackType.success,
        );
      } else {
        CustomSnackbar.show(
          title: 'فشل التصدير',
          message: 'تعذر حفظ ملف سند الصرف.',
          type: SnackType.error,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'فشل التصدير',
        message: AppException.sanitizeMessage(e.toString()),
        type: SnackType.error,
      );
    } finally {
      isExporting.value = false;
    }
  }

  /// مشاركة ملف سند الصرف
  Future<void> sharePdf() async {
    final exp = expense.value;
    if (exp == null) return;

    isExporting.value = true;
    try {
      await expenseDocumentUseCase.share(exp);
    } catch (e) {
      CustomSnackbar.show(
        title: 'فشل المشاركة',
        message: AppException.sanitizeMessage(e.toString()),
        type: SnackType.error,
      );
    } finally {
      isExporting.value = false;
    }
  }

  /// طباعة سند الصرف
  Future<void> printPdf() async {
    final exp = expense.value;
    if (exp == null) return;

    try {
      await expenseDocumentUseCase.print(exp);
    } catch (e) {
      CustomSnackbar.show(
        title: 'فشل الطباعة',
        message: AppException.sanitizeMessage(e.toString()),
        type: SnackType.error,
      );
    }
  }

  /// حذف المصروف مع العكس المالي
  Future<void> deleteExpense() async {
    if (expenseId == null) return;

    try {
      await deleteExpenseUseCase(expenseId!);
      CustomSnackbar.show(
        title: 'تم الحذف بنجاح',
        message: 'تم حذف المصروف واسترجاع المبلغ لمحفظة الشبكة.',
        type: SnackType.success,
      );
      Get.back(result: true);
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر حذف المصروف',
        message: AppException.sanitizeMessage(e.toString()),
        type: SnackType.error,
      );
    }
  }
}
