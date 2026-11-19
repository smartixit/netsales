import 'package:flutter/material.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card_network_actions.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card_pos_actions.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// شريط أزرار الإجراءات التفاعلية لبطاقة طلب التوريد (Order Card Actions Bar)
///
/// يقدم أزرار إجراءات ذكية تتكيف تلقائياً مع سياق مساحة العمل وحالة الطلب:
/// - مساحة نقطة البيع (POS): عرض التفاصيل، تعديل الكميات، إلغاء الطلب، حذف السجل.
/// - مساحة شبكة التوزيع (Network): اعتماد فوري، تعديل الكميات ومعاينة التسعير، رفض مع السبب.
class ProcurementOrderCardActions extends StatelessWidget {
  const ProcurementOrderCardActions({
    super.key,
    required this.request,
    required this.onDetails,
    this.isNetworkView = false,
    this.onEdit,
    this.onCancel,
    this.onDelete,
    this.onApprove,
    this.onModify,
    this.onReject,
  });

  final RequestEntity request;
  final VoidCallback onDetails;
  final bool isNetworkView;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final VoidCallback? onApprove;
  final VoidCallback? onModify;
  final VoidCallback? onReject;

  Future<void> _showMoreActions() async {
    final actions = <CustomBottomSheetActionItem>[
      CustomBottomSheetActionItem(
        title: 'عرض تفاصيل الطلب الكاملة',
        icon: Icons.visibility_outlined,
        onTap: onDetails,
      ),
      if (isNetworkView) ...[
        if (request.isPending && onApprove != null)
          CustomBottomSheetActionItem(
            title: 'اعتماد طلب التوريد',
            icon: Icons.check_circle_outline_rounded,
            onTap: onApprove!,
          ),
        if (request.isPending && onModify != null)
          CustomBottomSheetActionItem(
            title: 'تعديل كميات البنود ومعاينة التسعير',
            icon: Icons.edit_note_rounded,
            onTap: onModify!,
          ),
        if (request.isPending && onReject != null)
          CustomBottomSheetActionItem(
            title: 'رفض طلب التوريد',
            icon: Icons.cancel_outlined,
            isDestructive: true,
            onTap: onReject!,
          ),
      ] else ...[
        if (onEdit != null)
          CustomBottomSheetActionItem(
            title: 'تعديل كميات الطلب',
            icon: Icons.edit_note_rounded,
            onTap: onEdit!,
          ),
        if (onCancel != null)
          CustomBottomSheetActionItem(
            title: 'إلغاء طلب التوريد',
            icon: Icons.cancel_outlined,
            isDestructive: true,
            onTap: onCancel!,
          ),
        if (onDelete != null)
          CustomBottomSheetActionItem(
            title: 'حذف سجل الطلب',
            icon: Icons.delete_outline_rounded,
            isDestructive: true,
            onTap: onDelete!,
          ),
      ],
    ];

    await CustomBottomSheet.showActions<void>(
      title: 'إجراءات طلب التوريد #${request.requestUuid ?? request.requestId}',
      leadingIcon: Icons.receipt_long_rounded,
      items: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isNetworkView) {
      return ProcurementOrderCardNetworkActions(
        isPending: request.isPending,
        onDetails: onDetails,
        onApprove: onApprove,
        onModify: onModify,
        onReject: onReject,
        onMoreActions: _showMoreActions,
      );
    }
    return ProcurementOrderCardPosActions(
      onDetails: onDetails,
      onEdit: onEdit,
      onCancel: onCancel,
      onDelete: onDelete,
      onMoreActions: _showMoreActions,
    );
  }
}
