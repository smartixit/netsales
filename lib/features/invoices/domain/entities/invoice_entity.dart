import 'package:netsales/core/enums/invoice_payment_status.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_item_entity.dart';

/// كيان فاتورة المبيعات والمشتريات الرسمية (Sale / Purchase Invoice Entity)
class InvoiceEntity {
  final int invoiceId;
  final int networkId;
  final int posId;
  final int? requestId;
  final String? requestUuid;
  final String? invoiceUuid;
  final String? saleTypeRaw;
  final String? saleTypeLabel;
  final double invoiceTotalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String? paymentStatusRaw;
  final String? paymentStatusLabel;
  final bool isFullyPaid;
  final String? invoiceDate;
  final int? createdBy;
  final String? networkName;
  final String? posName;
  final String? posPhoneNumber;
  final List<InvoiceItemEntity> items;
  final String? createdAt;
  final String? updatedAt;

  const InvoiceEntity({
    required this.invoiceId,
    required this.networkId,
    required this.posId,
    this.requestId,
    this.requestUuid,
    this.invoiceUuid,
    this.saleTypeRaw,
    this.saleTypeLabel,
    required this.invoiceTotalAmount,
    this.paidAmount = 0.0,
    this.remainingAmount = 0.0,
    this.paymentStatusRaw,
    this.paymentStatusLabel,
    this.isFullyPaid = false,
    this.invoiceDate,
    this.createdBy,
    this.networkName,
    this.posName,
    this.posPhoneNumber,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// الحصول على حالة السداد المعتمدة كـ Enum
  InvoicePaymentStatus get paymentStatus =>
      InvoicePaymentStatus.fromWire(paymentStatusRaw);

  /// الحصول على نوع المعاملة (كاش/آجل) كـ Enum
  SaleType get saleType => SaleType.fromWire(saleTypeRaw);

  bool get isPaid => paymentStatus == InvoicePaymentStatus.paid || isFullyPaid;
  bool get isUnpaid => paymentStatus == InvoicePaymentStatus.unpaid;
  bool get isPartiallyPaid =>
      paymentStatus == InvoicePaymentStatus.partiallyPaid;
}
