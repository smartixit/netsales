import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/features/invoices/domain/entities/direct_invoice_item_input.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_repository.dart';

/// Creates a standalone B2B sale invoice using server-authoritative pricing
/// and wallet settlement. Client input contains quantities only.
class CreateDirectSaleInvoiceUseCase {
  final InvoiceRepository _repository;

  const CreateDirectSaleInvoiceUseCase(this._repository);

  Future<InvoiceEntity> call({
    required int networkId,
    required int posId,
    required SaleType saleType,
    required List<DirectInvoiceItemInput> items,
    required String idempotencyKey,
  }) {
    if (networkId <= 0 || posId <= 0 || items.isEmpty) {
      throw ArgumentError('Direct invoice requires a network, POS and items.');
    }
    if (idempotencyKey.trim().isEmpty) {
      throw ArgumentError.value(idempotencyKey, 'idempotencyKey');
    }
    if (saleType == SaleType.unknown) {
      throw ArgumentError.value(saleType, 'saleType');
    }
    if (items.any((item) => item.packageId <= 0 || item.voucherCount <= 0)) {
      throw ArgumentError('Direct invoice item identifiers and quantities must be positive.');
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
