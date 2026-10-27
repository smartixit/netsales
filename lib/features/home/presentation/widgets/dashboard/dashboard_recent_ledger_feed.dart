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
import 'package:netsales/features/home/domain/entities/dashboard_overview_entity.dart';
import 'package:netsales/features/home/presentation/controllers/home_layout_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// سجل العمليات الميدانية والتحصيل المباشر (DashboardRecentLedgerFeed)
/// ============================================================================
/// يعرض أحدث فواتير المبيعات وطلبات توريد الكروت كقيود محاسبية وميدانية حديثة،
/// مع تمييز فوري لحالة السداد (نقد / آجل) ودعم قناع الخصوصية.
class DashboardRecentLedgerFeed extends StatelessWidget {
  final List<DashboardActivityEntity> activities;
  final bool isMasked;

  const DashboardRecentLedgerFeed({
    super.key,
    required this.activities,
    required this.isMasked,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ترويسة القسم وزر استعراض السجل الكامل
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 28.r,
                    height: 28.r,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.xsRadius,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.history_rounded,
                      size: 16.r,
                      color: colors.primary,
                    ),
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: Text(
                      'أحدث العمليات والحركات',
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.hXs,
            CustomButton.text(
              text: 'السجل الكامل',
              icon: Icons.arrow_forward_ios_rounded,
              iconPosition: AppButtonIconPosition.end,
              size: AppButtonSize.small,
              onPressed: () {
                if (Get.isRegistered<HomeLayoutController>()) {
                  Get.find<HomeLayoutController>().changeTab(1);
                }
              },
            ),
          ],
        ),

        AppSpacing.vMd,

        // في حال عدم وجود عمليات
        if (activities.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadius.lgRadius,
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.25),
                width: 1.w,
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 40.r,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                ),
                AppSpacing.vSm,
                Text(
                  'لا توجد عمليات مسجلة في هذه الفترة',
                  style: AppTypography.labelMedium.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          // قائمة بطاقات القيود والعمليات
          ...activities.map((activity) {
            final isInvoice = activity.isInvoice;
            final isCash = activity.saleType == 'CASH';

            final iconData = isInvoice
                ? (isCash
                      ? Icons.point_of_sale_rounded
                      : Icons.receipt_long_rounded)
                : Icons.inventory_2_rounded;

            final accentColor = isInvoice
                ? (isCash ? colors.success : colors.warning)
                : colors.primary;

            final formattedAmount = isMasked
                ? '••••••'
                : '${AmountFormatter.formatValue(activity.amount, decimalPlaces: 0)} ر.ي';

            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: CustomInteractiveBounce(
                onTap: () {
                  if (activity.isInvoice) {
                    Get.toNamed(
                      '${AppRoutes.saleInvoices}/${activity.id}',
                      parameters: {'uuid': activity.uuid},
                    );
                  } else {
                    Get.toNamed(
                      AppRoutes.requests,
                      parameters: {'uuid': activity.uuid},
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: AppRadius.lgRadius,
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.25),
                      width: 1.w,
                    ),
                    boxShadow: AppElevation.level1(context),
                  ),
                  child: Row(
                    children: [
                      // أيقونة نوع القيد والعملية
                      Container(
                        width: 42.r,
                        height: 42.r,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: AppRadius.mdRadius,
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.25),
                            width: 1.w,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(iconData, size: 20.r, color: accentColor),
                      ),

                      AppSpacing.hSm,

                      // عنوان الحركة واسم الطرف الثاني
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.title,
                              style: AppTypography.titleSmall.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            AppSpacing.vXxs,
                            Text(
                              activity.partyName.isNotEmpty
                                  ? activity.partyName
                                  : (isInvoice
                                        ? 'عميل مباشر'
                                        : 'طلب توريد داخلي'),
                              style: AppTypography.bodySmall.copyWith(
                                color: colors.onSurfaceVariant,
                                fontSize: 11.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      AppSpacing.hSm,

                      // المبلغ المالي وشارة الحالة
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formattedAmount,
                            style: AppTypography.titleSmall.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w900,
                              letterSpacing: isMasked ? 2.0 : 0.0,
                            ),
                          ),
                          AppSpacing.vXxs,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 1.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.1),
                              borderRadius: AppRadius.xsRadius,
                            ),
                            child: Text(
                              activity.statusLabel.isNotEmpty
                                  ? activity.statusLabel
                                  : activity.status,
                              style: AppTypography.labelSmall.copyWith(
                                color: accentColor,
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
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
