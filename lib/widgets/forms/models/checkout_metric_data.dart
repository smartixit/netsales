/// بيانات عمود القياس المالي في شريط التأكيد والطلب
class CheckoutMetricData {
  const CheckoutMetricData({
    required this.label,
    required this.value,
    this.currency = 'ر.ي',
    this.isDiscount = false,
    this.isNet = false,
  });

  final String label;
  final String value;
  final String currency;
  final bool isDiscount;
  final bool isNet;
}
