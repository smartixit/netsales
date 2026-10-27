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
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
