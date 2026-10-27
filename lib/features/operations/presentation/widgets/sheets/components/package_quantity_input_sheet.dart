import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// ============================================================================
/// نافذة تحديد كمية باقة الكروت بالأوراق والكروت (PackageQuantityInputSheet)
/// ============================================================================
/// تتيح إدخال الكمية المزدوج بدقة (إما بعدد الأوراق أو بعدد الكروت الفعلي)
/// مع تحويل فوري متزامن وتطبيق مباشر لقاعدة قص الورقة الفردية (51 -> 26).
class PackageQuantityInputSheet extends StatefulWidget {
  final VoucherPackageEntity package;
  final int initialQuantity;
  final double discountPercent;
  final ValueChanged<int> onConfirm;

  const PackageQuantityInputSheet({
    super.key,
    required this.package,
    required this.initialQuantity,
    this.discountPercent = 0.0,
    required this.onConfirm,
  });

  /// دالة استدعاء ثابتة ومريحة لعرض النافذة
  static Future<void> show({
    required BuildContext context,
    required VoucherPackageEntity package,
    required int initialQuantity,
    double discountPercent = 0.0,
    required ValueChanged<int> onConfirm,
  }) {
    return CustomBottomSheet.show(
      title: 'تحديد كمية الكروت',
      subtitle: package.packageName,
      leadingIcon: Icon(
        Icons.layers_rounded,
        color: context.colors.primary,
        size: 22.r,
      ),
      child: PackageQuantityInputSheet(
        package: package,
        initialQuantity: initialQuantity,
        discountPercent: discountPercent,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<PackageQuantityInputSheet> createState() =>
      _PackageQuantityInputSheetState();
}

class _PackageQuantityInputSheetState extends State<PackageQuantityInputSheet> {
  late final TextEditingController _sheetsController;
  late final TextEditingController _cardsController;
  late int _currentCards;
  bool _isUpdatingFromSheets = false;
  bool _isUpdatingFromCards = false;

  @override
  void initState() {
    super.initState();
    _currentCards = widget.initialQuantity;

    final sheetSize = widget.package.packageVoucherCount;
    final initialSheets = _currentCards > 0 && sheetSize > 0
        ? (_currentCards / sheetSize)
        : 0.0;

    _sheetsController = TextEditingController(
      text: initialSheets > 0
          ? (initialSheets % 1 == 0
                ? initialSheets.toInt().toString()
                : initialSheets.toStringAsFixed(1))
          : '',
    );

    _cardsController = TextEditingController(
      text: _currentCards > 0 ? _currentCards.toString() : '',
    );
  }

  @override
  void dispose() {
    _sheetsController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  void _onSheetsChanged(String val) {
    if (_isUpdatingFromCards) return;
    _isUpdatingFromSheets = true;

    final cleaned = val.trim();
    if (cleaned.isEmpty) {
      setState(() => _currentCards = 0);
      _cardsController.text = '';
      _isUpdatingFromSheets = false;
      return;
    }

    final parsedSheets = double.tryParse(cleaned);
    if (parsedSheets != null && parsedSheets >= 0) {
      final calculatedCards = widget.package.vouchersForSheets(parsedSheets);
      setState(() => _currentCards = calculatedCards);
      _cardsController.text = calculatedCards > 0
          ? calculatedCards.toString()
          : '';
    }

    _isUpdatingFromSheets = false;
  }

  void _onCardsChanged(String val) {
    if (_isUpdatingFromSheets) return;
    _isUpdatingFromCards = true;

    final cleaned = val.trim();
    if (cleaned.isEmpty) {
      setState(() => _currentCards = 0);
      _sheetsController.text = '';
      _isUpdatingFromCards = false;
      return;
    }

    final parsedCards = int.tryParse(cleaned);
    if (parsedCards != null && parsedCards >= 0) {
      setState(() => _currentCards = parsedCards);
      final sheetSize = widget.package.packageVoucherCount;
      if (sheetSize > 0) {
        final b = VoucherSheetCalculator.breakdown(parsedCards, sheetSize);
        if (b.isExactSheetOrHalf) {
          final frac = b.fullSheets + (b.hasHalfSheet ? 0.5 : 0.0);
          _sheetsController.text = frac % 1 == 0
              ? frac.toInt().toString()
              : frac.toStringAsFixed(1);
        } else {
          final approx = parsedCards / sheetSize;
          _sheetsController.text = approx.toStringAsFixed(2);
        }
      }
    }

    _isUpdatingFromCards = false;
  }

  void _applyPreset(VoucherSheetPreset preset) {
    setState(() => _currentCards = preset.cards);
    _sheetsController.text = preset.sheets % 1 == 0
        ? preset.sheets.toInt().toString()
        : preset.sheets.toStringAsFixed(1);
    _cardsController.text = preset.cards.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sheetSize = widget.package.packageVoucherCount;
    final halfSheet = widget.package.halfSheetVoucherCount;
    final unitPrice = widget.package.packageVoucherPrice;
    final discountPercent = widget.discountPercent;
    final unitNet = unitPrice - (unitPrice * (discountPercent / 100));
    final totalNet = unitNet * _currentCards;
    final presets = widget.package.sheetPresets;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. بطاقة معيار الورقة المعتمد
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.06),
            borderRadius: AppRadius.smRadius,
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.2),
              width: 0.8.w,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: colors.primary,
                size: 17.r,
              ),
              AppSpacing.hXs,
              Expanded(
                child: Text(
                  'معيار الباقة: الورقة الكاملة = $sheetSize كرت • نصف الورقة = $halfSheet كرت',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5.sp,
                  ),
                ),
              ),
            ],
          ),
        ),

        AppSpacing.vSm,

        // 2. كبسولات الاختيار السريع للورقة
        Text(
          'أحجام الأوراق السريعة:',
          style: AppTypography.labelSmall.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        AppSpacing.vXxs,
        Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
          children: presets.map((p) {
            final isCurrent = _currentCards == p.cards;
            return CustomInteractiveBounce(
              onTap: () => _applyPreset(p),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? colors.primary
                      : colors.surfaceContainerHighest,
                  borderRadius: AppRadius.fullRadius,
                  border: Border.all(
                    color: isCurrent
                        ? colors.primary
                        : colors.outlineVariant.withValues(alpha: 0.3),
                    width: isCurrent ? 1.2.w : 0.8.w,
                  ),
                ),
                child: Text(
                  p.label,
                  style: AppTypography.labelSmall.copyWith(
                    color: isCurrent ? colors.onPrimary : colors.onSurface,
                    fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 10.5.sp,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        AppSpacing.vMd,

        // 3. حقلا الإدخال المزدوجان (أوراق <-> كروت)
        Row(
          children: [
            // حقل عدد الأوراق
            Expanded(
              child: CustomTextField(
                controller: _sheetsController,
                label: 'عدد الأوراق',
                hint: 'مثال: 1.5',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: _onSheetsChanged,
                prefixIcon: Icon(
                  Icons.receipt_long_rounded,
                  size: 18.r,
                  color: colors.primary,
                ),
              ),
            ),
            AppSpacing.hSm,
            // حقل إجمالي الكروت
            Expanded(
              child: CustomTextField(
                controller: _cardsController,
                label: 'إجمالي الكروت',
                hint: 'مثال: 77',
                keyboardType: TextInputType.number,
                onChanged: _onCardsChanged,
                prefixIcon: Icon(
                  Icons.style_outlined,
                  size: 18.r,
                  color: colors.secondary,
                ),
              ),
            ),
          ],
        ),

        AppSpacing.vSm,

        // 4. الرصيف المالي اللحظي للتأكيد
        if (_currentCards > 0) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: AppRadius.smRadius,
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.25),
                width: 0.8.w,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الكمية: $_currentCards كرت',
                      style: AppTypography.titleSmall.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5.sp,
                      ),
                    ),
                    AppSpacing.vXxs,
                    Text(
                      widget.package.describeSheetQuantity(_currentCards),
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${AmountFormatter.formatValue(totalNet)} ر.ي',
                      style: AppTypography.titleSmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 14.sp,
                      ),
                    ),
                    if (discountPercent > 0)
                      Text(
                        'خصم ${discountPercent.toInt()}%',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 9.5.sp,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.vMd,
        ],

        // 5. أزرار التحكم والإجراء
        Row(
          children: [
            Expanded(
              child: CustomButton.outline(
                text: 'إلغاء',
                onPressed: () => Get.back(),
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              flex: 2,
              child: CustomButton.primary(
                text: _currentCards > 0
                    ? 'تأكيد ($_currentCards كرت)'
                    : 'حذف الكمية',
                onPressed: () {
                  Get.back();
                  widget.onConfirm(_currentCards);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
