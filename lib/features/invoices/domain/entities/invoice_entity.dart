import 'package:netsales/core/enums/invoice_payment_status.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_item_entity.dart';

/// كيان فاتورة المبيعات والمشتريات الرسمية المعتمدة (Sale Invoice Entity)
///
/// يعبر عن العقد المالي والسيادي للفاتورة الصادرة عن مشغل الشبكة لصالح نقطة البيع.
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
  final String? networkPhoneNumber;
  final String? networkLogo;
  final String? posName;
  final String? posPhoneNumber;
  final String? posLogo;
  final String? createdByName;
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
    this.networkPhoneNumber,
    this.networkLogo,
    this.posName,
    this.posPhoneNumber,
    this.posLogo,
    this.createdByName,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// نوع البيع المحول ككائن Enum موثوق
  SaleType get saleType => SaleType.fromWire(saleTypeRaw);

  /// حالة السداد المحولة ككائن Enum موثوق
  InvoicePaymentStatus get paymentStatus =>
      InvoicePaymentStatus.fromWire(paymentStatusRaw);

  /// هل الفاتورة مسددة بالكامل
  bool get isPaid =>
      paymentStatus == InvoicePaymentStatus.paid ||
      (remainingAmount <= 0.001 && invoiceTotalAmount > 0);

  /// هل الفاتورة مسددة جزئياً
  bool get isPartiallyPaid =>
      paymentStatus == InvoicePaymentStatus.partiallyPaid;

  /// هل الفاتورة غير مسددة بالكامل
  bool get isUnpaid => paymentStatus == InvoicePaymentStatus.unpaid;

  /// هل الفاتورة ناتجة عن طلب توريد معتمد
  bool get hasLinkedRequest => requestId != null && requestId! > 0;

  /// معرف العرض السيادي للفاتورة
  String get displayReference =>
      invoiceUuid != null && invoiceUuid!.trim().isNotEmpty
          ? invoiceUuid!.trim()
          : '#$invoiceId';

  /// اسم الشبكة الموردة للعرض
  String get displayNetworkName =>
      networkName != null && networkName!.trim().isNotEmpty
          ? networkName!.trim()
          : 'الشبكة #$networkId';

  /// اسم نقطة البيع للعرض
  String get displayPosName => posName != null && posName!.trim().isNotEmpty
      ? posName!.trim()
      : 'نقطة البيع #$posId';

  /// التاريخ المحلل للفاتورة
  DateTime? get parsedInvoiceDate {
    final raw = invoiceDate ?? createdAt;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// صيغة تاريخ منسقة رسمياً للعرض
  String get formattedInvoiceDate => parsedInvoiceDate != null
      ? DateFormatter.dateTime(parsedInvoiceDate!)
      : (invoiceDate ?? createdAt ?? 'التاريخ غير متاح');

  /// إجمالي عدد الكروت المضمنة في الفاتورة
  int get totalVouchers =>
      items.fold<int>(0, (sum, item) => sum + item.voucherCount);

  /// إجمالي عدد الكروت (مرادف إحصائي)
  int get totalVouchersCount => totalVouchers;

  /// عدد باقات الفاتورة المختلفة
  int get packagesCount => items.length;

  /// إجمالي عدد الأوراق المقابلة
  double get totalSheets => items.fold<double>(0.0, (sum, item) {
    final sheet = item.sheetSize;
    return sum + (sheet > 0 ? item.voucherCount / sheet : 0.0);
  });

  /// صيغة نصية لعدد الأوراق
  String get formattedTotalSheets =>
      totalSheets.truncateToDouble() == totalSheets
          ? totalSheets.toInt().toString()
          : totalSheets.toStringAsFixed(1);
}
