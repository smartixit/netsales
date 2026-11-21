import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// شريط أزرار الإجراءات السريعة لبطاقة باقة الكروت (Package Card Actions)
class PackageCardActions extends StatelessWidget {
  const PackageCardActions({
    super.key,
    required this.package,
    required this.onDetails,
    this.onEdit,
    this.onToggleStatus,
    this.onDelete,
  });

  final PackageEntity package;
  final VoidCallback onDetails;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;

  void _showMoreActions(BuildContext context) {
    CustomBottomSheet.showActions<void>(
      title: 'إجراءات الباقة: ${package.packageName}',
      subtitle: 'إدارة وتحديث باقة كروت الإنترنت وتعديل حالتها',
      items: [
        CustomBottomSheetActionItem(
          title: 'عرض التفاصيل الكاملة',
          subtitle: 'استعراض مواصفات الكرت والأسعار والخصومات التعاقدية',
          icon: Icons.visibility_outlined,
          onTap: onDetails,
        ),
        if (onEdit != null)
          CustomBottomSheetActionItem(
            title: 'تعديل بيانات الباقة',
            subtitle: 'تحديث الأسعار ونسب الخصم والمواصفات الفنية',
            icon: Icons.edit_outlined,
            onTap: onEdit!,
          ),
        if (onToggleStatus != null)
          CustomBottomSheetActionItem(
            title: package.status ? 'تعطيل الباقة مؤقتاً' : 'تفعيل الباقة الآن',
            subtitle: package.status
                ? 'إيقاف شراء كروت جديدة من هذه الباقة للوكلاء'
                : 'إتاحة الباقة للشراء والطلب لنقاط البيع المعتمدة',
            icon: package.status
                ? Icons.pause_circle_outline_rounded
                : Icons.play_circle_outline_rounded,
            onTap: onToggleStatus!,
          ),
        if (onDelete != null)
          CustomBottomSheetActionItem(
            title: 'حذف الباقة',
            subtitle: 'نقل هذه الباقة إلى سلة المحذوفات',
            icon: Icons.delete_outline_rounded,
            isDestructive: true,
            onTap: onDelete!,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasExtendedActions = onToggleStatus != null || onDelete != null;

    return Row(
      children: [
        // زر عرض التفاصيل الرئيسي
        Expanded(
          child: CustomButton.secondary(
            text: 'التفاصيل',
            icon: Icons.visibility_outlined,
            size: AppButtonSize.small,
            shape: AppButtonShape.rounded,
            onPressed: onDetails,
          ),
        ),

        // زر التعديل السريع إن وُجدت الصلاحية
        if (onEdit != null) ...[
          AppSpacing.hXs,
          CustomButton.outline(
            text: 'تعديل',
            icon: Icons.edit_outlined,
            size: AppButtonSize.small,
            shape: AppButtonShape.rounded,
            onPressed: onEdit,
          ),
        ],

        // زر القائمة السفلية الموسعة للإجراءات الإدارية
        if (hasExtendedActions) ...[
          AppSpacing.hXs,
          CustomButton.icon(
            icon: Icons.more_horiz_rounded,
            tooltip: 'خيارات إضافية للباقة',
            backgroundColor: colors.surfaceContainer.withValues(alpha: 0.5),
            foregroundColor: colors.onSurfaceVariant,
            shape: AppButtonShape.rounded,
            size: AppButtonSize.small,
            onPressed: () => _showMoreActions(context),
          ),
        ],
      ],
    );
  }
}
