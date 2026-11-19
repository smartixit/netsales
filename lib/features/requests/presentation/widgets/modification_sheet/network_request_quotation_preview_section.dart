import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_line_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_entity.dart';
import 'package:netsales/features/requests/presentation/controllers/network_procurement_review_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/modification_sheet/network_request_quotation_voucher_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';

/// قسم المعاينة المالية وحساب الفروقات للطلب المعدل
class NetworkRequestQuotationPreviewSection
    extends GetView<NetworkProcurementReviewController> {
  const NetworkRequestQuotationPreviewSection({
    super.key,
    required this.request,
    required this.preview,
    required this.lines,
  });

  final RequestEntity? request;
  final RequestModificationPreviewEntity? preview;
  final List<RequestModificationLineEntity> lines;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 16.r,
                color: colors.primary,
              ),
            ),
            AppSpacing.hXs,
            Expanded(
              child: Text(
                'ملخص الفاتورة التقديرية المعتمدة',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.vSm,
        if (controller.isPreviewingModification.value)
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: CustomStateView.loading(
              presentation: CustomStatePresentation.skeletonOnly,
              skeleton: const CustomStateSkeleton(
                layout: CustomStateSkeletonLayout.detail,
                itemCount: 1,
                showCardSurface: true,
              ),
            ),
          )
        else if (preview == null)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.primary.withValues(alpha: .22)),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 52.r,
                  height: 52.r,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.calculate_outlined,
                      size: 26.r,
                      color: colors.primary,
                    ),
                  ),
                ),
                AppSpacing.vSm,
                Text(
                  'المعاينة لا تغيّر الطلب ولا تنشئ فاتورة',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  'اضغط على زر «معاينة التعديل» بالأسفل لاحتساب فروقات الأسعار، الخصومات الممنوحة، والإجمالي المعتمد من الخادم قبل الاعتماد النهائي.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          NetworkRequestQuotationVoucherCard(
            request: request,
            preview: preview!,
          ),
      ],
    );
  }
}
