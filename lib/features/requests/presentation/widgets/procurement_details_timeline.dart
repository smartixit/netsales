import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_details_timeline_node.dart';

/// الخط الزمني المالي والإداري التوثيقي لدورة حياة طلب التوريد
class ProcurementDetailsTimeline extends StatelessWidget {
  const ProcurementDetailsTimeline({super.key, required this.request});

  final RequestEntity request;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final requestDateStr = request.formattedRequestDate;
    final reviewDateStr = request.formattedReviewDate;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded, size: 16.r, color: colors.primary),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'مسار دورة حياة الطلب والتدقيق',
                  style: AppTypography.labelMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.25),
          ),
          AppSpacing.vMd,

          // الخطوة 1: تقديم الطلب
          ProcurementDetailsTimelineNode(
            title: 'تقديم الطلب واعتماد عرض الأسعار',
            subtitle: request.createdByName != null &&
                    request.createdByName!.isNotEmpty
                ? 'مقدم الطلب: ${request.createdByName} (${request.displayPosName})'
                : request.displayPosName,
            timestamp: requestDateStr,
            icon: Icons.check_circle_rounded,
            iconColor: colors.success,
            isCompleted: true,
            isLast: false,
          ),

          // الخطوة 2: المراجعة والتدقيق
          ProcurementDetailsTimelineNode(
            title: 'المراجعة والتدقيق الفني',
            subtitle: request.isPending
                ? 'جاري التدقيق من قبل إدارة شبكة ${request.displayNetworkName}'
                : (request.reviewedByName != null &&
                        request.reviewedByName!.isNotEmpty
                    ? 'تم التدقيق بواسطة: ${request.reviewedByName}'
                    : 'تم استكمال الفحص من إدارة الشبكة'),
            timestamp: !request.isPending && reviewDateStr.isNotEmpty
                ? reviewDateStr
                : null,
            icon: request.isPending
                ? Icons.hourglass_top_rounded
                : Icons.check_circle_rounded,
            iconColor: request.isPending ? colors.warning : colors.success,
            isCompleted: !request.isPending,
            isLast: false,
          ),

          // الخطوة 3: القرار والفوترة
          ProcurementDetailsTimelineNode(
            title: request.timelineDecisionTitle,
            subtitle: request.timelineDecisionSubtitle,
            timestamp: reviewDateStr.isNotEmpty ? reviewDateStr : null,
            icon: EnumPresentationRegistry.resolveRequestStatus(
              request.status,
              serverLabel: request.statusLabel,
            ).icon ?? Icons.pending_actions_rounded,
            iconColor: EnumPresentationRegistry.resolveRequestStatus(
              request.status,
              serverLabel: request.statusLabel,
            ).tone.color(context),
            isCompleted: !request.isPending,
            isLast: true,
          ),
        ],
      ),
    );
  }
}
