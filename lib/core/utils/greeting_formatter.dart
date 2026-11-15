/// أداة مركزية معيارية موحدة لتحديد نصوص الترحيب بحسب التوقيت الزمني للنظام (GreetingFormatter)
class GreetingFormatter {
  const GreetingFormatter._();

  /// إرجاع نص الترحيب باللغة العربية بحسب توقيت اليوم
  static String greeting([DateTime? time]) {
    final hour = (time ?? DateTime.now()).hour;
    if (hour >= 4 && hour < 12) {
      return 'صباح الخير';
    } else if (hour >= 12 && hour < 17) {
      return 'طاب يومك';
    } else {
      return 'مساء الخير';
    }
  }

  /// إرجاع نص الترحيب باللغة الإنجليزية بحسب توقيت اليوم
  static String greetingEn([DateTime? time]) {
    final hour = (time ?? DateTime.now()).hour;
    if (hour >= 4 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
}
