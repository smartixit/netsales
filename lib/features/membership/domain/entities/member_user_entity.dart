/// كيان المستخدم الأساسي لعضو مساحة العمل (Member User Entity)
class MemberUserEntity {
  final int userId;
  final String userUuid;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String? statusRaw;
  final String? statusLabel;
  final String? profilePictureUrl;

  const MemberUserEntity({
    required this.userId,
    required this.userUuid,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.statusRaw,
    this.statusLabel,
    this.profilePictureUrl,
  });

  /// معرف العرض السيادي للمستخدم
  String get displayReference {
    if (userUuid.trim().isNotEmpty) {
      return userUuid.trim();
    }
    return '#$userId';
  }
}
