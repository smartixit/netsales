import 'package:netsales/features/auth/domain/entities/register_network_result_entity.dart';

/// نموذج استجابة تسجيل الشبكة (RegisterNetworkResponseModel) يرث من الكيان الدوميني
class RegisterNetworkResponseModel extends RegisterNetworkResultEntity {
  const RegisterNetworkResponseModel({
    required super.success,
    required super.message,
    super.networkId,
    super.networkName,
    super.userId,
    super.userFullName,
    super.status,
  });

  factory RegisterNetworkResponseModel.fromJson(Map<String, dynamic> json, {String? defaultMessage}) {
    final network = json['network'] is Map ? json['network'] as Map<String, dynamic> : null;
    final user = json['user'] is Map ? json['user'] as Map<String, dynamic> : null;

    return RegisterNetworkResponseModel(
      success: true,
      message: json['message']?.toString() ??
          defaultMessage ??
          'تم استلام طلبكم، سيتم مراجعة الطلب واشعاركم في حال قبول الطلب.',
      networkId: network?['network_id'] as int?,
      networkName: network?['network_name']?.toString(),
      userId: user?['user_id'] as int?,
      userFullName: user?['user_full_name']?.toString(),
      status: network?['status']?.toString() ?? 'PENDING',
    );
  }
}
