/// بيانات البند الفردي في أكورديون البطاقة التنفيذية
class ExecutiveCardItemData {
  const ExecutiveCardItemData({
    required this.title,
    this.subtitle,
    this.colorHex,
    required this.totalAmount,
    this.discountAmount = 0.0,
    this.badgeText,
  });

  final String title;
  final String? subtitle;
  final String? colorHex;
  final double totalAmount;
  final double discountAmount;
  final String? badgeText;
}
