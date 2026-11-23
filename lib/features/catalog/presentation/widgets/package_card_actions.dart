import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// شريط إجراءات بطاقة الباقة التنفيذية (Package Card Actions)
class PackageCardActions extends StatelessWidget {
  const PackageCardActions({
    super.key,
    required this.package,
    required this.onDetails,
    this.onEdit,
    this.onToggleStatus,
    this.onDelete,
    this.canEdit = true,
    this.canDelete = true,
  });

  final PackageEntity package;
  final VoidCallback onDetails;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;
  final bool canEdit;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton.secondary(
            text: 'التفاصيل',
            icon: Icons.visibility_outlined,
            size: AppButtonSize.small,
            shape: AppButtonShape.rounded,
            onPressed: onDetails,
          ),
        ),
        if (canEdit && onToggleStatus != null) ...[
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: CustomButton.outline(
              text: package.isActive ? 'تعطيل' : 'تفعيل',
              icon: package.isActive
                  ? Icons.pause_circle_outline_rounded
                  : Icons.check_circle_outline_rounded,
              size: AppButtonSize.small,
              shape: AppButtonShape.rounded,
              onPressed: onToggleStatus,
            ),
          ),
        ],
        if (canEdit && onEdit != null) ...[
          SizedBox(width: AppSpacing.xs),
          CustomButton.icon(
            icon: Icons.edit_outlined,
            tooltip: 'تعديل الباقة',
            shape: AppButtonShape.rounded,
            onPressed: onEdit,
          ),
        ],
        if (canDelete && onDelete != null) ...[
          SizedBox(width: AppSpacing.xs),
          CustomButton.icon(
            icon: Icons.delete_outline_rounded,
            tooltip: 'حذف الباقة',
            shape: AppButtonShape.rounded,
            onPressed: onDelete,
          ),
        ],
      ],
    );
  }
}
