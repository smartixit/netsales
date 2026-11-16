import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

/// الشبكة الموردة المرتبطة بنقطة البيع.
class ProcurementNetworkContextSection extends GetView<PosProcurementController> {
  const ProcurementNetworkContextSection({super.key});

  @override
  /// بطاقة سياق الشبكة الموردة
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الشبكة الموردة للكروت',
          style: AppTypography.titleSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.vXs,
        Obx(() {
          if (controller.isLoadingNetworks.value) {
            return const LinearProgressIndicator();
          }

          final networks = controller.linkedNetworks;
          if (networks.isEmpty) {
            return Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                'لا توجد شبكات موردة نشطة مرتبطة بنقطة البيع حالياً.',
                style: AppTypography.bodySmall.copyWith(color: colors.error),
              ),
            );
          }

          if (networks.length == 1 || controller.isEditing.value) {
            final net = networks.firstWhereOrNull(
                  (n) => n.networkId == controller.selectedNetworkId.value,
                ) ??
                networks.first;
            final netName = net.network?.networkName ?? 'شبكة #${net.networkId}';

            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cell_tower_rounded,
                      color: colors.primary,
                      size: 20.r,
                    ),
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: Text(
                      netName,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  const CustomStatusBadge(
                    label: 'شبكة موردة',
                    tone: SemanticTone.info,
                    icon: Icons.hub_rounded,
                    isCompact: true,
                  ),
                ],
              ),
            );
          }

          return CustomDropdown<int>(
            label: 'اختر الشبكة الموردة',
            searchEnabled: false,
            rxValue: controller.selectedNetworkId,
            items: networks.map((link) {
              return DropdownItem<int>(
                value: link.networkId,
                child: Text(
                  link.network?.networkName ?? 'شبكة #${link.networkId}',
                ),
              );
            }).toList(),
            onChanged: (id) {
              if (id != null) controller.onNetworkSelected(id);
            },
          );
        }),
      ],
    );
  }
}
