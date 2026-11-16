
import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// بطاقة وصفية لباقة الشبكة، تفصل مواصفاتها وسعة ورقتها عن التسعير.
class ProcurementPackageOptionCard extends StatelessWidget {
  const ProcurementPackageOptionCard({
    super.key,
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  final PackageEntity package;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final packageColor = CustomColorPicker.parseHex(package.packageColor);

    return CustomInteractiveBounce(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.055)
              : colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.60)
                : colors.outlineVariant.withValues(alpha: 0.40),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: packageColor.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.wifi_tethering_rounded,
                    color: packageColor,
                    size: 22,
                  ),
                ),
                AppSpacing.hSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.packageName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.vXxs,
                      Text(
                        'مواصفات الباقة',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  CustomChip(
                    label: 'محددة',
                    icon: Icons.check_circle_rounded,
                    isCompact: true,
                  ),
              ],
            ),
            AppSpacing.vSm,
            Row(
              children: [
                Icon(
                  Icons.layers_outlined,
                  size: 16,
                  color: colors.primary,
                ),
                AppSpacing.hXs,
                Expanded(
                  child: Text(
                    'الورقة الواحدة تحتوي ${package.packageVoucherCount} كرت',
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.vSm,
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.xs,
              children: [
                _PackageSpec(
                  icon: Icons.data_usage_outlined,
                  label: package.balanceDisplay,
                ),
                _PackageSpec(
                  icon: Icons.timer_outlined,
                  label: package.uptimeDisplay,
                ),
                _PackageSpec(
                  icon: Icons.event_available_outlined,
                  label: package.validityDisplay,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageSpec extends StatelessWidget {
  const _PackageSpec({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colors.onSurfaceVariant),
        AppSpacing.hXxs,
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
