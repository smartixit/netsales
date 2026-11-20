/// مدخل بند الفاتورة المباشرة المرسل إلى الواجهة الخلفية
///
/// يلتزم بالحد الأدنى الآمن للمدخلات: المعرف والكمية فقط،
/// حيث تحسب الأسعار والخصومات والإجماليات خادمياً بنسبة 100%.
class DirectSaleInvoiceItemInputEntity {
  final int packageId;
  final int voucherCount;

  const DirectSaleInvoiceItemInputEntity({
    required this.packageId,
    required this.voucherCount,
  });

  Map<String, dynamic> toJson() => {
    'package_id': packageId,
    'voucher_count': voucherCount,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DirectSaleInvoiceItemInputEntity &&
          runtimeType == other.runtimeType &&
          packageId == other.packageId &&
          voucherCount == other.voucherCount;

  @override
  int get hashCode => packageId.hashCode ^ voucherCount.hashCode;
}
