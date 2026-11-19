import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/widgets/package_option_card/procurement_max_quantity_formatter.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// عناصر التحكم بالكمية (أزرار الزيادة والنقصان، الإدخال، وأزرار الورقة والنصف والتصفير)
class ProcurementPackageQuantityControls extends StatelessWidget {
  const ProcurementPackageQuantityControls({
    super.key,
    required this.quantity,
    required this.controller,
    required this.sheetCapacity,
    required this.halfCapacity,
    required this.unitLabel,
    required this.onChanged,
  });

  final int quantity;
  final TextEditingController controller;
  final int sheetCapacity;
  final int halfCapacity;
  final String unitLabel;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الكمية المطلوبة',
          style: AppTypography.labelMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        AppSpacing.vSm,
        Row(
          children: [
            CustomButton.icon(
              icon: Icons.add_rounded,
              tooltip: 'إضافة $unitLabel',
              dimension: 36.r,
              size: AppButtonSize.small,
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              onPressed: () => onChanged((quantity + 1).clamp(0, 1000000)),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 7.r),
                child: CustomTextField(
                  controller: controller,
                  label: '',
                  hint: '0',
                  isRequired: false,
                  isDense: true,
                  textAlign: TextAlign.center,
                  textStyle: AppTypography.inputText.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 3.r,
                    vertical: 6.r,
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    const ProcurementMaxQuantityFormatter(1000000),
                  ],
                  onChanged: (value) {
                    final parsed = int.tryParse(value) ?? 0;
                    onChanged(parsed.clamp(0, 1000000));
                  },
                ),
              ),
            ),
            CustomButton.icon(
              icon: Icons.remove_rounded,
              tooltip: 'إنقاص $unitLabel',
              dimension: 36.r,
              size: AppButtonSize.small,
              backgroundColor: colors.surfaceContainerLow,
              foregroundColor: colors.onSurfaceVariant,
              onPressed: quantity > 0 ? () => onChanged(quantity - 1) : null,
            ),
            AppSpacing.hXs,
            Text(
              unitLabel,
              style: AppTypography.labelSmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        AppSpacing.vSm,
        Row(
          children: [
            Expanded(
              child: CustomButton.outline(
                text: 'ورقة',
                icon: Icons.note_add_outlined,
                size: AppButtonSize.small,
                foregroundColor: colors.onSurfaceVariant,
                borderColor: colors.outlineVariant,
                onPressed: () =>
                    onChanged((quantity + sheetCapacity).clamp(0, 1000000)),
              ),
            ),
            AppSpacing.hXs,
            Expanded(
              child: CustomButton.outline(
                text: 'نصف',
                icon: Icons.description_outlined,
                size: AppButtonSize.small,
                foregroundColor: colors.onSurfaceVariant,
                borderColor: colors.outlineVariant,
                onPressed: () =>
                    onChanged((quantity + halfCapacity).clamp(0, 1000000)),
              ),
            ),
            AppSpacing.hXs,
            Expanded(
              child: CustomButton.outline(
                text: 'تصفير',
                icon: Icons.refresh_rounded,
                size: AppButtonSize.small,
                foregroundColor: colors.error,
                borderColor: colors.error.withValues(alpha: .55),
                onPressed: quantity > 0 ? () => onChanged(0) : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
