import 'package:netsales/features/auth/domain/entities/auth_result_entity.dart';

/// عقد مستودع المصادقة الدوميني المجرد
abstract interface class AuthRepository {
  /// تسجيل الدخول إلى النظام والتحقق من المستخدم وإنشاء الجلسة
  Future<AuthResultEntity> login({
    required String phoneNumber,
    required String password,
    String? deviceUuid,
    String? deviceName,
    String? deviceType,
  });
}
