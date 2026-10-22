import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/home/presentation/models/home_quick_action.dart';
import 'package:netsales/widgets/animations/custom_interactive_bounce.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// ============================================================================
/// ورقة الإجراءات السريعة المنبثقة (HomeQuickActionsSheet)
/// ============================================================================
/// نافذة سفلية عصرية ذات وصول مباشر تعرض حصراً الإجراءات المصرح بها للمستخدم.
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
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HomeQuickActionsSheet(
        actions: actions,
        onActionTap: onActionTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.cardPadding,
        AppSpacing.md,
        AppSpacing.cardPadding,
        AppSpacing.cardPadding + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        boxShadow: AppElevation.level5(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // مقبض السحب العلوي (Drag Handle)
          Center(
            child: Container(
              width: 44.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),

          AppSpacing.vMd,

          // ترويسة النافذة
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bolt_rounded,
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
                      'الإجراءات السريعة المباشرة',
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'اختر الإجراء الذي ترغب بتنفيذه فوراً بدون مغادرة سياقك',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpacing.vLg,

          // قائمة بطاقات الإجراءات المتاحة
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final action in actions) ...[
                    _QuickActionCard(
                      action: action,
                      onTap: () {
                        Navigator.pop(context);
                        onActionTap(action);
                      },
                    ),
                    AppSpacing.vSm,
                  ],
                ],
              ),
            ),
          ),

          AppSpacing.vMd,

          // زر إغلاق النافذة
          CustomButton.outline(
            text: 'إلغاء',
            foregroundColor: colors.onSurface,
            borderColor: colors.outlineVariant,
            width: double.infinity,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

/// بطاقة الإجراء الفردية المستقلة
class _QuickActionCard extends StatelessWidget {
  final HomeQuickAction action;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.action,
    required this.onTap,
  });

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
                child: Icon(
                  action.icon,
                  color: colors.primary,
                  size: 22.r,
                ),
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
