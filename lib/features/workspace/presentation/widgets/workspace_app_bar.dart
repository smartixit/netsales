import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/notifications/presentation/widgets/notification_badge_button.dart';
import 'package:netsales/features/workspace/presentation/controllers/workspace_coordinator_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_entity_picker_sheet.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_shimmer.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// شريط التطبيق القيادي الفاخر العائم والضبابي لمساحات العمل (WorkspaceAppBar - Executive Frosted Glass Floating Edition)
/// مكوّن عرض نقي خاضع بالكامل للحوكمة ولا يحتوي أي منطق أعمال أو استعلامات جلسة
class WorkspaceAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final AppWorkspace workspace;
  final bool isLoading;
  final EnumPresentation? rolePresentation;
  final String? userProfileLogo;
  final String? userInitials;
  final VoidCallback? onProfileTap;
  final VoidCallback? onEntityPickerTap;
  final List<Widget>? actions;

  const WorkspaceAppBar({
    super.key,
    required this.title,
    required this.workspace,
    this.isLoading = false,
    this.rolePresentation,
    this.userProfileLogo,
    this.userInitials,
    this.onProfileTap,
    this.onEntityPickerTap,
    this.actions,
  });

  @override
  Size get preferredSize => Size.fromHeight(80.h);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final effectivePresentation = rolePresentation ??
        EnumPresentationRegistry.resolveRoleScope(
          workspace == AppWorkspace.network ? RoleScope.network : RoleScope.pos,
        );

    final effectiveInitials = userInitials ??
        (workspace == AppWorkspace.network ? 'ش' : 'ن');

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppBreakpoints.screenMargin(context),
          right: AppBreakpoints.screenMargin(context),
          top: 10.h,
          bottom: 6.h,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 64.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A).withValues(alpha: 0.85)
                    : colors.surface.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : colors.outlineVariant.withValues(alpha: 0.6),
                  width: 1.2.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // الأفاتار القيادي الموحد مع نقطة الحالة النابضة (أو وميض الهيكل العظمي في وضع التحميل)
                  if (isLoading)
                    CustomSkeletonShimmer(
                      child: Container(
                        width: 46.r,
                        height: 46.r,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  else
                    CustomAvatarBadge(
                      imageUrl: userProfileLogo,
                      initials: effectiveInitials,
                      size: AvatarBadgeSize.sm,
                      customDimension: 46,
                      pulseColor: colors.primary,
                      onTap: onProfileTap ??
                          () => WorkspaceCoordinatorController.to
                              .showExecutiveProfile(
                                context,
                                workspace: workspace,
                                userRole: effectivePresentation.label,
                              ),
                    ),
                  SizedBox(width: 10.w),

                  // هوية المساحة والشبكة
                  Expanded(
                    child: isLoading
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomSkeletonShimmer(
                                child: Container(
                                  width: 64.w,
                                  height: 18.h,
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerHigh,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.full),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5.h),
                              CustomSkeletonShimmer(
                                child: Container(
                                  width: 108.w,
                                  height: 14.h,
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerHigh,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.xs.r),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : CustomInteractiveBounce(
                            onTap: onEntityPickerTap ??
                                () => WorkspaceEntityPickerSheet.show(
                                      context,
                                      currentWorkspace: workspace,
                                    ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomStatusBadge.fromPresentation(
                                    effectivePresentation,
                                    isCompact: true,
                                    showDot: true,
                                  ),
                                  SizedBox(height: 3.h),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.titleMedium.copyWith(
                                            color: colors.onSurface,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 16.r,
                                        color: colors.onSurfaceVariant.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),

                  // الإجراءات: شارة الإشعارات الحقيقية + زر التحكم القيادي
                  ...?actions,
                  const NotificationBadgeButton(),
                  SizedBox(width: 8.w),
                  CustomInteractiveBounce(
                    onTap: onProfileTap ??
                        () => WorkspaceCoordinatorController.to.showExecutiveProfile(
                              context,
                              workspace: workspace,
                              userRole: effectivePresentation.label,
                            ),
                    child: Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF131D2E)
                            : colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : colors.outlineVariant,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.tune_rounded,
                        size: 20.r,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
