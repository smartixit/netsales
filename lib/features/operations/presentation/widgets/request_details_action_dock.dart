import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/reject_voucher_request_sheet.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/sheets/invoice_print_format_sheet.dart';

/// ============================================================================
/// رصيف الإجراءات والقرارات العائم لطلب التوريد (RequestDetailsActionDock)
/// ============================================================================
/// يوفر وصولاً دائماً وفورياً لقرارات الرفض والإلغاء المباشر للطلبات المعلقة،
/// مع إغلاق قيد الفواتير المالية أمنياً في Milestone 4A.
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
    final isPosWorkspace =
        WorkspaceService.to.activeWorkspace == AppWorkspace.pos;

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
            ? (isPosWorkspace
                ? Row(
                    children: [
                      Expanded(
                        child: CustomButton.danger(
                          text: 'إلغاء الطلب',
                          icon: Icons.cancel_outlined,
                          onPressed: () => _showCancelConfirmation(context),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      if (PermissionService.to
                          .can(AppPermissions.requestsReject)) ...[
                        Expanded(
                          flex: 2,
                          child: CustomButton.danger(
                            text: 'رفض الطلب',
                            icon: Icons.close_rounded,
                            onPressed: () => _showRejectSheet(context),
                          ),
                        ),
                        AppSpacing.hSm,
                      ],
                      if (PermissionService.to
                          .can(AppPermissions.requestsApprove))
                        Expanded(
                          flex: 3,
                          child: CustomButton.outline(
                            text: 'اعتماد الطلب (مقفل أمنياً)',
                            icon: Icons.lock_outline_rounded,
                            onPressed: () => _showLockedNotice(context),
                          ),
                        ),
                    ],
                  ))
            : CustomButton.outline(
                text: 'طباعة ومشاركة سند الطلب',
                icon: Icons.print_rounded,
                onPressed: () =>
                    InvoicePrintFormatSheet.show(context, request: request),
              ),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    CustomBottomSheet.showConfirmation(
      title: 'تأكيد إلغاء طلب التوريد',
      message:
          'هل أنت متأكد من رغبتك في إلغاء طلب التوريد رقم #${request.requestUuid}؟ لا يمكن التراجع عن هذا الإجراء بعد تنفيذه.',
      confirmLabel: 'تأكيد الإلغاء',
      cancelLabel: 'تراجع',
      leadingIcon: Icons.cancel_rounded,
      onConfirm: () => controller.cancelRequest(request.requestId),
    );
  }

  void _showLockedNotice(BuildContext context) {
    CustomBottomSheet.showConfirmation(
      title: 'بوابة الفوترة والاعتماد المالي مقفلة',
      message:
          'اعتماد طلبات التوريد وتوليد فواتير المبيعات وتسوية أرصدة المحافظ مقفل أمنياً ومحمي في المرحلة الحالية (Milestone 4A). سيتم تمكين العمليات المالية في Milestone 4B.',
      confirmLabel: 'حسناً، فهمت',
      cancelLabel: 'إغلاق',
      leadingIcon: Icons.lock_clock_rounded,
      onConfirm: () {},
    );
  }

  void _showRejectSheet(BuildContext context) {
    RejectVoucherRequestSheet.show(
      context,
      requestId: request.requestId,
      requestUuid: request.requestUuid,
      controller: controller,
    );
  }
}
