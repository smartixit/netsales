import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/features/invoices/domain/entities/direct_invoice_item_input_entity.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_repository.dart';

/// حالة استخدام إنشاء فاتورة مبيعات مباشرة لمشغل الشبكة
class CreateDirectSaleInvoiceUseCase {
  final InvoiceRepository repository;

  const CreateDirectSaleInvoiceUseCase(this.repository);

  Future<InvoiceEntity> call({
    required int networkId,
    required int posId,
    required SaleType saleType,
    required List<DirectInvoiceItemInputEntity> items,
    required String idempotencyKey,
  }) {
    if (networkId <= 0) {
      throw ArgumentError('يجب تحديد شبكة صالحة لإصدار الفاتورة.');
    }
    if (posId <= 0) {
      throw ArgumentError('يجب تحديد نقطة بيع صالحة كطرف مستفيد.');
    }
    if (saleType == SaleType.unknown) {
      throw ArgumentError('يجب تحديد نوع بيع صالح (كاش أو آجل).');
    }
    if (items.isEmpty) {
      throw ArgumentError('لا يمكن إنشاء فاتورة مبيعات خالية من البنود.');
    }
    for (final item in items) {
      if (item.voucherCount <= 0) {
        throw ArgumentError('يجب أن تكون كمية الكروت أكبر من الصفر.');
      }
    }
    if (idempotencyKey.trim().isEmpty) {
      throw ArgumentError('مفتاح منع التكرار (Idempotency Key) مطلوب.');
    }

    return repository.createDirectInvoice(
      networkId: networkId,
      posId: posId,
      saleType: saleType,
      items: items,
      idempotencyKey: idempotencyKey,
    );
  }
}
