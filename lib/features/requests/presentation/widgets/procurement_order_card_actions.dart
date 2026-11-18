import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
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
    final colors = context.colors;

    if (isNetworkView) {
      return _buildNetworkActions(context, colors);
    }
    return _buildPosActions(context, colors);
  }

  /// أزرار إجراءات مساحة نقطة البيع (POS)
  Widget _buildPosActions(BuildContext context, AppColors colors) {
    return Row(
      children: [
        Expanded(
          child: CustomButton.outline(
            text: 'عرض التفاصيل',
            icon: Icons.chevron_right_rounded,
            iconPosition: AppButtonIconPosition.end,
            size: AppButtonSize.small,
            foregroundColor: colors.primary,
            borderColor: colors.primary.withValues(alpha: .6),
            onPressed: onDetails,
          ),
        ),
        if (onEdit != null) ...[
          AppSpacing.hXs,
          CustomButton.icon(
            icon: Icons.edit_note_rounded,
            tooltip: 'تعديل الطلب',
            dimension: 38.r,
            backgroundColor: colors.surfaceContainer,
            foregroundColor: colors.primary,
            borderColor: colors.primary.withValues(alpha: .3),
            onPressed: onEdit,
          ),
        ],
        if (onCancel != null) ...[
          AppSpacing.hXs,
          CustomButton.icon(
            icon: Icons.cancel_outlined,
            tooltip: 'إلغاء الطلب',
            dimension: 38.r,
            backgroundColor: colors.error.withValues(alpha: .08),
            foregroundColor: colors.error,
            borderColor: colors.error.withValues(alpha: .25),
            onPressed: onCancel,
          ),
        ],
        if (onDelete != null) ...[
          AppSpacing.hXs,
          CustomButton.icon(
            icon: Icons.delete_outline_rounded,
            tooltip: 'حذف سجل الطلب',
            dimension: 38.r,
            backgroundColor: colors.error.withValues(alpha: .08),
            foregroundColor: colors.error,
            borderColor: colors.error.withValues(alpha: .25),
            onPressed: onDelete,
          ),
        ],
        AppSpacing.hXs,
        CustomButton.icon(
          icon: Icons.more_horiz_rounded,
          tooltip: 'المزيد من الخيارات',
          dimension: 38.r,
          backgroundColor: colors.surfaceContainer,
          foregroundColor: colors.onSurfaceVariant,
          borderColor: colors.outlineVariant.withValues(alpha: .6),
          onPressed: _showMoreActions,
        ),
      ],
    );
  }

  /// أزرار إجراءات مساحة شبكة التوزيع (Network)
  Widget _buildNetworkActions(BuildContext context, AppColors colors) {
    if (request.isPending) {
      return Row(
        children: [
          if (onApprove != null)
            Expanded(
              flex: 4,
              child: CustomButton(
                text: 'اعتماد الطلب',
                icon: Icons.check_circle_outline_rounded,
                size: AppButtonSize.small,
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                onPressed: onApprove,
              ),
            ),
          if (onModify != null) ...[
            AppSpacing.hXs,
            Expanded(
              flex: 3,
              child: CustomButton.outline(
                text: 'تعديل',
                icon: Icons.edit_note_rounded,
                size: AppButtonSize.small,
                foregroundColor: colors.primary,
                borderColor: colors.primary.withValues(alpha: .5),
                onPressed: onModify,
              ),
            ),
          ],
          if (onReject != null) ...[
            AppSpacing.hXs,
            CustomButton.icon(
              icon: Icons.cancel_outlined,
              tooltip: 'رفض الطلب',
              dimension: 38.r,
              backgroundColor: colors.error.withValues(alpha: .08),
              foregroundColor: colors.error,
              borderColor: colors.error.withValues(alpha: .25),
              onPressed: onReject,
            ),
          ],
          AppSpacing.hXs,
          CustomButton.icon(
            icon: Icons.more_horiz_rounded,
            tooltip: 'المزيد من الخيارات',
            dimension: 38.r,
            backgroundColor: colors.surfaceContainer,
            foregroundColor: colors.onSurfaceVariant,
            borderColor: colors.outlineVariant.withValues(alpha: .6),
            onPressed: _showMoreActions,
          ),
        ],
      );
    }

    // الطلبات المكتملة أو المرفوضة أو الملغية
    return Row(
      children: [
        Expanded(
          child: CustomButton.outline(
            text: 'عرض تفاصيل الطلب',
            icon: Icons.chevron_right_rounded,
            iconPosition: AppButtonIconPosition.end,
            size: AppButtonSize.small,
            foregroundColor: colors.primary,
            borderColor: colors.primary.withValues(alpha: .6),
            onPressed: onDetails,
          ),
        ),
        AppSpacing.hXs,
        CustomButton.icon(
          icon: Icons.more_horiz_rounded,
          tooltip: 'المزيد من الخيارات',
          dimension: 38.r,
          backgroundColor: colors.surfaceContainer,
          foregroundColor: colors.onSurfaceVariant,
          borderColor: colors.outlineVariant.withValues(alpha: .6),
          onPressed: _showMoreActions,
        ),
      ],
    );
  }
}
