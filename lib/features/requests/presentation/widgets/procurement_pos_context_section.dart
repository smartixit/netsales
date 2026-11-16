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

/// سياق نقطة البيع المحددة للطلب.
class ProcurementPosContextSection extends GetView<PosProcurementController> {
  const ProcurementPosContextSection({super.key});

  @override
  /// بطاقة سياق نقطة البيع
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نقطة البيع المنفذة للطلب',
          style: AppTypography.titleSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.vXs,
        Obx(() {
          final posList = controller.myPosList;
          if (posList.isEmpty) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: colors.error.withValues(alpha: 0.28)),
              ),
              child: Text(
                'لا توجد نقاط بيع معتمدة ومصرح بها لحسابك حالياً.',
                style: AppTypography.bodySmall.copyWith(color: colors.error),
              ),
            );
          }

          if (posList.length == 1 || controller.isEditing.value) {
            final pos = controller.activePos ?? posList.first;
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
                      Icons.storefront_rounded,
                      color: colors.primary,
                      size: 20.r,
                    ),
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pos.posName,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        if (pos.posAddress != null &&
                            pos.posAddress!.isNotEmpty)
                          Text(
                            pos.posAddress!,
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const CustomStatusBadge(
                    label: 'نقطة معتمدة',
                    tone: SemanticTone.success,
                    icon: Icons.verified_rounded,
                    isCompact: true,
                  ),
                ],
              ),
            );
          }

          return CustomDropdown<int>(
            label: 'اختر نقطة البيع للطلب',
            hint: 'حدد نقطة البيع التي تريد التوريد إليها',
            searchEnabled: posList.length > 5,
            rxValue: controller.selectedPosId,
            items: posList
                .map((pos) {
                  return DropdownItem<int>(
                    value: pos.posId,
                    child: Text('${pos.posName} (#${pos.posId})'),
                  );
                })
                .toList(growable: false),
            onChanged: (id) {
              if (id != null) controller.onPosSelected(id);
            },
          );
        }),
      ],
    );
  }
}
