import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_removed_item_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

/// بطاقة تدقيق البند المستبعد من الطلب في قسيمة المعاينة
class NetworkRequestRemovedItemDiffCard extends StatelessWidget {
  const NetworkRequestRemovedItemDiffCard({super.key, required this.item});

  final RequestModificationRemovedItemEntity item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.error.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 24.r,
                height: 24.r,
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.remove_circle_outline_rounded,
                    size: 14.r,
                    color: colors.error,
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
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
              AppSpacing.hXs,
              const CustomStatusBadge(
                label: 'تم استبعادها',
                tone: SemanticTone.danger,
                isCompact: true,
              ),
            ],
          ),
          AppSpacing.vXs,
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
                  child: Text(
                    'الكمية المستبعدة: ${item.originalVoucherCount} كرت',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AppSpacing.hXs,
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'وفر مستبعد: ${AmountFormatter.formatValue(item.originalItemTotal)} ر.ي',
                    textDirection: TextDirection.rtl,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
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
