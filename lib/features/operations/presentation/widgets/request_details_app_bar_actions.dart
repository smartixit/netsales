import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/edit_voucher_request_sheet.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
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

          // 3. القائمة السياقية للعمليات المتقدمة (تعديل / إلغاء / حذف)
          if (request.isPending || request.isCancelled)
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
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: colors.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdRadius,
            side: BorderSide(
              color: colors.outline.withValues(alpha: 0.12),
            ),
          ),
          elevation: 4,
          shadowColor: AppElevation.level3(context).first.color,
        ),
      ),
      child: PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert_rounded,
          color: colors.onSurface,
          size: 20.r,
        ),
        tooltip: 'إجراءات الطلب الإضافية',
        position: PopupMenuPosition.under,
        onSelected: (value) => _handleAction(context, value, request),
        itemBuilder: (ctx) => [
          // التعديل متاح فقط في حالة قيد الانتظار (PENDING)
          if (request.isPending)
            PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: colors.primary,
                    size: 18.r,
                  ),
                  AppSpacing.hSm,
                  Text(
                    'تعديل الطلب',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // الإلغاء متاح فقط في حالة قيد الانتظار (PENDING)
          if (request.isPending)
            PopupMenuItem<String>(
              value: 'cancel',
              child: Row(
                children: [
                  Icon(
                    Icons.block_outlined,
                    color: colors.warning,
                    size: 18.r,
                  ),
                  AppSpacing.hSm,
                  Text(
                    'إلغاء الطلب',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // الحذف متاح للطلبات قيد الانتظار أو الملغاة فقط
          if (request.isPending || request.isCancelled)
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline_rounded,
                    color: colors.error,
                    size: 18.r,
                  ),
                  AppSpacing.hSm,
                  Text(
                    'حذف الطلب',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
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
