import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/enums/user_status.dart';
import 'package:netsales/core/models/role_model.dart';
import 'package:netsales/core/models/workspace_membership_model.dart';

/// نموذج بيانات المستخدم الأساسي (Clean User Model)
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
  final bool rawIsSuperAdmin;
  final String? generalRoleKey;
  final List<WorkspaceMembershipModel> workspaceMemberships;

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
    this.rawIsSuperAdmin = false,
    this.generalRoleKey,
    this.workspaceMemberships = const [],
  });

  /// الحفاظ على قائمة المفاتيح النصية للأدوار للتوافق مع الشيفرة الحالية
  List<String> get workspaceRoles =>
      workspaceMemberships.map((m) => m.roleKey).toList(growable: false);

  bool get isSuperAdmin =>
      rawIsSuperAdmin ||
      role?.roleKey == AppRoles.superAdmin ||
      generalRoleKey == AppRoles.superAdmin;

  bool get isNetworkOwner =>
      role?.roleKey == AppRoles.networkOwner ||
      workspaceMemberships.any(
        (m) =>
            m.isNetwork &&
            (m.roleKey == AppRoles.networkOwner ||
                m.roleKey == AppRoles.networkUser ||
                m.roleKey == AppRoles.networkAccountant),
      );

  bool get isPosAgent =>
      role?.roleKey == AppRoles.posAgent ||
      workspaceMemberships.any(
        (m) =>
            m.isPos &&
            (m.roleKey == AppRoles.posAgent ||
                m.roleKey == AppRoles.posUser ||
                m.roleKey == AppRoles.posAccountant),
      );

  bool get hasNetworkMembership => workspaceMemberships.any((m) => m.isNetwork);

  bool get hasPosMembership => workspaceMemberships.any((m) => m.isPos);

  String? get primaryWorkspaceRoleKey =>
      role?.roleKey ??
      (workspaceMemberships.isEmpty
          ? null
          : workspaceMemberships.first.roleKey);

  UserStatus get typedStatus => UserStatus.fromWire(status);
  bool get isActive => typedStatus == UserStatus.active;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // دعم قراءة بيانات المستخدم سواء جاءت مباشرة أو مغلفة داخل كائن user
    final Map<String, dynamic> userMap = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : json;

    final rawRoles =
        json['workspace_roles'] ??
        json['workspace_memberships'] ??
        userMap['workspace_roles'] ??
        userMap['workspace_memberships'];

    final memberships = <WorkspaceMembershipModel>[];
    if (rawRoles is List) {
      for (final item in rawRoles) {
        if (item is Map) {
          memberships.add(
            WorkspaceMembershipModel.fromJson(Map<String, dynamic>.from(item)),
          );
        } else if (item is String && item.isNotEmpty) {
          memberships.add(
            WorkspaceMembershipModel(
              scope: RoleScope.fromWire(null),
              tenantId: 0,
              roleKey: item,
              roleName: item,
            ),
          );
        }
      }
    }

    final isSuper =
        json['is_super_admin'] == true ||
        userMap['is_super_admin'] == true ||
        (userMap['role'] is Map &&
            (userMap['role'] as Map)['role_key'] == AppRoles.superAdmin);

    final genRole =
        json['role_key']?.toString() ?? userMap['role_key']?.toString();

    return UserModel(
      userId: userMap['user_id'] as int? ?? 0,
      roleId: userMap['role_id'] as int?,
      userFullName: userMap['user_full_name']?.toString() ?? '',
      userProfileLogo: userMap['user_profile_logo']?.toString(),
      userPhoneNumber: userMap['user_phone_number']?.toString() ?? '',
      userEmail: userMap['user_email']?.toString(),
      user2faEnabled: userMap['user_2fa_enabled'] == true,
      mustChangePassword: userMap['must_change_password'] == true,
      status: userMap['status']?.toString() ?? 'ACTIVE',
      statusLabel: userMap['status_label']?.toString(),
      lastLoginAt: userMap['last_login_at']?.toString(),
      role: userMap['role'] is Map
          ? RoleModel.fromJson(
              Map<String, dynamic>.from(userMap['role'] as Map),
            )
          : null,
      rawIsSuperAdmin: isSuper,
      generalRoleKey: genRole,
      workspaceMemberships: List.unmodifiable(memberships),
    );
  }

  UserModel copyWith({
    int? userId,
    int? roleId,
    String? userFullName,
    String? userProfileLogo,
    String? userPhoneNumber,
    String? userEmail,
    bool? user2faEnabled,
    bool? mustChangePassword,
    String? status,
    String? statusLabel,
    String? lastLoginAt,
    RoleModel? role,
    bool? rawIsSuperAdmin,
    String? generalRoleKey,
    List<WorkspaceMembershipModel>? workspaceMemberships,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      roleId: roleId ?? this.roleId,
      userFullName: userFullName ?? this.userFullName,
      userProfileLogo: userProfileLogo ?? this.userProfileLogo,
      userPhoneNumber: userPhoneNumber ?? this.userPhoneNumber,
      userEmail: userEmail ?? this.userEmail,
      user2faEnabled: user2faEnabled ?? this.user2faEnabled,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      role: role ?? this.role,
      rawIsSuperAdmin: rawIsSuperAdmin ?? this.rawIsSuperAdmin,
      generalRoleKey: generalRoleKey ?? this.generalRoleKey,
      workspaceMemberships: workspaceMemberships ?? this.workspaceMemberships,
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
      'is_super_admin': rawIsSuperAdmin,
      'role_key': generalRoleKey,
      'workspace_roles': workspaceMemberships
          .map((m) => m.toJson())
          .toList(growable: false),
      'workspace_memberships': workspaceMemberships
          .map((m) => m.toJson())
          .toList(growable: false),
    };
  }
}
