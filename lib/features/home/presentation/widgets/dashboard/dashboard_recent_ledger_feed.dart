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

  String? _formatActivityTime(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return null;
    try {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed == null) return rawDate;
      final local = parsed.toLocal();
      final h = local.hour;
      final m = local.minute.toString().padLeft(2, '0');
      final period = h >= 12 ? 'م' : 'ص';
      final displayHour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
      return '$displayHour:$m $period';
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ترويسة القسم السيادية متجاوبة ومحمية 100% من التجاوز
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      'أحدث العمليات والحركات',
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (activities.isNotEmpty) ...[
                    AppSpacing.hXs,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: AppRadius.fullRadius,
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.2),
                          width: 0.8.w,
                        ),
                      ),
                      child: Text(
                        '${activities.length}',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
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
              boxShadow: AppElevation.level1(context),
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 36.r,
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
          // حاوية دفتر الأستاذ الموحد (Sovereign Integrated Ledger Group)
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadius.lgRadius,
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.25),
                width: 1.w,
              ),
              boxShadow: AppElevation.level1(context),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: activities.length,
              separatorBuilder: (context, index) => Divider(
                height: 1.h,
                thickness: 0.8.w,
                indent: 58.w,
                endIndent: AppSpacing.md,
                color: colors.outlineVariant.withValues(alpha: 0.15),
              ),
              itemBuilder: (context, index) {
                final activity = activities[index];
                final isInvoice = activity.isInvoice;
                final isCash = activity.saleType == 'CASH';

                final iconData = isInvoice
                    ? (isCash
                          ? Icons.arrow_downward_rounded
                          : Icons.schedule_rounded)
                    : Icons.inventory_2_rounded;

                final accentColor = isInvoice
                    ? (isCash ? colors.success : colors.warning)
                    : colors.primary;

                final typeBadgeLabel = isInvoice
                    ? (isCash ? 'نقداً' : 'آجل')
                    : 'توريد';

                final timeText = _formatActivityTime(activity.createdAt);

                final formattedAmount = isMasked
                    ? '••••••'
                    : AmountFormatter.formatValue(
                        activity.amount,
                        decimalPlaces: 0,
                      );

                return CustomInteractiveBounce(
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
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 10.h,
                    ),
                    child: Row(
                      children: [
                        // أيقونة شارة التدفق المالي المعمارية
                        Container(
                          width: 36.r,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius: AppRadius.mdRadius,
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.22),
                              width: 1.w,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(iconData, size: 18.r, color: accentColor),
                        ),

                        AppSpacing.hSm,

                        // تفاصيل العملية والطرف الثاني والتوقيت (محمية ومقيدة بالكامل)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      activity.title,
                                      style: AppTypography.labelMedium.copyWith(
                                        color: colors.onSurface,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  AppSpacing.hXxs,
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                      vertical: 1.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(alpha: 0.1),
                                      borderRadius: AppRadius.xsRadius,
                                    ),
                                    child: Text(
                                      typeBadgeLabel,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: accentColor,
                                        fontSize: 8.5.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.vXxs,
                              Row(
                                children: [
                                  Icon(
                                    isInvoice
                                        ? Icons.storefront_outlined
                                        : Icons.hub_outlined,
                                    size: 11.r,
                                    color: colors.onSurfaceVariant.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                  AppSpacing.hXxs,
                                  Expanded(
                                    child: Text(
                                      '${activity.partyName.isNotEmpty ? activity.partyName : (isInvoice ? 'عميل مباشر' : 'طلب توريد داخلي')}${timeText != null ? ' • $timeText' : ''}',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: colors.onSurfaceVariant,
                                        fontSize: 10.sp,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        AppSpacing.hXs,

                        // القيمة المالية المحاسبية وشارة الحالة
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                if (isInvoice && isCash && !isMasked)
                                  Text(
                                    '+',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: colors.success,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                Text(
                                  formattedAmount,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: isCash
                                        ? colors.success
                                        : colors.onSurface,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: isMasked ? 2.0 : -0.2,
                                  ),
                                ),
                                AppSpacing.hXxs,
                                Text(
                                  'ر.ي',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            AppSpacing.vXxs,
                            Text(
                              activity.statusLabel.isNotEmpty
                                  ? activity.statusLabel
                                  : activity.status,
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.onSurfaceVariant.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        AppSpacing.hXxs,

                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10.r,
                          color: colors.onSurfaceVariant.withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
