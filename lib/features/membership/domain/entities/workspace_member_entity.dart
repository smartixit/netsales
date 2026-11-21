import 'package:netsales/core/enums/membership_status.dart';
import 'package:netsales/core/enums/role_key.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/membership/domain/entities/member_user_entity.dart';
import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';

/// كيان عضوية مساحة العمل (شبكة التوزيع أو نقطة البيع) الموحد (Workspace Member Entity)
class WorkspaceMemberEntity {
  final int id;
  final int tenantId;
  final int userId;
  final int roleId;
  final String? statusRaw;
  final String? statusLabel;
  final int lastEventSeq;
  final bool isOwner;
  final String? createdAt;
  final String? updatedAt;
  final MemberUserEntity? user;
  final MembershipRoleEntity? role;

  const WorkspaceMemberEntity({
    required this.id,
    required this.tenantId,
    required this.userId,
    required this.roleId,
    this.statusRaw,
    this.statusLabel,
    this.lastEventSeq = 1,
    this.isOwner = false,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.role,
  });

  MembershipStatus get status => MembershipStatus.fromWire(statusRaw);

  RoleKey get typedRoleKey =>
      role != null ? role!.typedRoleKey : RoleKey.unknown;

  bool get isActive => status == MembershipStatus.active;
  bool get isSuspended => status == MembershipStatus.suspended;
  bool get isInvited => status == MembershipStatus.invited;

  String get fullName => displayFullName;
  String get phoneNumber => displayPhoneNumber;
  String? get roleKey => role?.roleKey;
  String? get profileLogo => user?.profilePictureUrl;

  String get displayFullName => user?.fullName ?? 'مستخدم #$userId';

  String get displayPhoneNumber => user?.phoneNumber ?? 'غير متوفر';

  String get displayRoleName {
    if (isOwner) return 'المالك المعتمد';
    return role?.roleName ?? 'عضو مساحة العمل';
  }

  String get displayReference => user?.displayReference ?? '#$userId';

  DateTime? get parsedJoinedDate => DateTime.tryParse(createdAt ?? '');

  String get formattedJoinedDate => parsedJoinedDate != null
      ? DateFormatter.dateTime(parsedJoinedDate!)
      : (createdAt ?? 'التاريخ غير متاح');
}
