import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/home/presentation/models/home_quick_action.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// ============================================================================
/// ورقة الإجراءات السريعة المنبثقة (HomeQuickActionsSheet)
/// ============================================================================
/// نافذة سفلية عصرية تعتمد على [CustomBottomSheet] وتعرض حصراً الإجراءات المصرح بها للمستخدم.
class HomeQuickActionsSheet extends StatelessWidget {
  final List<HomeQuickAction> actions;
  final ValueChanged<HomeQuickAction> onActionTap;

  const HomeQuickActionsSheet({
    super.key,
    required this.actions,
    required this.onActionTap,
  });

  /// عرض النافذة السفلية المنبثقة
  static Future<void> show(
    BuildContext context, {
    required List<HomeQuickAction> actions,
    required ValueChanged<HomeQuickAction> onActionTap,
  }) {

    return CustomBottomSheet.show<void>(
      title: 'الإجراءات السريعة المباشرة',
      subtitle: 'اختر الإجراء الذي ترغب بتنفيذه فوراً بدون مغادرة سياقك',
      leadingIcon: Icons.bolt_rounded,
      scrollable: true,
      actions: [
        Expanded(
          child: CustomButton.outline(
            text: 'إلغاء',
            onPressed: () => Get.back(),
          ),
        ),
      ],
      child: HomeQuickActionsSheet(actions: actions, onActionTap: onActionTap),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final action in actions) ...[
          _QuickActionCard(
            action: action,
            onTap: () {
              Get.back();
              onActionTap(action);
            },
          ),
          AppSpacing.vSm,
        ],
      ],
    );
  }
}

/// بطاقة الإجراء الفردية المستقلة
class _QuickActionCard extends StatelessWidget {
  final HomeQuickAction action;
  final VoidCallback onTap;

  const _QuickActionCard({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.5),
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Center(
                child: Icon(action.icon, color: colors.primary, size: 22.r),
              ),
            ),
            AppSpacing.hMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: AppTypography.labelLarge.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.vXxs,
                  Text(
                    action.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            AppSpacing.hSm,
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.r,
              color: colors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
