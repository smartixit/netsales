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
/// مركز الاعتمادات والعمليات التشغيلية العاجلة (DashboardUrgentApprovalsHub)
/// ============================================================================
/// منصة توجيه تشغيلية تركز على طلبات نقاط البيع المعلقة وتنبيهات السيولة الحرجة،
/// مع أزرار تنفيذية مباشرة تحافظ على وتيرة التوزيع الميداني بدون انقطاع.
class DashboardUrgentApprovalsHub extends StatelessWidget {
  final DashboardController controller;

  const DashboardUrgentApprovalsHub({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final overview = controller.overview.value;
      if (overview == null) return const SizedBox.shrink();

      final isMasked = controller.isPrivacyMasked.value;
      final kpis = overview.kpis;
      final requests = (kpis['requests'] as Map<String, dynamic>?) ?? {};
      final pendingCount = (requests['pending_count'] as num?)?.toInt() ?? 0;
      final pendingTotalAmount = (requests['pending_total_amount'] as num?)?.toDouble() ?? 0.0;
      final alerts = overview.alerts;

      final formattedPendingAmount = isMasked
          ? '••••••'
          : '${AmountFormatter.formatValue(pendingTotalAmount, decimalPlaces: 0)} ر.ي';

      // 1. في حال وجود طلبات معلقة من نقاط البيع
      if (pendingCount > 0) {
        return Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.lgRadius,
            border: Border.all(
              color: colors.warning.withValues(alpha: 0.45),
              width: 1.2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.warning.withValues(alpha: 0.12),
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ترويسة التنبيه العاجل
              Row(
                children: [
                  Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      color: colors.warning.withValues(alpha: 0.15),
                      borderRadius: AppRadius.mdRadius,
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
                        Text(
                          'مركز الاعتمادات والطلبات العاجلة',
                          style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        AppSpacing.vXxs,
                        Text(
                          'نقاط البيع بانتظار تزويدها بالكروت لمواصلة البيع',
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.warning.withValues(alpha: 0.2),
                      borderRadius: AppRadius.fullRadius,
                    ),
                    child: Text(
                      '$pendingCount معلق',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.warning,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              AppSpacing.vMd,

              // تفاصيل المبالغ والإجراء الفوري
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: AppRadius.mdRadius,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إجمالي المبالغ المطلوبة',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          AppSpacing.vXxs,
                          Text(
                            formattedPendingAmount,
                            style: AppTypography.titleMedium.copyWith(
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
                      icon: Icons.arrow_back_rounded,
                      size: AppButtonSize.small,
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

      // 2. في حال وجود تنبيهات أخرى (مثل انخفاض رصيد المحفظة المركزية)
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
                color: accentColor.withValues(alpha: 0.35),
                width: 1.w,
              ),
              boxShadow: AppElevation.level1(context),
            ),
            child: Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: AppRadius.mdRadius,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    isDanger ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
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

      // 3. حالة الاستقرار التشغيلي التام للمنظومة
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.lgRadius,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.25),
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.check_circle_outline_rounded,
                color: colors.success,
                size: 18.r,
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'شبكة التوزيع الميداني مستقرة',
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'كافة طلبات التوريد معتمدة ولا توجد معلقات تتطلب إجراءً عاجلاً',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 10.5.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
