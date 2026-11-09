/// طرق الدفع التي يدعمها عقد تحصيل المديونية في Laravel.
enum RepaymentPaymentMethod {
  cash('CASH', 'نقدي'),
  bank('BANK', 'بنكي'),
  wallet('WALLET', 'محفظة'),
  unknown('UNKNOWN', 'غير معروف');

  const RepaymentPaymentMethod(this.wireValue, this.label);

  final String wireValue;
  final String label;

  /// الخيارات التي يسمح للمستخدم باختيارها في عملية التحصيل.
  /// تبقى [unknown] مخصصة لقراءة قيم API المستقبلية فقط.
  static const List<RepaymentPaymentMethod> selectableValues = [
    cash,
    bank,
    wallet,
  ];

  String get referenceLabel => switch (this) {
    cash => 'مرجع سند القبض (اختياري)',
    bank => 'رقم الحوالة أو الإشعار (اختياري)',
    wallet => 'معرّف عملية المحفظة (اختياري)',
    unknown => 'مرجع السداد (اختياري)',
  };

  String get referenceHint => switch (this) {
    cash => 'أدخل رقم سند القبض إن توفر...',
    bank => 'أدخل رقم الحوالة أو الإشعار...',
    wallet => 'أدخل رقم العملية أو مرجع المحفظة...',
    unknown => 'أدخل رقم المرجع...',
  };

  String get supportingLabel => switch (this) {
    cash => 'استلام مباشر',
    bank => 'حوالة أو إيداع',
    wallet => 'إلكترونية',
    unknown => 'غير مدعومة',
  };

  /// يحافظ على القيم غير المعروفة دون تحويلها خطأً إلى وسيلة دفع أخرى.
  static RepaymentPaymentMethod fromWire(String? value) {
    return values.firstWhere(
      (method) => method.wireValue == value,
      orElse: () => RepaymentPaymentMethod.unknown,
    );
  }
}
