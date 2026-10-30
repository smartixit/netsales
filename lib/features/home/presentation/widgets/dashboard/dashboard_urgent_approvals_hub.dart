import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:netsales/features/home/presentation/controllers/home_layout_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// منصة القرارات والاعتمادات السيادية العاجلة (DashboardUrgentApprovalsHub)
/// ============================================================================
/// مركز توجيه تنفيذي راقٍ يركز على تصفية الطلبات المعلقة وتنبيهات السيولة،
/// يتيح للمشغل اتخاذ القرار بلمسة واحدة دون التشتت في تفاصيل ثانوية.
class DashboardUrgentApprovalsHub extends StatelessWidget {
  final DashboardController controller;

  const DashboardUrgentApprovalsHub({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final overview = controller.overview.value;
      if (overview == null) return const SizedBox.shrink();

      final isMasked = controller.isPrivacyMasked.value;
      final kpis = overview.kpis;
      final requests =
          (kpis['requests'] as Map<String, dynamic>?) ??
          (kpis['pending_requests'] as Map<String, dynamic>?) ??
          {};
      final pendingCount =
          (requests['pending_count'] as num?)?.toInt() ??
          (requests['count'] as num?)?.toInt() ??
          0;
      final pendingTotalAmount =
          (requests['pending_total_amount'] as num?)?.toDouble() ?? 0.0;

      final networksKpi = (kpis['networks'] as Map<String, dynamic>?) ?? {};
      final pendingNetworks = (networksKpi['pending'] as num?)?.toInt() ?? 0;
      final posKpi = (kpis['pos'] as Map<String, dynamic>?) ?? {};
      final pendingPos = (posKpi['pending'] as num?)?.toInt() ?? 0;

      final alerts = overview.alerts;

      final formattedPendingAmount = isMasked
          ? '••••••'
          : '${AmountFormatter.formatValue(pendingTotalAmount, decimalPlaces: 0)} ر.ي';

      final hasSuperAdminPending =
          controller.isSuperAdmin &&
          (pendingNetworks > 0 || pendingPos > 0 || pendingCount > 0);

      // 1. في حال وجود اعتمادات أو طلبات معلقة (منصة القرارات الفورية)
      if (pendingCount > 0 || hasSuperAdminPending) {
        final totalPending = controller.isSuperAdmin
            ? (pendingNetworks + pendingPos + pendingCount)
            : pendingCount;

        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.lgRadius,
            border: Border.all(
              color: colors.warning.withValues(alpha: 0.35),
              width: 1.w,
            ),
            boxShadow: AppElevation.glow(context, colors.warning),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الشريط العلوي المدمج للقرار العاجل
              Padding(
                padding: EdgeInsets.all(AppSpacing.cardPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: colors.warning.withValues(alpha: 0.12),
                        borderRadius: AppRadius.mdRadius,
                        border: Border.all(
                          color: colors.warning.withValues(alpha: 0.25),
                          width: 1.w,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.pending_actions_rounded,
                        color: colors.warning,
                        size: 22.r,
                      ),
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  controller.isSuperAdmin
                                      ? 'مركز الرقابة والاعتمادات السيادية'
                                      : 'طلبات التوريد المعلقة',
                                  style: AppTypography.titleSmall.copyWith(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              AppSpacing.hXs,
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.warning.withValues(alpha: 0.15),
                                  borderRadius: AppRadius.fullRadius,
                                ),
                                child: Text(
                                  '$totalPending إجراء عاجل',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: colors.warning,
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.vXxs,
                          Text(
                            controller.isSuperAdmin
                                ? 'يوجد ${pendingNetworks > 0 ? "$pendingNetworks شبكة و" : ""}${pendingPos > 0 ? " $pendingPos نقطة بيع و" : ""} $pendingCount طلب كروت بانتظار الاعتماد'
                                : 'نقاط البيع الميدانية بانتظار توريد الكروت لمواصلة العمليات',
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: 11.sp,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // شريط التنفيذ الفوري واستعراض المبالغ
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.cardPadding,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(AppRadius.lg),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: colors.outlineVariant.withValues(alpha: 0.2),
                      width: 0.8.w,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المبلغ المطلوب',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: 10.sp,
                            ),
                          ),
                          Text(
                            formattedPendingAmount,
                            style: AppTypography.titleSmall.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.hSm,
                    CustomButton.primary(
                      text: 'معاينة واعتماد',
                      icon: Icons.arrow_forward_rounded,
                      size: AppButtonSize.small,
                      iconPosition: AppButtonIconPosition.end,
                      onPressed: () {
                        if (Get.isRegistered<HomeLayoutController>()) {
                          Get.find<HomeLayoutController>().changeTab(1);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      // 2. في حال وجود تنبيهات تشغيلية أخرى (مثل انخفاض الرصيد)
      if (alerts.isNotEmpty) {
        final alert = alerts.first;
        final isDanger = alert.severity == 'DANGER';
        final accentColor = isDanger ? colors.error : colors.primary;

        return CustomInteractiveBounce(
          onTap: () {
            if (alert.actionUrl != null && alert.actionUrl!.isNotEmpty) {
              if (alert.actionUrl!.contains('wallets')) {
                Get.toNamed(AppRoutes.networkWallets);
              } else if (alert.actionUrl!.contains('requests')) {
                if (Get.isRegistered<HomeLayoutController>()) {
                  Get.find<HomeLayoutController>().changeTab(1);
                }
              } else {
                Get.toNamed(alert.actionUrl!);
              }
            }
          },
          child: Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadius.lgRadius,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.3),
                width: 1.w,
              ),
              boxShadow: AppElevation.tinted(context, accentColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: AppRadius.mdRadius,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    isDanger
                        ? Icons.warning_amber_rounded
                        : Icons.info_outline_rounded,
                    color: accentColor,
                    size: 20.r,
                  ),
                ),
                AppSpacing.hSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: AppTypography.titleSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      AppSpacing.vXxs,
                      Text(
                        alert.message,
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 11.sp,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AppSpacing.hXs,
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 14.r,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      }

      // 3. حالة الاستقرار التشغيلي التام للمنظومة (مؤشر ناعم وأنيق)
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.25),
          borderRadius: AppRadius.lgRadius,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.2),
            width: 0.8.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8.r,
              height: 8.r,
              decoration: BoxDecoration(
                color: colors.success,
                shape: BoxShape.circle,
                boxShadow: AppElevation.tinted(context, colors.success),
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              child: Text(
                'شبكة التوزيع مستقرة • كافة طلبات التوريد والاعتمادات منجزة',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    });
  }
}
