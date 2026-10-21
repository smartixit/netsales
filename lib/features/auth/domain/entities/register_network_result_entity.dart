/// كائن نتيجة تسجيل شبكة جديدة (RegisterNetworkResultEntity)
class RegisterNetworkResultEntity {
  final bool success;
  final String message;
  final int? networkId;
  final String? networkName;
  final int? userId;
  final String? userFullName;
  final String? status;

  const RegisterNetworkResultEntity({
    required this.success,
    required this.message,
    this.networkId,
    this.networkName,
    this.userId,
    this.userFullName,
    this.status,
  });
}
