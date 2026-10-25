import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_theme_toggle_button.dart';

/// ============================================================================
/// بطاقة هوية المستخدم وملف الحساب (MoreProfileHeroCard)
/// ============================================================================
/// بطاقة قيادية تفاعلية تعرض بيانات المستخدم الحالي، دوره التشغيلي، وزر تبديل الثيم السريع.
class MoreProfileHeroCard extends StatelessWidget {
  final UserModel? user;

  const MoreProfileHeroCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final fullName = user?.userFullName ?? 'مستخدم NetSales';
    final phone = user?.userPhoneNumber ?? '';
    final roleName = user?.isNetworkOwner == true
        ? 'مزود شبكة إنترنت'
        : (user?.isPosAgent == true ? 'وكيل نقطة بيع' : 'إدارة النظام');

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppElevation.level1(context),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
          width: 1.r,
        ),
      ),
      child: Row(
        children: [
          // 1. الصورة الشخصية أو الحرف الأول
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.4),
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.25),
                width: 1.5.r,
              ),
            ),
            child: Center(
              child: Text(
                fullName.isNotEmpty ? fullName[0] : 'U',
                style: AppTypography.titleLarge.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          AppSpacing.hMd,

          // 2. الاسم، الدور الوظيفي، ورقم الهاتف
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vXxs,
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        roleName,
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (phone.isNotEmpty) ...[
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          phone,
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // 3. زر تبديل المظهر (Light/Dark Mode Toggle) المدمج
          const CustomThemeToggleButton(),
        ],
      ),
    );
  }
}
