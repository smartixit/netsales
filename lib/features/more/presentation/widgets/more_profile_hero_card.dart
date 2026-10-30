import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_theme_toggle_button.dart';

/// ============================================================================
/// بطاقة هوية المستخدم والملف الشخصي التنفيذية (MoreProfileHeroCard)
/// ============================================================================
/// بطاقة هوية قيادية فاخرة تعكس الرتبة المؤسسية والبيانات المعتمدة للمستخدم
/// مع زر تبديل المظهر السريع (فاتح / داكن).
class MoreProfileHeroCard extends StatelessWidget {
  final UserModel? user;

  const MoreProfileHeroCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final fullName = user?.userFullName ?? 'مستخدم NetSales';
    final phone = user?.userPhoneNumber ?? '';
    final roleName = user?.isNetworkOwner == true
        ? 'مزود شبكة إنترنت معتمد'
        : (user?.isPosAgent == true ? 'وكيل نقطة بيع معتمد' : 'إدارة المنشأة');

    final roleIcon = user?.isNetworkOwner == true
        ? Icons.wifi_tethering_rounded
        : (user?.isPosAgent == true
              ? Icons.storefront_rounded
              : Icons.business_center_rounded);

    final initial = fullName.trim().isNotEmpty
        ? fullName.trim().characters.first
        : 'U';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.buttonPaddingV),
      decoration: BoxDecoration(
        gradient: AppGradients.moreHero(context),
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppElevation.level1(context),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.28),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          // 1. الصورة الشخصية ذات الحلقة المزدوجة المتوهجة
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.4),
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.35),
                width: 1.5.w,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: AppTypography.titleLarge.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          AppSpacing.hMd,

          // 2. الاسم، الرتبة المؤسسية، ورقم الهاتف المعتمد
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
                        color: colors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.20),
                          width: 0.6.w,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(roleIcon, size: 11.r, color: colors.primary),
                          AppSpacing.hXxs,
                          Text(
                            roleName,
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 9.5.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (phone.isNotEmpty) ...[
                  AppSpacing.vXxs,
                  Row(
                    children: [
                      Icon(
                        Icons.phone_iphone_rounded,
                        size: 12.r,
                        color: colors.onSurfaceVariant,
                      ),
                      AppSpacing.hXxs,
                      Text(
                        phone,
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          AppSpacing.hSm,

          // 3. زر تبديل المظهر السريع (Dark/Light Mode)
          const CustomThemeToggleButton(),
        ],
      ),
    );
  }
}
