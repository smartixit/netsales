
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// تحكم موحد بكمية الكروت: تعديل كرت واحد، ورقة كاملة، أو إدخال يدوي.
class VoucherQuantityStepper extends StatelessWidget {
  final TextEditingController controller;
  final int sheetSize;
  final int currentCount;
  final ValueChanged<int> onCountChanged;
  final String label;
  final bool showPresets;
  final bool showSummaryCard;
  final bool showClearAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onTextChanged;

  const VoucherQuantityStepper({
    super.key,
    required this.controller,
    required this.sheetSize,
    required this.currentCount,
    required this.onCountChanged,
    this.label = 'عدد الكروت المطلوبة',
    this.showPresets = true,
    this.showSummaryCard = true,
    this.showClearAction = true,
    this.validator,
    this.onTextChanged,
  });

  void _changeByCard(int delta) {
    final next = currentCount + delta;
    onCountChanged(next < 0 ? 0 : next);
  }

  void _changeBySheet(int delta) {
    final sheetCards = VoucherSheetCalculator.cardsForSheets(1, sheetSize);
    if (sheetCards <= 0) return;
    final next = currentCount + (delta * sheetCards);
    onCountChanged(next < 0 ? 0 : next);
  }

  void _addPreset(int cards) {
    if (cards > 0) onCountChanged(currentCount + cards);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final presets = showPresets && sheetSize > 0
        ? VoucherSheetCalculator.getPresets(sheetSize)
        : const <VoucherSheetPreset>[];
    final description = currentCount > 0 && sheetSize > 0
        ? VoucherSheetCalculator.describe(currentCount, sheetSize)
        : 'لم تُحدد الكمية بعد';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'التحكم بالكمية',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (showClearAction && currentCount > 0)
                CustomButton.text(
                  text: 'مسح',
                  icon: Icons.delete_sweep_outlined,
                  size: AppButtonSize.small,
                  foregroundColor: colors.error,
                  onPressed: () => onCountChanged(0),
                ),
            ],
          ),
          AppSpacing.vSm,
          if (sheetSize > 0) ...[
            Row(
              children: [
                Expanded(
                  child: CustomButton.outline(
                    text: '− ورقة',
                    icon: Icons.remove_rounded,
                    size: AppButtonSize.small,
                    onPressed: currentCount > 0
                        ? () => _changeBySheet(-1)
                        : null,
                  ),
                ),
                AppSpacing.hSm,
                Expanded(
                  child: CustomButton.outline(
                    text: '+ ورقة',
                    icon: Icons.add_rounded,
                    size: AppButtonSize.small,
                    foregroundColor: colors.primary,
                    borderColor: colors.primary.withValues(alpha: 0.45),
                    onPressed: () => _changeBySheet(1),
                  ),
                ),
              ],
            ),
            AppSpacing.vSm,
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomButton.icon(
                icon: Icons.remove_rounded,
                tooltip: 'إنقاص كرت واحد',
                dimension: 44.r,
                size: AppButtonSize.medium,
                onPressed: currentCount > 0 ? () => _changeByCard(-1) : null,
              ),
              AppSpacing.hSm,
              Expanded(
                child: CustomTextField(
                  controller: controller,
                  label: label,
                  hint: 'أدخل العدد يدوياً',
                  keyboardType: TextInputType.number,
                  inputFormatters: const [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: validator,
                  onChanged: onTextChanged,
                  isRequired: false,
                  textInputAction: TextInputAction.done,
                ),
              ),
              AppSpacing.hSm,
              CustomButton.icon(
                icon: Icons.add_rounded,
                tooltip: 'إضافة كرت واحد',
                dimension: 44.r,
                size: AppButtonSize.medium,
                backgroundColor: colors.primary.withValues(alpha: 0.10),
                foregroundColor: colors.primary,
                onPressed: () => _changeByCard(1),
              ),
            ],
          ),
          AppSpacing.vSm,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16.r,
                color: colors.onSurfaceVariant,
              ),
              AppSpacing.hXs,
              Expanded(
                child: Text(
                  sheetSize > 0
                      ? 'سعة الورقة لهذه الباقة $sheetSize كرت. يمكنك طلب جزء من الورقة أو أي عدد يدوي.'
                      : 'أدخل العدد المطلوب من الكروت يدوياً.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          if (presets.isNotEmpty) ...[
            AppSpacing.vMd,
            Text(
              'إضافات سريعة إلى الكمية الحالية',
              style: AppTypography.labelMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.vXs,
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: presets
                  .map(
                    (preset) => CustomChip(
                      label: '+ ${preset.shortLabel} • ${preset.cards}',
                      icon: Icons.add_rounded,
                      onTap: () => _addPreset(preset.cards),
                      isCompact: true,
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
          if (showSummaryCard && sheetSize > 0) ...[
            AppSpacing.vMd,
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: AppTypography.titleSmall.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.vXxs,
                  Text(
                    currentCount > 0
                        ? 'الإجمالي: $currentCount كرت • سعة الورقة: $sheetSize كرت'
                        : 'اختر كمية لتظهر هنا بصورة وصفية.',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
