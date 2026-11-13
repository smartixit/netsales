import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/usecases/invoice_document_use_case.dart';
import 'package:netsales/features/invoices/domain/usecases/get_invoice_details_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم شاشة تفاصيل الفاتورة المالية وعمليات التصدير والطباعة
class InvoiceDetailsController extends GetxController {
  final GetInvoiceDetailsUseCase getInvoiceDetailsUseCase;
  final InvoiceDocumentUseCase invoiceDocumentUseCase;

  InvoiceDetailsController({
    required this.getInvoiceDetailsUseCase,
    required this.invoiceDocumentUseCase,
  });

  final invoice = Rxn<InvoiceEntity>();
  final isLoading = false.obs;
  final isExporting = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is InvoiceEntity) {
      invoice.value = args;
      loadInvoiceDetails(args.invoiceId);
    } else if (args is int) {
      loadInvoiceDetails(args);
    }
  }

  /// تحميل تفاصيل الفاتورة بالكامل من الخادم
  Future<void> loadInvoiceDetails(int invoiceId) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final details = await getInvoiceDetailsUseCase(invoiceId);
      invoice.value = details;
    } on AppException catch (e) {
      errorMessage.value = e.message;
      CustomSnackbar.show(
        title: 'خطأ في جلب التفاصيل',
        message: e.message,
        type: SnackType.error,
      );
    } catch (e) {
      errorMessage.value = 'تعذر تحميل بيانات الفاتورة: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// تصدير وحفظ مستند الفاتورة كـ PDF في الجهاز
  Future<void> exportPdf() async {
    final currentInvoice = invoice.value;
    if (currentInvoice == null || isExporting.value) return;

    isExporting.value = true;
    await CustomAnimationOverlay.showLoading(
      message: 'جاري إنشاء وتصدير الفاتورة...',
    );

    try {
      final succeeded = await invoiceDocumentUseCase.exportAndSaveInvoice(currentInvoice);
      if (succeeded) {
        CustomSnackbar.show(
          title: 'تم تصدير الفاتورة',
          message: 'تم حفظ الفاتورة بنجاح في مجلد Invoices.',
          type: SnackType.success,
        );
      } else {
        CustomSnackbar.show(
          title: 'فشل التصدير',
          message: 'تعذر حفظ ملف الفاتورة.',
          type: SnackType.error,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'خطأ أثناء التصدير',
        message: 'حدث خطأ غير متوقع أثناء توليد المستند: $e',
        type: SnackType.error,
      );
    } finally {
      isExporting.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  /// طباعة الفاتورة مباشرة
  Future<void> printInvoice() async {
    final currentInvoice = invoice.value;
    if (currentInvoice == null || isExporting.value) return;

    isExporting.value = true;
    try {
      final succeeded = await invoiceDocumentUseCase.printInvoice(currentInvoice);
      if (!succeeded) {
        CustomSnackbar.show(
          title: 'تعذر الطباعة',
          message: 'لم يتم تأكيد إرسال الفاتورة إلى خدمة الطباعة.',
          type: SnackType.warning,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'فشل الطباعة',
        message: 'تعذر إرسال المستند للطباعة: $e',
        type: SnackType.error,
      );
    } finally {
      isExporting.value = false;
    }
  }

  /// مشاركة الفاتورة عبر نافذة النظام
  Future<void> shareInvoice() async {
    final currentInvoice = invoice.value;
    if (currentInvoice == null || isExporting.value) return;

    isExporting.value = true;
    try {
      final succeeded = await invoiceDocumentUseCase.shareInvoice(currentInvoice);
      if (!succeeded) {
        CustomSnackbar.show(
          title: 'تعذرت المشاركة',
          message: 'لم يتم تأكيد مشاركة ملف الفاتورة.',
          type: SnackType.warning,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'فشل المشاركة',
        message: 'تعذر فتح نافذة المشاركة: $e',
        type: SnackType.error,
      );
    } finally {
      isExporting.value = false;
    }
  }

  /// فتح تفاصيل طلب التوريد المرتبط
  Future<void> openVoucherRequestDetails(int requestId) async {
    await Get.toNamed<void>(
      AppRoutes.voucherRequestDetails,
      arguments: requestId,
    );
  }
}
