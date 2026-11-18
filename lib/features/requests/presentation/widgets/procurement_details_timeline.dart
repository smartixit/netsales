import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/request_status.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';

/// مسار التدقيق والتسلسل الزمني الحي لمراحل طلب التوريد
class ProcurementDetailsTimeline extends StatelessWidget {
  const ProcurementDetailsTimeline({super.key, required this.request});

  final RequestEntity request;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final requestDate = request.requestDate != null
        ? DateTime.tryParse(request.requestDate!)
        : null;
    final requestDateStr = requestDate != null
        ? DateFormatter.dateTime(requestDate)
        : (request.requestDate ?? '');

    final reviewDate = request.reviewDate != null
        ? DateTime.tryParse(request.reviewDate!)
        : null;
    final reviewDateStr = reviewDate != null
        ? DateFormatter.dateTime(reviewDate)
        : (request.reviewDate ?? '');

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
        mainAxisSize: MainAxisSize.min,
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
          _buildTimelineNode(
            context,
            title: 'تقديم الطلب واعتماد عرض الأسعار',
            subtitle:
                request.createdByName != null &&
                    request.createdByName!.isNotEmpty
                ? 'مقدم الطلب: ${request.createdByName} (${request.posName ?? 'نقطة البيع'})'
                : (request.posName ?? 'نقطة البيع التابعة'),
            timestamp: requestDateStr,
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFF10B981),
            isCompleted: true,
            isLast: false,
          ),

          // الخطوة 2: المراجعة والتدقيق
          _buildTimelineNode(
            context,
            title: 'المراجعة والتدقيق الفني',
            subtitle: request.isPending
                ? 'جاري التدقيق من قبل إدارة شبكة ${request.networkName ?? ''}'
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
            iconColor: request.isPending
                ? const Color(0xFFD97706)
                : const Color(0xFF10B981),
            isCompleted: !request.isPending,
            isLast: false,
          ),

          // الخطوة 3: القرار والفوترة
          _buildTimelineNode(
            context,
            title: _resolveDecisionTitle(),
            subtitle: _resolveDecisionSubtitle(),
            timestamp: reviewDateStr.isNotEmpty ? reviewDateStr : null,
            icon: _resolveDecisionIcon(),
            iconColor: _resolveDecisionColor(),
            isCompleted: !request.isPending,
            isLast: true,
          ),
        ],
      ),
    );
  }

  String _resolveDecisionTitle() {
    switch (request.status) {
      case RequestStatus.approved:
        return 'تم الاعتماد وإصدار الفاتورة';
      case RequestStatus.rejected:
        return 'تم رفض الطلب';
      case RequestStatus.cancelled:
        return 'تم إلغاء الطلب';
      case RequestStatus.pending:
      default:
        return 'في انتظار القرار النهائي';
    }
  }

  String _resolveDecisionSubtitle() {
    switch (request.status) {
      case RequestStatus.approved:
        final approver =
            request.reviewedByName != null && request.reviewedByName!.isNotEmpty
            ? 'بواسطة ${request.reviewedByName}'
            : '';
        return request.invoiceUuid != null && request.invoiceUuid!.isNotEmpty
            ? 'تم الاعتماد $approver وإصدار الفاتورة المعتمدة #${request.invoiceUuid}'
            : 'تمت المصادقة $approver على الكميات وتوليد الفاتورة آلياً';
      case RequestStatus.rejected:
        final rejector =
            request.reviewedByName != null && request.reviewedByName!.isNotEmpty
            ? 'بواسطة ${request.reviewedByName} • '
            : '';
        return request.requestNote != null && request.requestNote!.isNotEmpty
            ? '${rejector}السبب: ${request.requestNote}'
            : '${rejector}تم رفض الطلب وتوثيق السبب';
      case RequestStatus.cancelled:
        final canceller =
            request.createdByName != null && request.createdByName!.isNotEmpty
            ? 'بواسطة ${request.createdByName}'
            : 'من قبل نقطة البيع';
        return 'تم إلغاء الطلب $canceller قبل البت فيه';
      case RequestStatus.pending:
      default:
        return 'الطلب بانتظار اعتماد المشرف أو تعديل الكميات';
    }
  }

  IconData _resolveDecisionIcon() {
    switch (request.status) {
      case RequestStatus.approved:
        return Icons.verified_rounded;
      case RequestStatus.rejected:
        return Icons.cancel_rounded;
      case RequestStatus.cancelled:
        return Icons.block_rounded;
      case RequestStatus.pending:
      default:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  Color _resolveDecisionColor() {
    switch (request.status) {
      case RequestStatus.approved:
        return const Color(0xFF10B981);
      case RequestStatus.rejected:
        return const Color(0xFFDC2626);
      case RequestStatus.cancelled:
        return const Color(0xFF64748B);
      case RequestStatus.pending:
      default:
        return const Color(0xFF94A3B8);
    }
  }

  Widget _buildTimelineNode(
    BuildContext context, {
    required String title,
    required String subtitle,
    String? timestamp,
    required IconData icon,
    required Color iconColor,
    required bool isCompleted,
    required bool isLast,
  }) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عمود الأيقونة والخط الرابط
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24.r,
              height: 24.r,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, size: 13.r, color: iconColor),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 38.h,
                color: isCompleted
                    ? const Color(0xFF10B981).withValues(alpha: 0.4)
                    : colors.outlineVariant.withValues(alpha: 0.35),
              ),
          ],
        ),
        AppSpacing.hSm,

        // عمود التفاصيل
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: AppTypography.labelMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (timestamp != null && timestamp.isNotEmpty)
                      Text(
                        timestamp,
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 10.sp,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
