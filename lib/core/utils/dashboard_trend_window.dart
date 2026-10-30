
/// ============================================================================
/// حساب نافذة التحليل (DashboardTrendWindow)
/// ============================================================================
/// أداة نقية (Pure Utility) لحساب نطاق التواريخ (from/to) ونوع الفترة (period)
/// وفق مفتاح الفترة (periodKey)، خارج طبقة Presentation (UI) لتجنب استخدام
/// Duration داخل Controllers (AGENTS.md §34.6).
class DashboardTrendWindow {
  DashboardTrendWindow._();

  /// يحسب نافذة التحليل لـ [periodKey] (yesterday/this_week/this_month/this_year).
  static ({String period, DateTime fromDate, DateTime toDate}) resolve(
    String periodKey,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (periodKey) {
      case 'yesterday':
        final day = today.subtract(const Duration(days: 1));
        return (period: 'daily', fromDate: day, toDate: day);
      case 'this_week':
        final start = today.subtract(Duration(days: today.weekday - 1));
        return (
          period: 'daily',
          fromDate: start,
          toDate: start.add(const Duration(days: 6)),
        );
      case 'this_month':
        return (
          period: 'daily',
          fromDate: DateTime(today.year, today.month, 1),
          toDate: DateTime(today.year, today.month + 1, 0),
        );
      case 'this_year':
        return (
          period: 'monthly',
          fromDate: DateTime(today.year, 1, 1),
          toDate: DateTime(today.year, 12, 31),
        );
      default:
        return (period: 'daily', fromDate: today, toDate: today);
    }
  }
}
