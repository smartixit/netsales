import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_item_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

/// بطاقة تدقيق الفروقات للبند المضاف أو المعدل في قسيمة المعاينة
class NetworkRequestPreviewItemDiffCard extends StatelessWidget {
  const NetworkRequestPreviewItemDiffCard({super.key, required this.item});

  final RequestModificationPreviewItemEntity item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isAdded = item.isAdded;
    final isModified = item.isModified;

    final Color accentColor = isAdded
        ? colors.tertiary
        : isModified
        ? colors.secondary
        : colors.outlineVariant;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isAdded
            ? colors.tertiary.withValues(alpha: 0.04)
            : isModified
            ? colors.secondary.withValues(alpha: 0.04)
            : colors.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── السطر الأول: أيقونة الحالة واسم الباقة وشارة التعديل ──
          Row(
            children: [
              Container(
                width: 24.r,
                height: 24.r,
                decoration: BoxDecoration(
                  color: isAdded
                      ? colors.tertiary.withValues(alpha: 0.12)
                      : isModified
                      ? colors.secondary.withValues(alpha: 0.12)
                      : colors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isAdded
                        ? Icons.add_rounded
                        : isModified
                        ? Icons.edit_rounded
                        : Icons.check_rounded,
                    size: 14.r,
                    color: isAdded
                        ? colors.tertiary
                        : isModified
                        ? colors.secondary
                        : colors.onSurfaceVariant,
                  ),
                ),
              ),
              AppSpacing.hXs,
              Expanded(
                child: Text(
                  item.packageName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
              AppSpacing.hXs,
              if (isAdded)
                const CustomStatusBadge(
                  label: 'باقة مضافة',
                  tone: SemanticTone.success,
                  isCompact: true,
                )
              else if (isModified)
                CustomStatusBadge(
                  label: '${item.originalVoucherCount} ➔ ${item.voucherCount}',
                  tone: SemanticTone.info,
                  isCompact: true,
                )
              else
                Text(
                  '${item.voucherCount} كرت',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          AppSpacing.vXs,

          // ── السطر الثاني: التفاصيل المحاسبية (الكمية × السعر ➔ الصافي) ──
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 6.r,
            ),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: '${item.voucherCount} كرت',
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      children: [
                        TextSpan(
                          text:
                              ' × ${AmountFormatter.formatValue(item.voucherPrice)} ر.ي',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppSpacing.hXs,
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${AmountFormatter.formatValue(item.itemTotalAmount)} ر.ي',
                        textDirection: TextDirection.rtl,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colors.primary,
                        ),
                      ),
                      if (item.discountAmount > 0)
                        Text(
                          'وفر: -${AmountFormatter.formatValue(item.discountAmount)} ر.ي',
                          textDirection: TextDirection.rtl,
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.tertiary,
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
