import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

class CustomErrorState extends StatelessWidget {
  const CustomErrorState({
    super.key,
    required this.title,
    this.subtitle,
    this.retryLabel = 'إعادة المحاولة',
    this.onRetry,
  });

  final String title;
  final String? subtitle;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 160.w,
                height: 160.w,
                child: Lottie.asset(
                  'assets/animations/error.json',
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
              if (onRetry != null) ...[
                AppSpacing.vXs,
                CustomButton.text(
                  text: retryLabel,
                  icon: Icons.refresh_rounded,
                  onPressed: onRetry!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
