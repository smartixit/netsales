/// بيانات سطر التدقيق والحسبة المالية داخل أكورديون البند
class DocumentItemAuditRowData {
  const DocumentItemAuditRowData({
    required this.label,
    this.formula,
    required this.amount,
    this.isDiscount = false,
    this.isTotal = false,
  });

  final String label;
  final String? formula;
  final String amount;
  final bool isDiscount;
  final bool isTotal;
}
