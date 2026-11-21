import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_nav_item.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

class WorkspaceMoreNavigationSheet extends StatelessWidget {
  const WorkspaceMoreNavigationSheet({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onSelected,
  });

  final List<WorkspaceNavItem> items;
  final WorkspaceNavItem? selectedItem;
  final ValueChanged<WorkspaceNavItem> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.72,
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.topXl,
          boxShadow: AppElevation.level5(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: AppSpacing.xxs,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: AppRadius.fullRadius,
                ),
              ),
            ),
            AppSpacing.vLg,
            Text(
              'المزيد من مساحة العمل',
              style: AppTypography.titleMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vMd,
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, _) => AppSpacing.vXs,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = identical(item, selectedItem);
                  return CustomInteractiveBounce(
                    onTap: () => onSelected(item),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary.withValues(alpha: 0.10)
                            : colors.surfaceContainerLow,
                        borderRadius: AppRadius.mdRadius,
                        border: Border.all(
                          color: isSelected
                              ? colors.primary.withValues(alpha: 0.35)
                              : colors.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            size: 20.r,
                            color: isSelected
                                ? colors.primary
                                : colors.onSurfaceVariant,
                          ),
                          AppSpacing.hMd,
                          Expanded(
                            child: Text(
                              item.label,
                              style: AppTypography.labelLarge.copyWith(
                                color: colors.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (item.badgeCount != null && item.badgeCount! > 0)
                            Text(
                              item.badgeCount.toString(),
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          AppSpacing.hSm,
                          Icon(
                            Icons.chevron_left_rounded,
                            size: 18.r,
                            color: colors.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
