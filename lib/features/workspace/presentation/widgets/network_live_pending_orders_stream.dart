import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/indicators/custom_pulsing_indicator.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// شريط أحدث طلبات التوريد الحقيقية بانتظار الاعتماد (NetworkLivePendingOrdersStream)
class NetworkLivePendingOrdersStream extends StatelessWidget {
  final List<Map<String, dynamic>> requests;
  final int totalPendingCount;
  final VoidCallback onViewAll;

  const NetworkLivePendingOrdersStream({
    super.key,
    required this.requests,
    required this.totalPendingCount,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomSurfaceCard(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CustomPulsingIndicator(
                      color: colors.warning,
                      size: 6.r,
                      enablePing: true,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'أحدث طلبات التوريد بانتظار الاعتماد',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              CustomInteractiveBounce(
                onTap: onViewAll,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'معاينة الكل ($totalPendingCount)',
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11.r,
                      color: colors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vMd,
          ...requests.map((request) => NetworkPendingOrderRow(request: request)),
        ],
      ),
    );
  }
}

/// صف عرض تفاصيل طلب التوريد
class NetworkPendingOrderRow extends StatelessWidget {
  final Map<String, dynamic> request;

  const NetworkPendingOrderRow({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final requestId = request['request_id'];
    final posName = request['pos_name']?.toString() ?? 'نقطة بيع';
    final requestUuid = request['request_uuid']?.toString() ?? '';
    final saleTypeLabel = request['sale_type_label']?.toString() ?? 'نقد';
    final totalAmount = request['request_total_amount']?.toString() ?? '0.00';
    final isCash =
        saleTypeLabel.contains('نقد') || saleTypeLabel.contains('كاش');
    final initials = TextFormatter.avatarInitials(posName, maxChars: 2);

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? colors.surfaceContainerLowest
            : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: isCash
                  ? colors.primary.withValues(alpha: 0.12)
                  : colors.info.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isCash
                    ? colors.primary.withValues(alpha: 0.3)
                    : colors.info.withValues(alpha: 0.3),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: AppTypography.titleSmall.copyWith(
                color: isCash ? colors.primary : colors.info,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  posName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'طلب #${requestUuid.split('-').first} • $saleTypeLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${AmountFormatter.format(totalAmount)} ر.ي',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4.h),
              CustomInteractiveBounce(
                onTap: () {
                  if (requestId is num) {
                    Get.toNamed<void>(
                      AppRoutes.voucherRequestDetails,
                      arguments: requestId.toInt(),
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'مراجعة واعتماد',
                    style: AppTypography.badgeText.copyWith(
                      color: colors.primary,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
