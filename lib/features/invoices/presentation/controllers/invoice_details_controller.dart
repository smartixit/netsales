import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/usecases/get_invoice_details_use_case.dart';
import 'package:netsales/features/invoices/domain/usecases/invoice_document_use_case.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم شاشة تفاصيل فاتورة المبيعات والمشتريات (InvoiceDetailsController)
class InvoiceDetailsController extends GetxController {
  InvoiceDetailsController({
    required this.getInvoiceDetailsUseCase,
    required this.invoiceDocumentUseCase,
  });

  final GetInvoiceDetailsUseCase getInvoiceDetailsUseCase;
  final InvoiceDocumentUseCase invoiceDocumentUseCase;

  final Rxn<InvoiceEntity> invoice = Rxn<InvoiceEntity>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxBool isPrinting = false.obs;
  final RxBool isSharing = false.obs;
  final RxBool isExporting = false.obs;

  /// فهرس البند المفتوح حالياً بنظام الأكورديون الحصري
  final Rxn<int> expandedItemIndex = Rxn<int>();

  void toggleItemExpansion(int index) {
    if (expandedItemIndex.value == index) {
      expandedItemIndex.value = null;
    } else {
      expandedItemIndex.value = index;
    }
  }

  bool isItemExpanded(int index) => expandedItemIndex.value == index;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is InvoiceEntity) {
      invoice.value = args;
      loadInvoiceDetails(args.invoiceId);
    } else if (args is int && args > 0) {
      loadInvoiceDetails(args);
    } else if (args is String) {
      final parsed = int.tryParse(args);
      if (parsed != null && parsed > 0) {
        loadInvoiceDetails(parsed);
      }
    } else if (args is Map<String, dynamic>) {
      if (args['invoice'] is InvoiceEntity) {
        invoice.value = args['invoice'] as InvoiceEntity;
      }
      final invoiceId =
          args['invoice_id'] as int? ??
          int.tryParse(args['invoice_id']?.toString() ?? '') ??
          (args['invoice'] as InvoiceEntity?)?.invoiceId;
      if (invoiceId != null && invoiceId > 0) {
        loadInvoiceDetails(invoiceId);
      }
    }
  }

  Future<void> loadInvoiceDetails(int invoiceId) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await getInvoiceDetailsUseCase(invoiceId);
      invoice.value = result;
    } catch (e) {
      errorMessage.value = AppException.sanitizeMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> printCurrentInvoice() async {
    final currentInvoice = invoice.value;
    if (currentInvoice == null) return;

    isPrinting.value = true;
    try {
      await invoiceDocumentUseCase.printInvoice(currentInvoice);
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

  Future<void> shareCurrentInvoice() async {
    final currentInvoice = invoice.value;
    if (currentInvoice == null) return;

    isSharing.value = true;
    try {
      await invoiceDocumentUseCase.shareInvoice(currentInvoice);
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

  Future<void> exportAndSaveCurrentInvoice() async {
    final currentInvoice = invoice.value;
    if (currentInvoice == null) return;

    isExporting.value = true;
    try {
      await invoiceDocumentUseCase.exportAndSaveInvoice(currentInvoice);
      CustomSnackbar.show(
        title: 'تم التصدير بنجاح',
        message: 'تم حفظ نسخة رسمية من الفاتورة كملف PDF.',
        type: SnackType.success,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر التصدير',
        message: AppException.sanitizeMessage(e),
        type: SnackType.error,
      );
    } finally {
      isExporting.value = false;
    }
  }
}
