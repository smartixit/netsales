import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/presentation/controllers/procurement_request_details_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

class ProcurementDetailsActionRow extends StatelessWidget {
  const ProcurementDetailsActionRow({
    super.key,
    required this.request,
    required this.controller,
    required this.isNetwork,
  });

  final RequestEntity request;
  final ProcurementRequestDetailsController controller;
  final bool isNetwork;

  @override
  Widget build(BuildContext context) {
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
            text: 'عرض فاتورة الشراء المرتبطة',
            icon: Icons.receipt_long_rounded,
            onPressed: controller.openLinkedInvoice,
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }
}
