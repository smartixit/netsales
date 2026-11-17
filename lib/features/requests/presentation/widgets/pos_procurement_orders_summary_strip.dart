import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/domain/entities/request_status_summary_entity.dart';

class PosProcurementOrdersSummaryStrip extends StatelessWidget {
  const PosProcurementOrdersSummaryStrip({
    super.key,
    required this.summary,
    required this.isLoading,
  });

  final RequestStatusSummaryEntity? summary;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cards = [
      _SummaryCardData(
        label: 'إجمالي الطلبات',
        value: summary?.total,
        color: colors.primary,
        icon: Icons.receipt_long_rounded,
        gradient: AppGradients.entityAmethyst(context),
      ),
      _SummaryCardData(
        label: 'قيد المراجعة',
        value: summary?.pending,
        color: colors.warning,
        icon: Icons.schedule_rounded,
        gradient: AppGradients.accentHero3(context, colors.warning),
      ),
      _SummaryCardData(
        label: 'معتمدة',
        value: summary?.approved,
        color: colors.success,
        icon: Icons.verified_rounded,
        gradient: AppGradients.accentHero3(context, colors.success),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.cardPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < cards.length; index++) ...[
            if (index > 0) AppSpacing.hSm,
            Expanded(
              child: _SummaryCard(data: cards[index], isLoading: isLoading),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryCardData {
  const _SummaryCardData({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.gradient,
  });

  final String label;
  final int? value;
  final Color color;
  final IconData icon;
  final Gradient gradient;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data, required this.isLoading});

  final _SummaryCardData data;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: BoxConstraints(minHeight: 104.h),
      padding: EdgeInsets.fromLTRB(9.r, 10.r, 9.r, 9.r),
      decoration: BoxDecoration(
        gradient: data.gradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: .10)
              : data.color.withValues(alpha: .16),
        ),
        boxShadow: AppElevation.tinted(
          context,
          data.color,
          alpha: .09,
          blur: 13,
          dy: 4,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: dark ? .20 : .12),
              shape: BoxShape.circle,
              border: Border.all(color: data.color.withValues(alpha: .20)),
              boxShadow: AppElevation.level1(context),
            ),
            child: Icon(data.icon, size: 19.r, color: data.color),
          ),
          AppSpacing.vXs,
          Text(
            isLoading ? '—' : (data.value?.toString() ?? '—'),
            style: AppTypography.titleLarge.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
          AppSpacing.vXxs,
          Text(
            data.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
