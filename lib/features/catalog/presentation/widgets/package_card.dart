import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/indicators/custom_interactive_amount_text.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// بطاقة عرض باقة كروت الإنترنت في كتالوج الشبكة
class PackageCard extends StatelessWidget {
  final PackageEntity package;
  final VoidCallback onTap;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PackageCard({
    super.key,
    required this.package,
    required this.onTap,
    this.onToggleStatus,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final packageColor = CustomColorPicker.parseHex(package.packageColor);

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: package.status
                ? colors.outlineVariant.withValues(alpha: 0.5)
                : colors.error.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: AppElevation.level2(context),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // الشريط اللوني المميز للباقة
                Container(
                  width: AppSpacing.xs + 2,
                  color: package.status ? packageColor : colors.outlineVariant,
                ),

                // المحتوى الأساسي
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // الرأس: الاسم + الشارة الدلالية
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: AppSpacing.giant,
                              height: AppSpacing.giant,
                              decoration: BoxDecoration(
                                color: packageColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                              ),
                              child: Icon(
                                Icons.wifi_tethering_rounded,
                                color: packageColor,
                                size: AppSpacing.xl,
                              ),
                            ),
                            AppSpacing.hSm,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    package.packageName,
                                    style: AppTypography.titleMedium.copyWith(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (package.packageBalance > 0) ...[
                                    AppSpacing.vXxs,
                                    Text(
                                      'الرصيد: ${package.packageBalance} ميجابايت',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            CustomStatusBadge(
                              label: package.status ? 'نشطة' : 'معطلة',
                              tone: package.status
                                  ? SemanticTone.success
                                  : SemanticTone.danger,
                              isCompact: true,
                              showDot: true,
                            ),
                          ],
                        ),

                        AppSpacing.vSm,
                        Divider(
                          height: 1,
                          color: colors.outlineVariant.withValues(alpha: 0.3),
                        ),
                        AppSpacing.vSm,

                        // تفاصيل التسعير والخصم المالي
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // السعر الأساسي للكرت
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'السعر الأساسي',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                AppSpacing.vXxs,
                                CustomInteractiveAmountText(
                                  amount: package.packageVoucherPrice,
                                  style: AppTypography.titleMedium.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            // نسب الخصومات الافتراضية
                            Row(
                              children: [
                                // الخصم النقدي
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs,
                                    vertical: AppSpacing.xxs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.success.withValues(
                                      alpha: 0.08,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.xs,
                                    ),
                                    border: Border.all(
                                      color: colors.success.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.payments_outlined,
                                        size: AppSpacing.md,
                                        color: colors.success,
                                      ),
                                      AppSpacing.hXxs,
                                      Text(
                                        'نقدي: ${package.packageDefaultCashDiscount}%',
                                        style: AppTypography.labelSmall
                                            .copyWith(
                                              color: colors.success,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),

                                AppSpacing.hXs,

                                // الخصم الآجل
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs,
                                    vertical: AppSpacing.xxs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.secondary.withValues(
                                      alpha: 0.08,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.xs,
                                    ),
                                    border: Border.all(
                                      color: colors.secondary.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.credit_card_outlined,
                                        size: AppSpacing.md,
                                        color: colors.secondary,
                                      ),
                                      AppSpacing.hXxs,
                                      Text(
                                        'آجل: ${package.packageDefaultCreditDiscount}%',
                                        style: AppTypography.labelSmall
                                            .copyWith(
                                              color: colors.secondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
