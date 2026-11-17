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
        gradient: AppGradients.financialHero(context),
        foreground: colors.onPrimary,
        prominent: true,
      ),
      _SummaryCardData(
        label: 'قيد المراجعة',
        value: summary?.pending,
        color: colors.warning,
        icon: Icons.hourglass_top_rounded,
        gradient: AppGradients.accentHero3(context, colors.warning),
        foreground: colors.onSurface,
      ),
      _SummaryCardData(
        label: 'معتمدة',
        value: summary?.approved,
        color: colors.success,
        icon: Icons.verified_rounded,
        gradient: AppGradients.accentHero3(context, colors.success),
        foreground: colors.onSurface,
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.cardPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var index = 0; index < cards.length; index++) ...[
            if (index > 0) AppSpacing.hXs,
            Expanded(
              child: _SummaryCard(
                data: cards[index],
                isLoading: isLoading,
              ),
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
    required this.foreground,
    this.prominent = false,
  });

  final String label;
  final int? value;
  final Color color;
  final IconData icon;
  final Gradient gradient;
  final Color foreground;
  final bool prominent;
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
      height: 96.h,
      padding: EdgeInsetsDirectional.fromSTEB(8.r, 9.r, 8.r, 8.r),
      decoration: BoxDecoration(
        gradient: data.gradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: data.prominent
              ? colors.onPrimary.withValues(alpha: .16)
              : data.color.withValues(alpha: dark ? .24 : .18),
        ),
        boxShadow: data.prominent
            ? AppElevation.tinted(
                context,
                data.color,
                alpha: .14,
                blur: 14,
                dy: 5,
              )
            : AppElevation.level1(context),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 31.r,
            height: 31.r,
            decoration: BoxDecoration(
              color: data.foreground.withValues(alpha: data.prominent ? .14 : .10),
              shape: BoxShape.circle,
              border: Border.all(
                color: data.foreground.withValues(alpha: .20),
              ),
            ),
            child: Icon(
              data.icon,
              size: 17.r,
              color: data.prominent ? data.foreground : data.color,
            ),
          ),
          AppSpacing.vXxs,
          Text(
            isLoading ? '—' : (data.value?.toString() ?? '—'),
            style: AppTypography.titleLarge.copyWith(
              color: data.foreground,
              fontWeight: FontWeight.w700,
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
              color: data.foreground.withValues(alpha: .88),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
