import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

class CustomEmptyState extends StatelessWidget {
  const CustomEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  }) : compact = false;

  /// نسخة مضغوطة مخصّصة للحاويات محدودة الارتفاع (المخططات، الشرائط، البطاقات)
  /// بلا رسوم Lottie ولا تمرير، مع الحفاظ على نفس الهوية النصية.
  const CustomEmptyState.compact({super.key, required this.title})
    : subtitle = null,
      actionLabel = null,
      onAction = null,
      compact = true;

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (compact) return _CompactEmptyStateBody(title: title);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 160.w,
              height: 160.w,
              child: Lottie.asset(
                'assets/animations/no_data.json',
                repeat: true,
              ),
            ),
            AppSpacing.vMd,
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                color: colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              AppSpacing.vXs,
              Text(
                subtitle!,
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.vXs,
              CustomButton.text(text: actionLabel!, onPressed: onAction!),
            ],
          ],
        ),
      ),
    );
  }
}

/// جسم الحالة الفارغة المضغوطة — أيقونة هادئة ونص توجيهي بلا رسوم متحركة.
class _CompactEmptyStateBody extends StatelessWidget {
  const _CompactEmptyStateBody({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insights_rounded,
            size: 20.r,
            color: colors.onSurfaceVariant.withValues(alpha: 0.45),
          ),
          AppSpacing.vXs,
          Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
