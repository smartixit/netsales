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
/// متحكم نافذة إدخال كميات الكروت (PackageQuantityInputController)
/// ============================================================================
class PackageQuantityInputController extends GetxController {
  final VoucherPackageEntity package;
  final int initialQuantity;

  PackageQuantityInputController({
    required this.package,
    required this.initialQuantity,
  });

  late final TextEditingController sheetsController;
  late final TextEditingController cardsController;
  final RxInt currentCards = 0.obs;

  bool _isUpdatingFromSheets = false;
  bool _isUpdatingFromCards = false;

  @override
  void onInit() {
    super.onInit();
    currentCards.value = initialQuantity;

    final sheetSize = package.packageVoucherCount;
    final initialSheets = currentCards.value > 0 && sheetSize > 0
        ? (currentCards.value / sheetSize)
        : 0.0;

    sheetsController = TextEditingController(
      text: initialSheets > 0
          ? (initialSheets % 1 == 0
                ? initialSheets.toInt().toString()
                : initialSheets.toStringAsFixed(1))
          : '',
    );

    cardsController = TextEditingController(
      text: currentCards.value > 0 ? currentCards.value.toString() : '',
    );
  }

  @override
  void onClose() {
    sheetsController.dispose();
    cardsController.dispose();
    super.onClose();
  }

  void onSheetsChanged(String val) {
    if (_isUpdatingFromCards) return;
    _isUpdatingFromSheets = true;

    final cleaned = val.trim();
    if (cleaned.isEmpty) {
      currentCards.value = 0;
      cardsController.text = '';
      _isUpdatingFromSheets = false;
      return;
    }

    final parsedSheets = double.tryParse(cleaned);
    if (parsedSheets != null && parsedSheets >= 0) {
      final calculatedCards = package.vouchersForSheets(parsedSheets);
      currentCards.value = calculatedCards;
      cardsController.text = calculatedCards > 0
          ? calculatedCards.toString()
          : '';
    }

    _isUpdatingFromSheets = false;
  }

  void onCardsChanged(String val) {
    if (_isUpdatingFromSheets) return;
    _isUpdatingFromCards = true;

    final cleaned = val.trim();
    if (cleaned.isEmpty) {
      currentCards.value = 0;
      sheetsController.text = '';
      _isUpdatingFromCards = false;
      return;
    }

    final parsedCards = int.tryParse(cleaned);
    if (parsedCards != null && parsedCards >= 0) {
      currentCards.value = parsedCards;
      final sheetSize = package.packageVoucherCount;
      if (sheetSize > 0) {
        final b = VoucherSheetCalculator.breakdown(parsedCards, sheetSize);
        if (b.isExactSheetOrHalf) {
          final frac = b.fullSheets + (b.hasHalfSheet ? 0.5 : 0.0);
          sheetsController.text = frac % 1 == 0
              ? frac.toInt().toString()
              : frac.toStringAsFixed(1);
        } else {
          final approx = parsedCards / sheetSize;
          sheetsController.text = approx.toStringAsFixed(2);
        }
      }
    }

    _isUpdatingFromCards = false;
  }

  void applyPreset(VoucherSheetPreset preset) {
    currentCards.value = preset.cards;
    sheetsController.text = preset.sheets % 1 == 0
        ? preset.sheets.toInt().toString()
        : preset.sheets.toStringAsFixed(1);
    cardsController.text = preset.cards.toString();
  }
}

