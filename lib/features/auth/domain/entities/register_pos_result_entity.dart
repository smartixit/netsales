/// كائن نتيجة تقديم طلب تسجيل نقطة بيع جديدة (RegisterPosResultEntity)
///
/// كيان دوميني نقي خالٍ تماماً من منطق تحويل الـ JSON
class RegisterPosResultEntity {
  final bool success;
  final String message;
  final int? posId;
  final String? posName;
  final int? userId;
  final String? userFullName;
  final String? status;

  const RegisterPosResultEntity({
    required this.success,
    required this.message,
    this.posId,
    this.posName,
    this.userId,
    this.userFullName,
    this.status,
  });
}
