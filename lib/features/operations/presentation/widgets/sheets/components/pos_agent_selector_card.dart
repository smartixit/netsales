import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

/// ============================================================================
/// بطاقة اختيار أو استعراض نقطة البيع المستهدفة (PosAgentSelectorCard)
/// ============================================================================
/// تدعم عرض نقطة البيع المحددة سلفاً أو الاختيار من النقاط المرتبطة عبر [CustomDropdown] الموحد.
class PosAgentSelectorCard extends StatelessWidget {
  final ValueListenable<int?> posIdNotifier;
  final String? selectedPosName;
  final List<NetworkPosEntity> linkedPosList;
  final bool isPreselected;
  final ValueChanged<NetworkPosEntity> onPosSelected;

  const PosAgentSelectorCard({
    super.key,
    required this.posIdNotifier,
    required this.selectedPosName,
    required this.linkedPosList,
    required this.isPreselected,
    required this.onPosSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // إذا كانت نقطة البيع محددة مسبقاً من سياق الشاشة السابقة
    if (isPreselected || linkedPosList.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: AppRadius.mdRadius,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.4),
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'الوكيل / نقطة البيع المحددة',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.vXxs,
                  Text(
                    selectedPosName ?? 'نقطة بيع #${posIdNotifier.value ?? ""}',
                    style: AppTypography.titleSmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 2.h,
              ),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: AppRadius.fullRadius,
              ),
              child: Text(
                'سياق مثبت',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // إذا كان متاحاً للموزع اختيار نقطة البيع من قائمة الوكلاء المرتبطين
    final dropdownItems = linkedPosList.map((link) {
      return DropdownItem<int>(
        value: link.posId,
        child: Text(
          link.posName ?? 'نقطة بيع #${link.posId}',
        ),
      );
    }).toList();

    return CustomDropdown<int>(
      label: 'نقطة البيع المستلمة للكروت',
      hint: 'اختر نقطة البيع',
      prefixIcon: Icons.storefront_rounded,
      valueListenable: posIdNotifier,
      items: dropdownItems,
      itemSearchText: (posId) =>
          linkedPosList
              .cast<NetworkPosEntity?>()
              .firstWhere((p) => p?.posId == posId, orElse: () => null)
              ?.posName ??
          '',
      onChanged: (posId) {
        if (posId != null) {
          final matched = linkedPosList.firstWhere((p) => p.posId == posId);
          onPosSelected(matched);
        }
      },
    );
  }
}
