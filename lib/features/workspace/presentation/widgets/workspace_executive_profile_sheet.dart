import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_sheet_action_tile.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// النافذة السفلية لعرض الملف الشخصي والتحكم القيادي بمساحات العمل (WorkspaceExecutiveProfileSheet)
/// مكوّن عرض نقي خاضع بالكامل للبيانات الممررة من الكنترولر دون أي منطق أعمال
class WorkspaceExecutiveProfileSheet extends StatelessWidget {
  final String userName;
  final String userRole;
  final String? userPhoneNumber;
  final String? userProfileLogo;
  final AppWorkspace currentWorkspace;
  final bool canSwitchWorkspace;
  final String switchWorkspaceTooltip;
  final VoidCallback? onSwitchWorkspace;
  final VoidCallback? onLogout;
  final VoidCallback? onOpenSecuritySettings;
  final VoidCallback? onOpenActiveSessions;
  final VoidCallback? onToggleTheme;

  const WorkspaceExecutiveProfileSheet({
    super.key,
    required this.userName,
    required this.userRole,
    this.userPhoneNumber,
    this.userProfileLogo,
    required this.currentWorkspace,
    this.canSwitchWorkspace = false,
    this.switchWorkspaceTooltip = '',
    this.onSwitchWorkspace,
    this.onLogout,
    this.onOpenSecuritySettings,
    this.onOpenActiveSessions,
    this.onToggleTheme,
  });

  /// عرض النافذة السفلية
  static Future<void> show(
    BuildContext context, {
    required AppWorkspace currentWorkspace,
    required String userName,
    required String userRole,
    String? userPhoneNumber,
    String? userProfileLogo,
    bool canSwitchWorkspace = false,
    String switchWorkspaceTooltip = '',
    VoidCallback? onSwitchWorkspace,
    VoidCallback? onLogout,
    VoidCallback? onOpenSecuritySettings,
    VoidCallback? onOpenActiveSessions,
    VoidCallback? onToggleTheme,
  }) async {
    final isNetwork = currentWorkspace == AppWorkspace.network;

    await CustomBottomSheet.show<void>(
      title: 'الملف الشخصي والتحكم القيادي',
      subtitle: isNetwork ? 'لوحة تحكم مزود الشبكة' : 'لوحة تحكم نقطة البيع',
      leadingIcon: Icons.account_circle_outlined,
      child: WorkspaceExecutiveProfileSheet(
        userName: userName,
        userRole: userRole,
        userPhoneNumber: userPhoneNumber,
        userProfileLogo: userProfileLogo,
        currentWorkspace: currentWorkspace,
        canSwitchWorkspace: canSwitchWorkspace,
        switchWorkspaceTooltip: switchWorkspaceTooltip,
        onSwitchWorkspace: onSwitchWorkspace,
        onLogout: onLogout,
        onOpenSecuritySettings: onOpenSecuritySettings,
        onOpenActiveSessions: onOpenActiveSessions,
        onToggleTheme: onToggleTheme,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initials = TextFormatter.avatarInitials(userName, maxChars: 2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // بطاقة هوية المستخدم التنفيذية
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              CustomAvatarBadge(
                imageUrl: userProfileLogo,
                initials: initials,
                size: AvatarBadgeSize.md,
                hasPulse: false,
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      userRole,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (userPhoneNumber != null &&
                        userPhoneNumber!.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        userPhoneNumber!,
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg),

        // قائمة الإجراءات القيادية
        if (canSwitchWorkspace && onSwitchWorkspace != null)
          WorkspaceSheetActionTile(
            icon: Icons.swap_horiz_rounded,
            iconColor: colors.primary,
            title: 'تبديل مساحة العمل',
            subtitle: switchWorkspaceTooltip,
            onTap: () async {
              Get.back<void>();
              await Future<void>.delayed(const Duration(milliseconds: 150));
              onSwitchWorkspace!();
            },
          ),

        WorkspaceSheetActionTile(
          icon: Icons.shield_outlined,
          iconColor: colors.info,
          title: 'إعدادات الأمان والخصوصية',
          subtitle: 'كلمة المرور، والتحقق، وتأمين الحساب',
          onTap: () {
            Get.back<void>();
            onOpenSecuritySettings?.call();
          },
        ),

        WorkspaceSheetActionTile(
          icon: Icons.devices_rounded,
          iconColor: colors.secondary,
          title: 'الأجهزة والجلسات النشطة',
          subtitle: 'إدارة الأجهزة المصرح لها بالدخول',
          onTap: () {
            Get.back<void>();
            onOpenActiveSessions?.call();
          },
        ),

        // خيار تبديل المظهر النهاري / الليلي
        WorkspaceSheetActionTile(
          icon: Theme.of(context).brightness == Brightness.dark
              ? Icons.light_mode_outlined
              : Icons.dark_mode_outlined,
          iconColor: colors.warning,
          title: Theme.of(context).brightness == Brightness.dark
              ? 'التبديل إلى الوضع النهاري (الفاتح)'
              : 'التبديل إلى الوضع الليلي (الداكن)',
          subtitle: 'تغيير سمة وألوان الواجهة فورياً',
          onTap: () {
            Get.back<void>();
            onToggleTheme?.call();
          },
        ),

        SizedBox(height: AppSpacing.sm),
        Divider(color: colors.outlineVariant),
        SizedBox(height: AppSpacing.sm),

        // تسجيل الخروج
        WorkspaceSheetActionTile(
          icon: Icons.logout_rounded,
          iconColor: colors.error,
          isDestructive: true,
          title: 'تسجيل الخروج من الحساب',
          subtitle: 'إنهاء الجلسة والعودة لشاشة الدخول',
          onTap: () {
            Get.back<void>();
            onLogout?.call();
          },
        ),
      ],
    );
  }
}
