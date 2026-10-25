import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// ============================================================================
/// شريط إجراءات اعتماد وإدارة طلب التوريد (RequestApprovalActionsBar)
/// ============================================================================
/// يتيح لمالك الشبكة اعتماد الطلب وتوليد الفاتورة أو الرفض والإلغاء مع شاشات التأكيد المعتمدة.
class RequestApprovalActionsBar extends StatelessWidget {
  final VoucherRequestEntity request;
  final OperationsController controller;

  const RequestApprovalActionsBar({
    super.key,
    required this.request,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (!request.isPending) {
      return _AuditStatusBanner(request: request);
    }

    return Column(
      children: [
        // زر الاعتماد الرئيسي
        CustomButton.primary(
          text: 'اعتماد الطلب وتوليد الفاتورة',
          icon: Icons.check_circle_outline_rounded,
          onPressed: () => _showApproveConfirmation(context),
        ),

        AppSpacing.vSm,

        // أزرار الرفض والإلغاء
        Row(
          children: [
            Expanded(
              child: CustomButton.danger(
                text: 'رفض الطلب',
                icon: Icons.cancel_outlined,
                onPressed: () => _showRejectSheet(context),
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              child: CustomButton.outline(
                text: 'إلغاء الطلب',
                icon: Icons.close_rounded,
                onPressed: () => _showCancelConfirmation(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showApproveConfirmation(BuildContext context) {
    Get.bottomSheet(
      CustomBottomSheet.confirmation(
        title: 'تأكيد اعتماد طلب التوريد',
        message:
            'هل أنت متأكد من اعتماد طلب التوريد وتوليد فاتورة مبيعات جديدة؟ سيتم قيد العملية في حساب نقطة البيع فوراً.',
        confirmLabel: 'تأكيد واعتماد',
        cancelLabel: 'تراجع',
        leadingIcon: Icon(
          Icons.verified_rounded,
          color: context.colors.primary,
          size: 24.r,
        ),
        onConfirm: () => controller.approveRequest(request.requestId),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    Get.bottomSheet(
      CustomBottomSheet.confirmation(
        title: 'إلغاء طلب التوريد',
        message: 'هل أنت متأكد من رغبتك في إلغاء هذا الطلب نهائياً؟',
        confirmLabel: 'نعم، إلغاء الطلب',
        cancelLabel: 'تراجع',
        isDestructive: true,
        leadingIcon: Icon(
          Icons.warning_amber_rounded,
          color: context.colors.error,
          size: 24.r,
        ),
        onConfirm: () => controller.cancelRequest(request.requestId),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showRejectSheet(BuildContext context) {
    final reasonController = TextEditingController();

    CustomBottomSheet.show(
      title: 'رفض طلب التوريد',
      subtitle: 'يرجى كتابة سبب رفض الطلب لتوضيحه لوكيل نقطة البيع',
      leadingIcon: Icon(
        Icons.cancel_rounded,
        color: context.colors.error,
        size: 24.r,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: reasonController,
            label: 'سبب الرفض',
            hint: 'مثال: الرصيد غير كافي أو خطأ في تحديد الكمية',
            prefixIcon: const Icon(Icons.comment_outlined),
            maxLines: 2,
          ),
          AppSpacing.vLg,
          Row(
            children: [
              Expanded(
                child: CustomButton.outline(
                  text: 'تراجع',
                  onPressed: () => Get.back(),
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: CustomButton.danger(
                  text: 'تأكيد الرفض',
                  icon: Icons.cancel_rounded,
                  onPressed: () {
                    final reason = reasonController.text.trim();
                    Get.back();
                    controller.rejectRequest(
                      request.requestId,
                      reason: reason.isNotEmpty
                          ? reason
                          : 'مرفوض من قبل الإدارة',
                    );
                  },
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
        ],
      ),
    );
  }
}

/// شارة حالة الطلب للأوامر غير المعلقة
class _AuditStatusBanner extends StatelessWidget {
  final VoucherRequestEntity request;

  const _AuditStatusBanner({required this.request});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isApproved = request.isApproved;
    final isRejected = request.isRejected;

    final bannerColor = isApproved
        ? colors.success
        : isRejected
        ? colors.error
        : colors.onSurfaceVariant;

    final bannerBg = bannerColor.withValues(alpha: 0.08);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(color: bannerColor.withValues(alpha: 0.3)),
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
                if (request.reviewDate != null) ...[
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
