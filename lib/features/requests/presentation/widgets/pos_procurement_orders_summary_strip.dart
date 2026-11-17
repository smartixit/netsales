import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
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
      ),
      _SummaryCardData(
        label: 'قيد المراجعة',
        value: summary?.pending,
        color: colors.warning,
        icon: Icons.schedule_rounded,
      ),
      _SummaryCardData(
        label: 'معتمدة',
        value: summary?.approved,
        color: colors.success,
        icon: Icons.check_circle_outline_rounded,
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.cardPadding),
      child: Row(
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
  });

  final String label;
  final int? value;
  final Color color;
  final IconData icon;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data, required this.isLoading});

  final _SummaryCardData data;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      constraints: BoxConstraints(minHeight: 92.h),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: AppElevation.level1(context),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 19.r, color: data.color),
          ),
          AppSpacing.vXs,
          Text(
            isLoading ? '—' : (data.value?.toString() ?? '—'),
            style: AppTypography.titleLarge.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            data.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
