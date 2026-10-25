import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/home/domain/entities/dashboard_overview_entity.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// رادار التنبيهات والعمليات العاجلة (DashboardOperationalRadar)
/// ============================================================================
/// يعرض التنبيهات التشغيلية اللحظية (طلبات معلقة، مديونيات، اعتمادات)
/// مع توجيه فوري بنقرة واحدة نحو شاشة المعالجة المباشرة.
class DashboardOperationalRadar extends StatelessWidget {
  final List<DashboardAlertEntity> alerts;
  final ValueChanged<DashboardAlertEntity>? onAlertTap;

  const DashboardOperationalRadar({
    super.key,
    required this.alerts,
    this.onAlertTap,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.radar_rounded, size: 20.r, color: colors.primary),
            AppSpacing.hSm,
            Text(
              'الرادار التشغيلي والتنبيهات',
              style: AppTypography.titleMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.hSm,
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.12),
                borderRadius: AppRadius.fullRadius,
              ),
              child: Text(
                '${alerts.length}',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        AppSpacing.vMd,

        // قائمة بطاقات التنبيهات
        ...alerts.map((alert) {
          final isDanger = alert.severity == 'DANGER';
          final isWarning = alert.severity == 'WARNING';

          final borderColor = isDanger
              ? colors.error.withValues(alpha: 0.4)
              : isWarning
              ? colors.warning.withValues(alpha: 0.4)
              : colors.primary.withValues(alpha: 0.3);

          final iconColor = isDanger
              ? colors.error
              : isWarning
              ? colors.warning
              : colors.primary;

          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: CustomInteractiveBounce(
              onTap: () => onAlertTap?.call(alert),
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: AppRadius.lgRadius,
                  border: Border.all(color: borderColor),
                  boxShadow: AppElevation.level1(context),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        borderRadius: AppRadius.mdRadius,
                      ),
                      child: Icon(
                        isDanger
                            ? Icons.error_outline_rounded
                            : isWarning
                            ? Icons.pending_actions_rounded
                            : Icons.info_outline_rounded,
                        color: iconColor,
                        size: 22.r,
                      ),
                    ),
                    AppSpacing.hMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.title,
                            style: AppTypography.titleSmall.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppSpacing.vXxs,
                          Text(
                            alert.message,
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.hSm,
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colors.onSurfaceVariant,
                      size: 20.r,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
