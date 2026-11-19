/// كيان مدخلات بند الفاتورة المباشرة للإرسال إلى الخادم
///
/// ينقل فقط المعرفات الأساسية وكميات الكروت دون أسعار أو حسابات مالية محلية.
class DirectInvoiceItemInputEntity {
  final int packageId;
  final int voucherCount;

  const DirectInvoiceItemInputEntity({
    required this.packageId,
    required this.voucherCount,
  });

  Map<String, dynamic> toJson() => {
    'package_id': packageId,
    'voucher_count': voucherCount,
  };
}
