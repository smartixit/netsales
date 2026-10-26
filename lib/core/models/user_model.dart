import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/models/role_model.dart';

/// نموذج بيانات المستخدم (User Model) مطابق لـ UserResource في netsales_api
class UserModel {
  final int userId;
  final int? roleId;
  final String userFullName;
  final String? userProfileLogo;
  final String userPhoneNumber;
  final String? userEmail;
  final bool user2faEnabled;
  final bool mustChangePassword;
  final String status;
  final String? statusLabel;
  final String? lastLoginAt;
  final RoleModel? role;

  const UserModel({
    required this.userId,
    this.roleId,
    required this.userFullName,
    this.userProfileLogo,
    required this.userPhoneNumber,
    this.userEmail,
    this.user2faEnabled = false,
    this.mustChangePassword = false,
    this.status = 'ACTIVE',
    this.statusLabel,
    this.lastLoginAt,
    this.role,
  });

  /// التحقق مما إذا كان المستخدم مديراً عاماً للنظام
  bool get isSuperAdmin => role?.roleKey == AppRoles.superAdmin;

  /// التحقق مما إذا كان مزود شبكة
  bool get isNetworkOwner => role?.roleKey == AppRoles.networkOwner;

  /// التحقق مما إذا كان وكيل نقطة بيع
  bool get isPosAgent => role?.roleKey == AppRoles.posAgent;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as int? ?? 0,
      roleId: json['role_id'] as int?,
      userFullName: json['user_full_name']?.toString() ?? '',
      userProfileLogo: json['user_profile_logo']?.toString(),
      userPhoneNumber: json['user_phone_number']?.toString() ?? '',
      userEmail: json['user_email']?.toString(),
      user2faEnabled: json['user_2fa_enabled'] ?? false,
      mustChangePassword: json['must_change_password'] ?? false,
      status: json['status']?.toString() ?? 'ACTIVE',
      statusLabel: json['status_label']?.toString(),
      lastLoginAt: json['last_login_at']?.toString(),
      role: json['role'] is Map
          ? RoleModel.fromJson(Map<String, dynamic>.from(json['role'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'role_id': roleId,
      'user_full_name': userFullName,
      'user_profile_logo': userProfileLogo,
      'user_phone_number': userPhoneNumber,
      'user_email': userEmail,
      'user_2fa_enabled': user2faEnabled,
      'must_change_password': mustChangePassword,
      'status': status,
      'status_label': statusLabel,
      'last_login_at': lastLoginAt,
      'role': role?.toJson(),
    };
  }
}
