import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';

/// ============================================================================
/// بطاقة طلب التوريد المرتبط بالفاتورة (InvoiceLinkedRequestCard)
/// ============================================================================
/// تعرض بطاقة ربط سيادية لطلب التوريد الأصلي الذي تم اعتماد الفاتورة بناءً عليه،
/// وتتيح الانتقال المباشر لتفاصيل طلب التوريد لمطابقة البنود والكميات الأصلية.
class InvoiceLinkedRequestCard extends StatelessWidget {
  final SaleInvoiceEntity invoice;
  final OperationsController controller;

  const InvoiceLinkedRequestCard({
    super.key,
    required this.invoice,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final requestId = invoice.requestId;
    final requestUuid = invoice.requestUuid;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: requestId != null
            ? () => controller.openRequestDetails(requestId)
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
                  Icons.assignment_outlined,
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
                      'طلب التوريد المعتمد الأصلي',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.sp,
                      ),
                    ),
                    AppSpacing.vXxs,
                    Text(
                      requestUuid ?? 'طلب توريد رقم #$requestId',
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

