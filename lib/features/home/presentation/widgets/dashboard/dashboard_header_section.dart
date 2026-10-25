import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// ترويسة لوحة القيادة التفاعلية (DashboardHeaderSection)
/// ============================================================================
/// تعرض اسم وهوية الكيان النشط (شبكة أو نقطة بيع) مع شريط تبديل الفترات الزمنية.
class DashboardHeaderSection extends StatelessWidget {
  final DashboardController controller;

  const DashboardHeaderSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final ctx = controller.contextData;
      final roleLabel = controller.overview.value?.roleLabel ?? '';
      final displayName = ctx?.displayName ?? 'منظومة NetSales';
      final code = ctx?.displayCode ?? '';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // سطر الهوية والترحيب
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: AppTypography.titleLarge.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (code.isNotEmpty) ...[
                          AppSpacing.hSm,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.1),
                              borderRadius: AppRadius.smRadius,
                              border: Border.all(
                                color: colors.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              code,
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    AppSpacing.vXxs,
                    Text(
                      roleLabel.isNotEmpty ? roleLabel : 'لوحة القيادة والمتابعة اللحظية',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpacing.vMd,

          // شريط اختيار الفترة الزمنية التفاعلي (Horizontal Period Pills)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: DashboardController.periods.map((p) {
                final isSelected = controller.selectedPeriod.value == p['key'];
                return Padding(
                  padding: EdgeInsetsDirectional.only(end: AppSpacing.sm),
                  child: CustomInteractiveBounce(
                    onTap: () => controller.changePeriod(p['key']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.primary : colors.surface,
                        borderRadius: AppRadius.fullRadius,
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        p['label']!,
                        style: AppTypography.labelMedium.copyWith(
                          color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    });
  }
}

