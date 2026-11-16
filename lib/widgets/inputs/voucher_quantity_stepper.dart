import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// مكون موحد ومعياري لإدخال كمية كروت الباقات (Voucher Quantity Stepper)
/// يدعم:
/// 1. الإدخال اليدوي المباشر بعدد الكروت عبر لوحة المفاتيح.
/// 2. أزرار التحكم الدقيق (+ ورقة / - ورقة) بمقدار سعة الورقة للباقة مع حماية من الأرقام السالبة.
/// 3. شريط كبسولات الإضافة التراكمية السريعة (+ كبسولات أوراق وأنصاف أوراق).
/// 4. بطاقة التوصيف والتفكيك اللغوي الفصيح لحجم الطلب المعادل دون أي تداخل في النصوص.
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
    this.label = 'عدد الكروت المطلوبة',
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

    final verbalDescription = sheetSize > 0 && currentCount > 0
        ? VoucherSheetCalculator.describe(currentCount, sheetSize)
        : null;

    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // شريط العنوان مع إجراء مسح الكمية
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
              if (showClearAction && currentCount > 0)
                InkWell(
                  onTap: _clear,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    child: Text(
                      'مسح الكمية',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          AppSpacing.vSm,

          // صندوق التحكم الرقمي المركزي (Hero Stepper Row)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                // زر إنقاص ورقة
                CustomButton.outline(
                  text: '- ورقة',
                  size: AppButtonSize.small,
                  icon: Icons.remove_rounded,
                  borderColor: colors.outlineVariant,
                  foregroundColor: colors.onSurface,
                  onPressed: currentCount > 0 ? _stepDown : null,
                ),

                // العرض المركزي المنسق للكمية مع إمكانية التعديل
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          IntrinsicWidth(
                            child: TextField(
                              controller: controller,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: AppTypography.headlineMedium.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: onTextChanged,
                            ),
                          ),
                          AppSpacing.hXxs,
                          Text(
                            'كرت',
                            style: AppTypography.labelMedium.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (verbalDescription != null) ...[
                        AppSpacing.vXxs,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            'يعادل: $verbalDescription',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // زر زيادة ورقة
                CustomButton.outline(
                  text: '+ ورقة',
                  size: AppButtonSize.small,
                  icon: Icons.add_rounded,
                  borderColor: colors.primary.withValues(alpha: 0.5),
                  foregroundColor: colors.primary,
                  onPressed: _stepUp,
                ),
              ],
            ),
          ),

          // كبسولات الإضافة التراكمية السريعة (Quick Add Preset Pills)
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
            Row(
              children: presets.map((preset) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: InkWell(
                      onTap: () => _addQuantity(preset.cards),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: colors.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '+ ${preset.shortLabel}',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '(${preset.cards} كرت)',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.onSurfaceVariant,
                                fontSize: 9.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(growable: false),
            ),
          ],

          // بطاقة التوصيف المعياري وسعة الورقة
          if (showSummaryCard && sheetSize > 0) ...[
            AppSpacing.vSm,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'سعة الورقة للباقة: $sheetSize كرت',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (currentCount > 0)
                  Text(
                    'الإجمالي المحتسب: $currentCount كرت',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
