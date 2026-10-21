import 'package:netsales/features/auth/domain/entities/register_pos_result_entity.dart';

/// نموذج استجابة تسجيل نقطة البيع (RegisterPosResponseModel)
///
/// يرث إجبارياً من الكيان الدوميني المقابل (LSP) ويتولى تسلسل البيانات من الـ JSON
class RegisterPosResponseModel extends RegisterPosResultEntity {
  const RegisterPosResponseModel({
    required super.success,
    required super.message,
    super.posId,
    super.posName,
    super.userId,
    super.userFullName,
    super.status,
  });

  factory RegisterPosResponseModel.fromJson(
    Map<String, dynamic> json, {
    String? defaultMessage,
  }) {
    final pos = json['pos'] is Map ? json['pos'] as Map<String, dynamic> : null;
    final user = json['user'] is Map ? json['user'] as Map<String, dynamic> : null;

    return RegisterPosResponseModel(
      success: true,
      message: json['message']?.toString() ??
          defaultMessage ??
          'تم استلام طلب تسجيل نقطة البيع بنجاح وهو قيد المراجعة والاعتماد.',
      posId: pos?['pos_id'] as int?,
      posName: pos?['pos_name']?.toString(),
      userId: user?['user_id'] as int?,
      userFullName: user?['user_full_name']?.toString(),
      status: pos?['status']?.toString() ?? 'PENDING',
    );
  }
}
