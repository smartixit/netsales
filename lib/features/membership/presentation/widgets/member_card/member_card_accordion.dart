import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_card_accordion.dart';

/// درج تفاصيل وإجراءات بطاقة العضو (MemberCardAccordion)
///
/// يستند مباشرة إلى [CustomCardAccordion] الموحد في `lib/widgets/cards/`
/// لتوحيد الرسوم المتحركة وشريط التوسيع ومنع تكرار الكود عبر شاشات المنصة.
class MemberCardAccordion extends StatelessWidget {
  const MemberCardAccordion({
    super.key,
    required this.member,
    required this.isExpanded,
    required this.onToggleExpansion,
    required this.onUpdateRole,
    required this.onToggleStatus,
    required this.onDelete,
  });

  final WorkspaceMemberEntity member;
  final bool isExpanded;
  final VoidCallback onToggleExpansion;
  final VoidCallback onUpdateRole;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomCardAccordion(
      title: 'بيانات العضوية والصلاحيات',
      isExpanded: isExpanded,
      onToggle: onToggleExpansion,
      icon: Icons.badge_outlined,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // سطر رقم الهاتف مع إمكانية الاتصال المباشر
            InkWell(
              onTap: () => UrlLauncherService.callPhone(member.phoneNumber),
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone_android_rounded,
                      size: 16.r,
                      color: colors.primary,
                    ),
                    AppSpacing.hXs,
                    Text(
                      'رقم الهاتف المعتمد',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      member.phoneNumber,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                    AppSpacing.hXxs,
                    Icon(
                      Icons.call_outlined,
                      size: 14.r,
                      color: colors.primary,
                    ),
                  ],
                ),
              ),
            ),

            // سطر المسمى الوظيفي
            if (member.roleLabel != null) ...[
              Divider(
                color: colors.outlineVariant.withValues(alpha: .4),
                height: 12.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.assignment_ind_outlined,
                      size: 16.r,
                      color: colors.primary,
                    ),
                    AppSpacing.hXs,
                    Text(
                      'الدور الوظيفي المعتمد',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      member.roleLabel!,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // تنبيه الحماية إذا كان العضو مالكاً أساسياً للمنشأة
            if (member.isOwner) ...[
              AppSpacing.vSm,
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 16.r,
                      color: colors.onSurfaceVariant,
                    ),
                    AppSpacing.hXs,
                    Expanded(
                      child: Text(
                        'حساب المالك الرئيسي محمي بالكامل ومحصن من التجميد أو الحذف.',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // أزرار الإجراءات الإدارية (تعديل الدور، تجميد/تفعيل، حذف) لغير المالك
            if (!member.isOwner) ...[
              Divider(
                color: colors.outlineVariant.withValues(alpha: .4),
                height: 16.h,
              ),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                alignment: WrapAlignment.end,
                children: [
                  CustomButton.outline(
                    text: 'تعديل الدور',
                    icon: Icons.badge_outlined,
                    size: AppButtonSize.small,
                    onPressed: onUpdateRole,
                  ),
                  CustomButton.outline(
                    text: member.isActive ? 'تجميد العضوية' : 'إعادة التفعيل',
                    icon: member.isActive
                        ? Icons.pause_circle_outline_rounded
                        : Icons.check_circle_outline_rounded,
                    size: AppButtonSize.small,
                    onPressed: onToggleStatus,
                  ),
                  CustomButton.danger(
                    text: 'حذف العضو',
                    icon: Icons.delete_outline_rounded,
                    size: AppButtonSize.small,
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
