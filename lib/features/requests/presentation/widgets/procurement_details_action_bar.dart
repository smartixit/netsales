import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/presentation/controllers/procurement_request_details_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// شريط الإجراءات التفاعلي المخصص في أسفل صفحة تفاصيل الطلب
class ProcurementDetailsActionBar extends StatelessWidget {
  const ProcurementDetailsActionBar({
    super.key,
    required this.request,
    required this.controller,
  });

  final RequestEntity request;
  final ProcurementRequestDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isNetwork = controller.isNetworkWorkspace;

    // لا نعرض شريط الأزرار إذا لم يكن هناك إجراء متاح
    final hasPendingActions = request.isPending;
    final hasInvoiceAction =
        request.isApproved &&
        request.invoiceId != null &&
        request.invoiceId! > 0;

    if (!hasPendingActions && !hasInvoiceAction) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadding,
          vertical: 10.h,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Align(
          alignment: Alignment.center,
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: _buildActionRow(context, isNetwork: isNetwork),
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, {required bool isNetwork}) {
    // 1. منظور الشبكة (اعتماد / رفض أو استعراض الفاتورة)
    if (isNetwork) {
      if (request.isPending) {
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomButton.danger(
                text: 'رفض الطلب',
                icon: Icons.cancel_outlined,
                onPressed: controller.promptRejectRequest,
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              flex: 3,
              child: CustomButton.primary(
                text: 'اعتماد وإصدار الفاتورة',
                icon: Icons.verified_rounded,
                onPressed: controller.promptApproveRequest,
              ),
            ),
          ],
        );
      }

      if (request.isApproved && request.invoiceId != null) {
        return SizedBox(
          width: double.infinity,
          child: CustomButton.primary(
            text: 'عرض فاتورة المبيعات المرتبطة',
            icon: Icons.receipt_long_rounded,
            onPressed: controller.openLinkedInvoice,
          ),
        );
      }
    }

    // 2. منظور نقطة البيع (إلغاء / تعديل أو استعراض الفاتورة)
    if (!isNetwork) {
      if (request.isPending) {
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomButton.danger(
                text: 'إلغاء الطلب',
                icon: Icons.close_rounded,
                onPressed: controller.promptCancelRequest,
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              flex: 3,
              child: CustomButton.primary(
                text: 'تعديل بنود الطلب',
                icon: Icons.edit_note_rounded,
                onPressed: controller.openEditOrder,
              ),
            ),
          ],
        );
      }

      if (request.isApproved && request.invoiceId != null) {
        return SizedBox(
          width: double.infinity,
          child: CustomButton.primary(
            text: 'عرض فاتورة المشتريات المرتبطة',
            icon: Icons.receipt_long_rounded,
            onPressed: controller.openLinkedInvoice,
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }
}
