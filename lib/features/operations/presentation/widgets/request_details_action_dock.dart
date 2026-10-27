import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/sheets/invoice_print_format_sheet.dart';

/// ============================================================================
/// رصيف الإجراءات والقرارات العائم لطلب التوريد (RequestDetailsActionDock)
/// ============================================================================
/// يوفر وصولاً دائماً وفورياً لقرارات الاعتماد والرفض المباشر للطلبات المعلقة،
/// أو خيارات الطباعة والمشاركة للطلبات المعالجة.
class RequestDetailsActionDock extends StatelessWidget {
  final VoucherRequestEntity request;
  final OperationsController controller;

  const RequestDetailsActionDock({
    super.key,
    required this.request,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isPending = request.isPending;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: 10.h,
      ),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.3),
            width: 0.8.w,
          ),
        ),
        boxShadow: AppElevation.level2(context),
      ),
      child: SafeArea(
        top: false,
        child: isPending
            ? Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomButton.danger(
                      text: 'رفض الطلب',
                      icon: Icons.close_rounded,
                      onPressed: () => _showRejectSheet(context),
                    ),
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    flex: 3,
                    child: CustomButton.primary(
                      text: 'اعتماد وتوليد الفاتورة',
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: () => _showApproveConfirmation(context),
                    ),
                  ),
                ],
              )
            : CustomButton.outline(
                text: 'طباعة ومشاركة سند الطلب',
                icon: Icons.print_rounded,
                onPressed: () => InvoicePrintFormatSheet.show(
                  context,
                  request: request,
                ),
              ),
      ),
    );
  }

  void _showApproveConfirmation(BuildContext context) {
    CustomBottomSheet.showConfirmation(
      title: 'تأكيد اعتماد طلب التوريد',
      message:
          'هل أنت متأكد من رغبتك في اعتماد طلب التوريد وتوليد فاتورة مبيعات جديدة؟ سيتم قيد العملية في حساب نقطة البيع فوراً.',
      confirmLabel: 'تأكيد واعتماد',
      cancelLabel: 'تراجع',
      leadingIcon: Icon(
        Icons.verified_rounded,
        color: context.colors.primary,
        size: 24.r,
      ),
      onConfirm: () => controller.approveRequest(request.requestId),
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
                      reason: reason.isNotEmpty ? reason : 'تم الرفض بواسطة الإدارة',
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
