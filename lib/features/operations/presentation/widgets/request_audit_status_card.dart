import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';

/// ============================================================================
/// بطاقة حالة وتدقيق طلب التوريد المعالج (RequestAuditStatusCard)
/// ============================================================================
/// تعرض نتيجة مراجعة وتدقيق طلب التوريد (معتمد، مرفوض، ملغي) مع تاريخ المراجعة
/// وهوية المدقق بصرياً بنمط سجل سيادي موحد، بدون تكرار لأزرار أو نوافذ الرفض.
class RequestAuditStatusCard extends StatelessWidget {
  final VoucherRequestEntity request;

  const RequestAuditStatusCard({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isApproved = request.isApproved;
    final isRejected = request.isRejected;

    final bannerColor = isApproved
        ? colors.primary
        : isRejected
            ? colors.error
            : colors.onSurfaceVariant;

    final bannerBg = bannerColor.withValues(alpha: 0.08);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: bannerColor.withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: bannerColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isApproved
                  ? Icons.check_circle_rounded
                  : isRejected
                      ? Icons.cancel_rounded
                      : Icons.info_outline_rounded,
              color: bannerColor,
              size: 20.r,
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isApproved
                      ? 'تم اعتماد هذا الطلب وتوليد الفاتورة'
                      : isRejected
                          ? 'تم رفض طلب التوريد'
                          : 'طلب التوريد ملغي',
                  style: AppTypography.titleSmall.copyWith(
                    color: bannerColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (request.reviewDate != null && request.reviewDate!.isNotEmpty) ...[
                  AppSpacing.vXxs,
                  Text(
                    'تاريخ المراجعة: ${request.reviewDate}',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
