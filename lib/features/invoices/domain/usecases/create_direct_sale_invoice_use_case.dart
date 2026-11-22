import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/features/invoices/domain/entities/direct_sale_invoice_item_input_entity.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_repository.dart';

/// حالة استخدام إنشاء فاتورة بيع مباشرة جديدة
///
/// تفرض الفحص المسبق والتحقق الدفاعي للبيانات قبل الاتصال بالمستودع:
/// - اشتراط معرفات موجبة للشبكة ونقطة البيع.
/// - اشتراط أن تكون الفاتورة نقدية فقط.
/// - اشتراط قائمة بنود غير فارغة وبكميات كروت موجبة.
/// - اشتراط مفتاح عزل تكرار (Idempotency Key) غير فارغ لحماية المعاملات المالية.
class CreateDirectSaleInvoiceUseCase {
  final InvoiceRepository _repository;

  const CreateDirectSaleInvoiceUseCase(this._repository);

  Future<InvoiceEntity> call({
    required int networkId,
    required int posId,
    required SaleType saleType,
    required List<DirectSaleInvoiceItemInputEntity> items,
    required String idempotencyKey,
  }) {
    if (networkId <= 0) {
      throw ArgumentError.value(networkId, 'networkId', 'معرف الشبكة غير صالح');
    }
    if (posId <= 0) {
      throw ArgumentError.value(posId, 'posId', 'معرف نقطة البيع غير صالح');
    }
    if (saleType != SaleType.cash) {
      throw ArgumentError.value(saleType, 'saleType', 'الفواتير المباشرة نقدية فقط');
    }
    if (idempotencyKey.trim().isEmpty) {
      throw ArgumentError(
        'مفتاح تكرار العملية (Idempotency Key) مطلوب ولا يمكن أن يكون فارغاً',
      );
    }
    if (items.isEmpty) {
      throw ArgumentError('يجب تحديد بند واحد على الأقل لإنشاء الفاتورة');
    }
    for (final item in items) {
      if (item.voucherCount <= 0) {
        throw ArgumentError('يجب أن تكون كمية الكروت موجبة لكل بند');
      }
    }

    return _repository.createDirectInvoice(
      networkId: networkId,
      posId: posId,
      saleType: saleType,
      items: items,
      idempotencyKey: idempotencyKey,
    );
  }
}
