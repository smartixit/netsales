import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// مكون موحد ومعياري لإدخال كمية كروت الباقات (Voucher Quantity Stepper)
/// يدعم:
/// 1. الإدخال اليدوي المباشر بعدد الكروت.
/// 2. أزرار التحكم الدقيق (+ ورقة / - ورقة) بمقدار سعة الورقة للباقة مع حماية من الأرقام السالبة.
/// 3. شريط كبسولات الإضافة التراكمية السريعة (+ كبسولات أوراق وأنصاف أوراق).
/// 4. بطاقة التوصيف والتفكيك اللغوي الفصيح لحجم الطلب المعادل.
/// 5. زر المسح والتصفير السريع.
class VoucherQuantityStepper extends StatelessWidget {
  /// متحكم حقل الإدخال النصي
  final TextEditingController controller;

  /// سعة الورقة الواحدة للباقة المختارة (تأتي من الباكيند packageVoucherCount)
  final int sheetSize;

  /// القيمة الحالية بعدد الكروت
  final int currentCount;

  /// دالة تحديث القيمة عند الزيادة أو النقص أو الإدخال التراكمي
  final ValueChanged<int> onCountChanged;

  /// عنوان الحقل
  final String label;

  /// هل يتم إظهار كبسولات الإضافة التراكمية السريعة؟
  final bool showPresets;

  /// هل يتم إظهار بطاقة الملخص والتفكيك المقابل للأوراق؟
  final bool showSummaryCard;

  /// هل يتم إظهار زر مسح وتصفير الكمية؟
  final bool showClearAction;

  /// إمكانية إضافة التحقق المخصص
  final FormFieldValidator<String>? validator;

  /// دالة اختيارية تنفذ عند تغيير النص يدوياً
  final ValueChanged<String>? onTextChanged;

  const VoucherQuantityStepper({
    super.key,
    required this.controller,
    required this.sheetSize,
    required this.currentCount,
    required this.onCountChanged,
    this.label = 'عدد الكروت',
    this.showPresets = true,
    this.showSummaryCard = true,
    this.showClearAction = true,
    this.validator,
    this.onTextChanged,
  });

  /// زيادة ورقة كاملة وفق سعة الورقة للباقة
  void _stepUp() {
    final step = sheetSize > 0 ? sheetSize : 1;
    onCountChanged(currentCount + step);
  }

  /// إنقاص ورقة كاملة مع حظر الأرقام السالبة نهائياً (Zero Clamp)
  void _stepDown() {
    if (currentCount <= 0) return;
    final step = sheetSize > 0 ? sheetSize : 1;
    final target = math.max(0, currentCount - step);
    onCountChanged(target);
  }

  /// إضافة كمية تراكمية
  void _addQuantity(int count) {
    if (count <= 0) return;
    onCountChanged(currentCount + count);
  }

  /// تصفير الكمية
  void _clear() {
    onCountChanged(0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final presets = showPresets && sheetSize > 0
        ? VoucherSheetCalculator.getPresets(sheetSize)
        : const <VoucherSheetPreset>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showClearAction)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (currentCount > 0)
                GestureDetector(
                  onTap: _clear,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    child: Text(
                      'مسح الكمية',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        AppSpacing.vXs,

        // صف أزرار الزيادة والإنقاص وحقل الإدخال المباشر
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // زر إنقاص ورقة
            SizedBox(
              height: 48,
              child: CustomButton.outline(
                text: '- ورقة',
                size: AppButtonSize.small,
                icon: Icons.remove_rounded,
                onPressed: currentCount > 0 ? _stepDown : null,
              ),
            ),
            AppSpacing.hSm,

            // حقل إدخال الكروت المباشر
            Expanded(
              child: CustomTextField(
                controller: controller,
                label: label,
                hint: sheetSize > 0
                    ? 'سعة الورقة: $sheetSize كرت'
                    : 'أدخل عدد الكروت',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.style_outlined),
                onChanged: onTextChanged,
                validator:
                    validator ??
                    FormValidators.positiveIntegerValidator(
                      fieldName: label,
                      min: 1,
                    ),
              ),
            ),
            AppSpacing.hSm,

            // زر زيادة ورقة
            SizedBox(
              height: 48,
              child: CustomButton.outline(
                text: '+ ورقة',
                size: AppButtonSize.small,
                icon: Icons.add_rounded,
                onPressed: _stepUp,
              ),
            ),
          ],
        ),

        // شريط الكبسولات التراكمية السريعة
        if (presets.isNotEmpty) ...[
          AppSpacing.vSm,
          Text(
            'إضافة سريعة تراكمية (انقر للإضافة إلى الإجمالي):',
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          AppSpacing.vXs,
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: presets
                .map((preset) {
                  return CustomButton.outline(
                    text: '+ ${preset.shortLabel} (${preset.cards})',
                    size: AppButtonSize.small,
                    onPressed: () => _addQuantity(preset.cards),
                  );
                })
                .toList(growable: false),
          ),
        ],

        // بطاقة ملخص تفكيك الكروت وسعة الأوراق
        if (showSummaryCard && sheetSize > 0 && currentCount > 0) ...[
          AppSpacing.vSm,
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.fact_check_outlined,
                  color: colors.primary,
                  size: AppSpacing.lg,
                ),
                AppSpacing.hSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إجمالي الكروت: $currentCount كرت',
                        style: AppTypography.bodyMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.vXxs,
                      Text(
                        'المعادل: ${VoucherSheetCalculator.describe(currentCount, sheetSize)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'سعة الورقة للباقة: $sheetSize كرت',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
