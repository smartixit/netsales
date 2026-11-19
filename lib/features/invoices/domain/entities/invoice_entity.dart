import 'package:netsales/core/enums/invoice_payment_status.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_item_entity.dart';

/// كيان فاتورة المبيعات والمشتريات الرسمية المعتمدة (Sale / Purchase Invoice Entity)
///
/// يمثل الوثيقة المالية السيادية الصادرة عن شبكة التزويد لصالح نقطة البيع.
/// نقي تماماً من أي اعتماديات واجهة مستخدم (Flutter UI) أو دوال منطقية متقدمة.
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
  final String? createdByName;
  final String? networkName;
  final String? networkLogoUrl;
  final String? networkPhoneNumber;
  final String? networkEmail;
  final String? networkAddress;
  final String? posName;
  final String? posLogoUrl;
  final String? posPhoneNumber;
  final String? posEmail;
  final String? posAddress;
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
    this.createdByName,
    this.networkName,
    this.networkLogoUrl,
    this.networkPhoneNumber,
    this.networkEmail,
    this.networkAddress,
    this.posName,
    this.posLogoUrl,
    this.posPhoneNumber,
    this.posEmail,
    this.posAddress,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// الحصول على حالة السداد المعتمدة كـ Enum مدعوم
  InvoicePaymentStatus get paymentStatus =>
      InvoicePaymentStatus.fromWire(paymentStatusRaw);

  /// الحصول على نوع المعاملة (كاش/آجل) كـ Enum مدعوم
  SaleType get saleType => SaleType.fromWire(saleTypeRaw);

  /// حالات السداد السريعة
  bool get isPaid => paymentStatus == InvoicePaymentStatus.paid || isFullyPaid;
  bool get isUnpaid => paymentStatus == InvoicePaymentStatus.unpaid;
  bool get isPartiallyPaid =>
      paymentStatus == InvoicePaymentStatus.partiallyPaid;

  /// مرجع الفاتورة المقروء للعرض (UUID إن وجد أو المعرف الرقمي)
  String get displayReference {
    if (invoiceUuid != null && invoiceUuid!.trim().isNotEmpty) {
      return invoiceUuid!;
    }
    return '#$invoiceId';
  }

  /// هل تملك الفاتورة معرّف UUID موثق
  bool get hasInvoiceUuid =>
      invoiceUuid != null && invoiceUuid!.trim().isNotEmpty;

  /// هل الفاتورة مرتبطة بطلب توريد معتمد
  bool get hasRequest => requestId != null;

  /// مرجع طلب التوريد المرتبط إن وجد
  String get displayRequestReference {
    if (requestUuid != null && requestUuid!.trim().isNotEmpty) {
      return requestUuid!;
    }
    if (requestId != null) {
      return '#$requestId';
    }
    return '-';
  }

  /// تاريخ الفاتورة كمحرف زمني
  DateTime? get parsedInvoiceDate =>
      DateTime.tryParse(invoiceDate ?? createdAt ?? '');

  /// تاريخ الفاتورة المنسق للعرض
  String get formattedInvoiceDate => parsedInvoiceDate != null
      ? DateFormatter.dateTime(parsedInvoiceDate!)
      : (invoiceDate ?? createdAt ?? '-');

  /// اسم الشبكة المعروض
  String get displayNetworkName {
    if (networkName != null && networkName!.trim().isNotEmpty) {
      return networkName!;
    }
    return 'شبكة #$networkId';
  }

  /// اسم نقطة البيع المعروض
  String get displayPosName {
    if (posName != null && posName!.trim().isNotEmpty) {
      return posName!;
    }
    return 'نقطة بيع #$posId';
  }

  /// إجمالي الفاتورة منسقاً
  String get formattedTotalAmount =>
      AmountFormatter.format(invoiceTotalAmount.toString());

  /// المبلغ المسدد منسقاً
  String get formattedPaidAmount =>
      AmountFormatter.format(paidAmount.toString());

  /// المبلغ المتبقي للسداد منسقاً
  String get formattedRemainingAmount =>
      AmountFormatter.format(remainingAmount.toString());

  /// نسبة السداد المالي المحققة (من 0.0 إلى 1.0)
  double get paidPercentage {
    if (invoiceTotalAmount <= 0) {
      return isPaid ? 1.0 : 0.0;
    }
    return (paidAmount / invoiceTotalAmount).clamp(0.0, 1.0);
  }

  /// إجمالي عدد الكروت عبر كافة بنود الفاتورة
  int get totalVouchersCount =>
      items.fold(0, (sum, item) => sum + item.voucherCount);

  /// عدد باقات الفاتورة المعتمدة
  int get packagesCount => items.length;
}