/// ============================================================================
/// نافذة تحديد كمية باقة الكروت بالأوراق والكروت (PackageQuantityInputSheet)
/// ============================================================================
/// تتيح إدخال الكمية المزدوج بدقة (إما بعدد الأوراق أو بعدد الكروت الفعلي)
/// مع تحويل فوري متزامن وتطبيق مباشر لقاعدة قص الورقة الفردية (51 -> 26).
class PackageQuantityInputSheet extends StatelessWidget {
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
      leadingIcon: Icons.layers_rounded,
      child: PackageQuantityInputSheet(
        package: package,
        initialQuantity: initialQuantity,
        discountPercent: discountPercent,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sheetSize = package.packageVoucherCount;
    final halfSheet = package.halfSheetVoucherCount;
    final unitPrice = package.packageVoucherPrice;
    final unitNet = unitPrice - (unitPrice * (discountPercent / 100));
    final presets = package.sheetPresets;

    return GetBuilder<PackageQuantityInputController>(
      init: PackageQuantityInputController(
        package: package,
        initialQuantity: initialQuantity,
      ),
      builder: (controller) {
        return Obx(() {
          final currentCards = controller.currentCards.value;
          final totalNet = unitNet * currentCards;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. بطاقة معلومات مقاس الورقة القياسي
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.06),
                  borderRadius: AppRadius.mdRadius,
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.2),
                    width: 1.w,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: colors.primary,
                      size: 20.r,
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المقاس الطباعي: $sheetSize كرت / ورقة',
                            style: AppTypography.labelMedium.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          AppSpacing.vXxs,
                          Text(
                            'يدعم إدخال الأوراق الكاملة، ونصف الورقة ($halfSheet كرت) بدقة تلقائية.',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: 10.5.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.vMd,

              // 2. حقول الإدخال المتزامنة (أوراق كروت)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // حقل عدد الأوراق
                  Expanded(
                    child: CustomTextField(
                      label: 'عدد الأوراق',
                      hint: '0 أو 0.5',
                      controller: controller.sheetsController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixIcon: Icon(
                        Icons.description_outlined,
                        color: colors.primary,
                        size: 20.r,
                      ),
                      onChanged: controller.onSheetsChanged,
                    ),
                  ),

                  AppSpacing.hSm,

                  // أيقونة المزامنة والتحويل اللحظي
                  Padding(
                    padding: EdgeInsets.only(top: 28.h),
                    child: Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.sync_alt_rounded,
                        color: colors.onSurfaceVariant,
                        size: 16.r,
                      ),
                    ),
                  ),

                  AppSpacing.hSm,

                  // حقل إجمالي عدد الكروت
                  Expanded(
                    child: CustomTextField(
                      label: 'إجمالي الكروت',
                      hint: '0',
                      controller: controller.cardsController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icon(
                        Icons.credit_card_rounded,
                        color: colors.primary,
                        size: 20.r,
                      ),
                      onChanged: controller.onCardsChanged,
                    ),
                  ),
                ],
              ),

              AppSpacing.vMd,

              // 3. كبسولات الاختيار السريع للكميات المطبوعة الشائعة
              Text(
                'كميات سريعة بالأوراق الشائعة:',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppSpacing.vXs,

              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: presets.map((preset) {
                  final isSelected = currentCards == preset.cards;
                  return CustomInteractiveBounce(
                    onTap: () => controller.applyPreset(preset),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary
                            : colors.surfaceContainerLow,
                        borderRadius: AppRadius.fullRadius,
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.outlineVariant.withValues(alpha: 0.5),
                          width: 1.w,
                        ),
                      ),
                      child: Text(
                        '${preset.label} (${preset.cards} كرت)',
                        style: AppTypography.labelSmall.copyWith(
                          color: isSelected
                              ? colors.onPrimary
                              : colors.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              AppSpacing.vSm,

              // 4. الرصيف المالي اللحظي للتأكيد
              if (currentCards > 0) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.35,
                    ),
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
                            'الكمية: $currentCards كرت',
                            style: AppTypography.titleSmall.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5.sp,
                            ),
                          ),
                          AppSpacing.vXxs,
                          Text(
                            package.describeSheetQuantity(currentCards),
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
                      text: currentCards > 0
                          ? 'تأكيد ($currentCards كرت)'
                          : 'حذف الكمية',
                      onPressed: () {
                        Get.back();
                        onConfirm(currentCards);
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        });
      },
    );
  }
}
