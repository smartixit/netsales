/// طرق الدفع التي يدعمها عقد تحصيل المديونية في Laravel.
enum RepaymentPaymentMethod {
  cash('CASH', 'نقدي'),
  bank('BANK', 'بنكي'),
  wallet('WALLET', 'محفظة');

  const RepaymentPaymentMethod(this.wireValue, this.label);

  final String wireValue;
  final String label;

  static RepaymentPaymentMethod fromWire(String? value) {
    for (final method in values) {
      if (method.wireValue == value) return method;
    }
    return RepaymentPaymentMethod.cash;
  }
}
