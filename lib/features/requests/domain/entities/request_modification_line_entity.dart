/// بند معتمد لإرسال معاينة التعديل أو تأكيدها إلى Laravel.
/// لا يحمل أسعاراً أو خصومات؛ هذه القيم تبقى من اختصاص الخادم.
class RequestModificationLineEntity {
  final int packageId;
  final int voucherCount;
  final String? pricingToken;

  const RequestModificationLineEntity({
    required this.packageId,
    required this.voucherCount,
    this.pricingToken,
  });
}
