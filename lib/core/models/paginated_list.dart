/// كائن عام لإرجاع القوائم المصفحة بنظام المؤشر (Cursor Pagination)
/// يربط طبقة البيانات (Data) بطبقة النطاق (Domain) وطبقة العرض (Presentation)
/// بشكل متكامل ونظيف وفق مبادئ Clean Architecture.
class PaginatedList<T> {
  /// قائمة العناصر المعادة في الصفحة الحالية
  final List<T> items;

  /// مؤشر الصفحة التالية (Next Cursor) إن وجد
  final String? nextCursor;

  /// مؤشر الصفحة السابقة (Previous Cursor) إن وجد
  final String? prevCursor;

  /// عدد العناصر في الصفحة الواحدة
  final int? perPage;

  const PaginatedList({
    required this.items,
    this.nextCursor,
    this.prevCursor,
    this.perPage,
  });

  /// هل تتوفر صفحات أخرى تالية يمكن تحميلها
  bool get hasMore => nextCursor != null && nextCursor!.trim().isNotEmpty;

  /// هل القائمة الحالية فارغة تماماً
  bool get isEmpty => items.isEmpty;

  /// هل القائمة تحتوي على عناصر
  bool get isNotEmpty => items.isNotEmpty;

  /// عدد العناصر الحالية في هذه الصفحة
  int get length => items.length;

  /// قائمة فارغة افتراضية
  static PaginatedList<T> empty<T>() => PaginatedList<T>(items: const []);
}
