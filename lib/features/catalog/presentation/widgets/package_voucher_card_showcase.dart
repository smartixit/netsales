import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/core/utils/color_resolver.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_voucher_badge_divider.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_voucher_mini_badge.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

/// بطاقة المحاكاة الرقمية الفاخرة لكرت الإنترنت (Digital Voucher Card Showcase)
///
/// تجسد تجربة بصرية فائقة مستوحاة من كروت الشحن الرقمية وبطاقات الاتصالات الذكية:
/// - استهلاك 100% لتوكنز النظام المركزية (AppColors, AppSpacing, AppRadius, AppElevation).
/// - ألوان الشريحة الذكية مستمدة من [AppColors.executiveGoldAccent] و [AppColors.executiveGoldIcon].
/// - الظلال ثلاثية الأبعاد مبنية حصرياً عبر [AppElevation.tinted].
class PackageVoucherCardShowcase extends StatelessWidget {
  const PackageVoucherCardShowcase({super.key, required this.package});

  final PackageEntity package;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final baseColor = ColorResolver.resolve(
      package.packageColor,
      colors.primary,
    );
    final statusPres = EnumPresentationRegistry.resolvePackageStatus(
      package.packageStatus,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxxl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor,
            Color.lerp(baseColor, Colors.black, 0.45) ?? baseColor,
            Color.lerp(baseColor, Colors.black, 0.7) ?? Colors.black,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        boxShadow: AppElevation.tinted(
          context,
          baseColor,
          alpha: 0.35,
          blur: 28.r,
          dy: 14.h,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.2,
        ),
      ),
      child: Stack(
        children: [
          // 1. زخرفة خلفية هندسية شبكية
          Positioned(
            right: -30.w,
            top: -30.h,
            child: Opacity(
              opacity: 0.08,
              child: Icon(
                Icons.wifi_tethering_rounded,
                size: 220.r,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: -20.w,
            bottom: -20.h,
            child: Opacity(
              opacity: 0.06,
              child: Icon(
                Icons.sim_card_rounded,
                size: 160.r,
                color: Colors.white,
              ),
            ),
          ),

          // 2. محتوى الكرت الرقمي
          Padding(
            padding: EdgeInsets.all(AppSpacing.cardPadding * 1.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // شريحة الكرت الذكية (Microchip Motif) بألوان التوكن المركزية
                        Container(
                          width: 44.w,
                          height: 32.h,
                          decoration: BoxDecoration(
                            color: colors.executiveGoldAccent.withValues(
                              alpha: 0.85,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                            border: Border.all(
                              color: colors.executiveGoldIcon,
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 24.w,
                              height: 18.h,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: colors.amberAccent.withValues(
                                    alpha: 0.6,
                                  ),
                                  width: 0.8,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xs,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              package.networkName != null
                                  ? '${package.networkName}'
                                  : 'NETSALES TELECOM',
                              style: AppTypography.titleSmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'باقة كروت رقمية #${package.packageId}',
                              style: AppTypography.badgeText.copyWith(
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    CustomStatusBadge(
                      label: statusPres.label,
                      icon: statusPres.icon,
                      tone: statusPres.tone,
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.lg),

                Text(
                  package.packageName,
                  style: AppTypography.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),

                SizedBox(height: AppSpacing.xs),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      package.balanceDisplay,
                      style: AppTypography.displayMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 8.r,
                            offset: Offset(0, 3.h),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'رصيد الحزمة',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.md),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PackageVoucherMiniBadge(
                        icon: Icons.style_outlined,
                        label: '${package.packageVoucherCount} كرت',
                      ),
                      const PackageVoucherBadgeDivider(),
                      PackageVoucherMiniBadge(
                        icon: Icons.timer_outlined,
                        label: package.uptimeDisplay,
                      ),
                      const PackageVoucherBadgeDivider(),
                      PackageVoucherMiniBadge(
                        icon: Icons.event_available_outlined,
                        label: package.validityDisplay,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.sm),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'السعر الأساسي للحزمة: ${AmountFormatter.formatValue(package.packageVoucherPrice)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (package.packageVoucherCount > 0)
                      Text(
                        '(${AmountFormatter.formatValue(package.unitVoucherPrice)} للكرت)',
                        style: AppTypography.badgeText.copyWith(
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
