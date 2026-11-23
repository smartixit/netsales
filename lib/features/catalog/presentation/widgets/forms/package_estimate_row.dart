import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// سطر حساب تقديري في نموذج الباقة (Package Estimate Row)
///
/// يعتمد 100% على توكنز [AppSpacing] و [AppRadius]
class PackageEstimateRow extends StatelessWidget {
  const PackageEstimateRow({
    super.key,
    required this.label,
    required this.value,
    this.badgeText,
    required this.color,
  });

  final String label;
  final String value;
  final String? badgeText;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: color.withValues(alpha: 0.85),
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badgeText != null) ...[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs + AppSpacing.xxs,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  badgeText!,
                  style: AppTypography.badgeText.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.xs),
            ],
            Text(
              value,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
