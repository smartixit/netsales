import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';

/// ============================================================================
/// بطاقة الفاتورة المرتبطة بطلب التوريد (RequestLinkedInvoiceCard)
/// ============================================================================
/// تعرض بطاقة ربط سيادية للفاتورة المالية الناتجة عن اعتماد هذا الطلب،
/// وتتيح الانتقال المباشر لتفاصيل فاتورة المبيعات بالسند المالي الرقمي.
class RequestLinkedInvoiceCard extends StatelessWidget {
  final VoucherRequestEntity request;
  final OperationsController controller;

  const RequestLinkedInvoiceCard({
    super.key,
    required this.request,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final invoiceId = request.invoiceId;
    final invoiceUuid = request.invoiceUuid;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: invoiceId != null
            ? () => controller.openInvoiceDetails(invoiceId)
            : null,
        borderRadius: AppRadius.lgRadius,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.lgRadius,
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.35),
              width: 1.w,
            ),
            boxShadow: AppElevation.level1(context),
          ),
          child: Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: colors.primary,
                  size: 20.r,
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'فاتورة المبيعات الصادرة المرتبطة',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.sp,
                      ),
                    ),
                    AppSpacing.vXxs,
                    Text(
                      invoiceUuid ?? 'فاتورة رقم #$invoiceId',
                      style: AppTypography.titleSmall.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: colors.primary,
                size: 16.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

