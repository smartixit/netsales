import 'package:netsales/features/membership/data/models/member_user_model.dart';
import 'package:netsales/features/membership/data/models/membership_role_model.dart';
import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';

/// نموذج بيانات عضو مساحة العمل الموحد للتحويل من وإلى JSON
class WorkspaceMemberModel extends WorkspaceMemberEntity {
  const WorkspaceMemberModel({
    required super.id,
    required super.tenantId,
    required super.userId,
    required super.roleId,
    super.statusRaw,
    super.statusLabel,
    super.lastEventSeq = 1,
    super.isOwner = false,
    super.createdAt,
    super.updatedAt,
    super.user,
    super.role,
  });

  factory WorkspaceMemberModel.fromJson(
    Map<String, dynamic> json, {
    int defaultTenantId = 0,
  }) {
    final tenantId = json['network_id'] as int? ??
        json['pos_id'] as int? ??
        defaultTenantId;

    return WorkspaceMemberModel(
      id: json['id'] as int? ?? 0,
      tenantId: tenantId,
      userId: json['user_id'] as int? ?? 0,
      roleId: json['role_id'] as int? ?? 0,
      statusRaw: json['status'] as String?,
      statusLabel: json['status_label'] as String?,
      lastEventSeq: json['last_event_seq'] as int? ?? 1,
      isOwner: json['is_owner'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      user: json['user'] is Map<String, dynamic>
          ? MemberUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      role: json['role'] is Map<String, dynamic>
          ? MembershipRoleModel.fromJson(json['role'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'user_id': userId,
      'role_id': roleId,
      'status': statusRaw,
      'status_label': statusLabel,
      'last_event_seq': lastEventSeq,
      'is_owner': isOwner,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user': (user as MemberUserModel?)?.toJson(),
      'role': (role as MembershipRoleModel?)?.toJson(),
    };
  }
}
