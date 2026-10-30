import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/edit_voucher_request_sheet.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/menus/custom_popup_menu.dart';
import 'package:netsales/widgets/sheets/invoice_print_format_sheet.dart';

/// ============================================================================
/// أزرار إجراءات شريط التطبيق لتفاصيل طلب التوريد (RequestDetailsAppBarActions)
/// ============================================================================
/// ودجت مستقل ونظيف يوفر أزرار الطباعة والمشاركة مع قائمة منبثقة تفاعلية ذكية
/// تتيح التعديل والإلغاء والحذف للطلبات المتاحة فقط، وتمنع تعديل أو حذف المعتمد أو المرفوض.
class RequestDetailsAppBarActions extends StatelessWidget {
  final OperationsController controller;

  const RequestDetailsAppBarActions({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final request = controller.selectedRequest.value;
      if (request == null) return const SizedBox.shrink();

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. زر الطباعة المباشرة
          CustomButton.icon(
            icon: Icons.print_outlined,
            tooltip: 'طباعة الطلب',
            onPressed: () => InvoicePrintFormatSheet.show(context, request: request),
            dimension: 40.r,
            iconSize: 18.r,
            backgroundColor: Colors.transparent,
          ),

          // 2. زر المشاركة الرقمية
          CustomButton.icon(
            icon: Icons.share_outlined,
            tooltip: 'مشاركة السند',
            onPressed: () => InvoicePrintFormatSheet.show(context, request: request),
            dimension: 40.r,
            iconSize: 18.r,
            backgroundColor: Colors.transparent,
          ),

          // 3. القائمة السياقية للعمليات المتقدمة (تعديل / إلغاء / حذف) — محمية بالصلاحيات
          if ((request.isPending || request.isCancelled) &&
              (PermissionService.to.can(AppPermissions.requestsEdit) ||
                  PermissionService.to.can(AppPermissions.requestsDelete)))
            _buildOverflowMenu(context, colors, request),

          AppSpacing.hXs,
        ],
      );
    });
  }

  Widget _buildOverflowMenu(
    BuildContext context,
    AppColors colors,
    VoucherRequestEntity request,
  ) {
    return CustomPopupMenu<String>(
      tooltip: 'إجراءات الطلب الإضافية',
      triggerIcon: Icons.more_vert_rounded,
      triggerIconSize: 20.r,
      triggerDimension: 38.r,
      triggerBackgroundColor: colors.surfaceContainerHighest.withValues(alpha: 0.6),
      onSelected: (value) => _handleAction(context, value, request),
      items: [
        if (request.isPending && PermissionService.to.can(AppPermissions.requestsEdit))
          CustomPopupItem<String>(
            value: 'edit',
            label: 'تعديل الطلب',
            icon: Icons.edit_outlined,
            iconColor: colors.primary,
          ),
        if (request.isPending && PermissionService.to.can(AppPermissions.requestsEdit))
          CustomPopupItem<String>(
            value: 'cancel',
            label: 'إلغاء الطلب',
            icon: Icons.block_outlined,
            iconColor: colors.warning,
            textColor: colors.warning,
          ),
        if ((request.isPending || request.isCancelled) &&
            PermissionService.to.can(AppPermissions.requestsDelete))
          CustomPopupItem<String>(
            value: 'delete',
            label: 'حذف الطلب',
            icon: Icons.delete_outline_rounded,
            isDestructive: true,
          ),
      ],
    );
  }

  void _handleAction(
    BuildContext context,
    String action,
    VoucherRequestEntity request,
  ) async {
    switch (action) {
      case 'edit':
        await EditVoucherRequestSheet.show(context, request: request);
        break;

      case 'cancel':
        final confirmed = await CustomDialog.showConfirmation(
          title: 'تأكيد إلغاء الطلب',
          message:
              'هل أنت متأكد من رغبتك في إلغاء طلب التوريد رقم #${request.requestUuid}؟',
          confirmLabel: 'نعم، إلغاء الطلب',
          cancelLabel: 'تراجع',
        );
        if (confirmed == true) {
          await controller.cancelRequest(request.requestId);
        }
        break;

      case 'delete':
        final confirmed = await CustomDialog.showDanger(
          title: 'تأكيد حذف الطلب',
          message:
              'هل أنت متأكد من رغبتك في حذف طلب التوريد رقم #${request.requestUuid}؟ لن تتمكن من التراجع عن هذا الإجراء.',
          confirmLabel: 'نعم، حذف نهائي',
          cancelLabel: 'إلغاء',
        );
        if (confirmed == true) {
          await controller.deleteRequest(
            request.requestId,
            requestUuid: request.requestUuid,
          );
        }
        break;
    }
  }
}
