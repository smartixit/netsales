import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

/// ترويسة بطاقة الباقة التنفيذية (Package Card Header)
///
/// تدمج هوية الشبكة ورقم المعرف مع شارة الحالة وقائمة الإجراءات السياقية الرشيقة
class PackageCardHeader extends StatelessWidget {
  const PackageCardHeader({
    super.key,
    required this.package,
    required this.accentColor,
    this.onEdit,
    this.onToggleStatus,
    this.onDelete,
    this.canEdit = true,
    this.canDelete = true,
  });

  final PackageEntity package;
  final Color accentColor;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;
  final bool canEdit;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusPres = EnumPresentationRegistry.resolvePackageStatus(
      package.packageStatus,
    );

    final hasActions =
        (canEdit && (onEdit != null || onToggleStatus != null)) ||
        (canDelete && onDelete != null);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // شريحة أيقونة شبكة الإنترنت
        Container(
          width: 38.r,
          height: 38.r,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.sensors_rounded,
              size: 20.r,
              color: accentColor,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.sm),

        // اسم الباقة وهوية الشبكة
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                package.packageName,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  if (package.networkName != null) ...[
                    Flexible(
                      child: Text(
                        package.networkName!,
                        style: AppTypography.badgeText.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '•',
                      style: AppTypography.badgeText.copyWith(
                        color: colors.outlineVariant,
                      ),
                    ),
                    SizedBox(width: 4.w),
                  ],
                  Text(
                    'باقة #${package.packageId}',
                    style: AppTypography.badgeText.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(width: AppSpacing.xs),

        // شارة الحالة الرسمية
        CustomStatusBadge(
          label: statusPres.label,
          icon: statusPres.icon,
          tone: statusPres.tone,
        ),

        // قائمة الخيارات الإدارية المدمجة الرشيقة
        if (hasActions) ...[
          SizedBox(width: 2.w),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              size: 20.r,
              color: colors.onSurfaceVariant,
            ),
            tooltip: 'خيارات الباقة',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            color: colors.surface,
            elevation: 4,
            padding: EdgeInsets.zero,
            onSelected: (value) {
              if (value == 'edit') onEdit?.call();
              if (value == 'status') onToggleStatus?.call();
              if (value == 'delete') onDelete?.call();
            },
            itemBuilder: (context) => [
              if (canEdit && onEdit != null)
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18.r, color: colors.primary),
                      SizedBox(width: AppSpacing.xs),
                      Text('تعديل الباقة', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
              if (canEdit && onToggleStatus != null)
                PopupMenuItem(
                  value: 'status',
                  child: Row(
                    children: [
                      Icon(
                        package.isActive
                            ? Icons.pause_circle_outline_rounded
                            : Icons.play_circle_outline_rounded,
                        size: 18.r,
                        color: package.isActive
                            ? colors.amberAccent
                            : colors.success,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        package.isActive ? 'تعطيل الباقة' : 'تفعيل الباقة',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              if (canDelete && onDelete != null)
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 18.r,
                        color: colors.error,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        'حذف الباقة',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
