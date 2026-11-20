import 'package:netsales/core/enums/membership_status.dart';
import 'package:netsales/core/utils/text_formatter.dart';

/// كيان دورة حياة عضوية مساحة العمل لنظام NetSales (Workspace Member Entity)
class WorkspaceMemberEntity {
  final int userId;
  final String fullName;
  final String phoneNumber;
  final int roleId;
  final String? roleKey;
  final String? roleLabel;
  final String? statusRaw;
  final String? statusLabel;
  final String? profileLogo;
  final bool isOwner;

  const WorkspaceMemberEntity({
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.roleId,
    this.roleKey,
    this.roleLabel,
    this.statusRaw,
    this.statusLabel,
    this.profileLogo,
    this.isOwner = false,
  });

  /// كائن التعداد المستخلص من القيمة الخام
  MembershipStatus get status => MembershipStatus.fromWire(statusRaw);

  bool get isActive => status == MembershipStatus.active;
  bool get isSuspended => status == MembershipStatus.suspended;
  bool get isInvited => status == MembershipStatus.invited;

  /// الحروف الأولى من اسم العضو للأفاتار باستخدام أداة TextFormatter المركزية
  String get displayInitials => TextFormatter.avatarInitials(fullName);
}
