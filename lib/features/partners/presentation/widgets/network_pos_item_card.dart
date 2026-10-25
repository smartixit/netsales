import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';
import 'package:netsales/features/partners/presentation/controllers/partners_controller.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// ============================================================================
/// بطاقة عقد الشراكة والتوزيع (NetworkPosItemCard)
/// ============================================================================
/// بطاقة تفاعلية توضح علاقة الربط والتوزيع بين الشبكة ونقطة البيع مع زر تبديل الحالة.
class NetworkPosItemCard extends StatelessWidget {
  final NetworkPosEntity link;
  final PartnersController controller;

  const NetworkPosItemCard({
    super.key,
    required this.link,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final statusBg = link.isActive ? colors.successContainer : colors.errorContainer;
    final statusFg = link.isActive ? colors.success : colors.error;

    return CustomInteractiveBounce(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppElevation.level1(context),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.35),
            width: 1.r,
          ),
        ),
        child: Column(
          children: [
            // 1. محور الربط الثنائي بين الشبكة ونقطة البيع
            Row(
              children: [
                // جانب الشبكة
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.wifi_tethering_rounded,
                          color: colors.primary,
                          size: 18.r,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الشبكة',
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 10.sp,
                                ),
                              ),
                              Text(
                                link.networkName ?? 'شبكة #${link.networkId}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // أيقونة الارتباط في المنتصف
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.swap_horiz_rounded,
                      size: 18.r,
                      color: link.isActive ? colors.primary : colors.onSurfaceVariant,
                    ),
                  ),
                ),

                // جانب نقطة البيع
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.storefront_rounded,
                          color: colors.secondary,
                          size: 18.r,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'نقطة البيع',
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 10.sp,
                                ),
                              ),
                              Text(
                                link.posName ?? 'نقطة #${link.posId}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            AppSpacing.vSm,
            Divider(color: colors.outlineVariant.withValues(alpha: 0.2)),
            AppSpacing.vXs,

            // 2. الموقع وشارة الحالة وزر التبديل
            Row(
              children: [
                // المنطقة الجغرافية
                if (link.governorateName != null &&
                    link.governorateName!.isNotEmpty) ...[
                  Icon(
                    Icons.location_on_outlined,
                    size: 13.r,
                    color: colors.onSurfaceVariant,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '${link.governorateName ?? ''} - ${link.directorateName ?? ''}',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
                const Spacer(),

                // شارة الحالة
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    link.statusLabel,
                    style: AppTypography.labelSmall.copyWith(
                      color: statusFg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                AppSpacing.hSm,

                // زر تبديل الحالة
                CustomButton.outline(
                  text: link.isActive ? 'تجميد' : 'تفعيل',
                  icon: link.isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
                  height: 32.h,
                  onPressed: () => controller.toggleLinkStatus(link.networkPosId),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
