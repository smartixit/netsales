import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// ============================================================================
/// منتقي الألوان المؤسسي الموحد (CustomColorPicker)
/// ============================================================================
/// ودجت عام وقابل لإعادة الاستخدام في كافة قطاعات النظام (باقات، شبكات، تصنيفات).
/// يجمع بين عينات الوصول السريع الأكثر استخداماً وعجلة الألوان المتقدمة [ColorPicker].
/// يوفر تجربة سلسة بدون أي كتابة يدوية لأكواد الألوان مع تحويل Hex فوري وآمن.
class CustomColorPicker extends StatelessWidget {
  /// اللون المحدد حالياً بصيغة Hex (مثل "0xFF0D7A5F" أو "#0D7A5F")
  final String selectedColorHex;

  /// حدث تغير اللون المختار
  final ValueChanged<String> onColorChanged;

  /// عنوان الحقل
  final String? label;

  /// قائمة الألوان المقترحة (اختيارية، توفر قائمة قياسية افتراضية)
  final List<String>? customPalette;

  /// إمكانية فتح عجلة الألوان والتخصيص المتقدم
  final bool enableCustomWheel;

  /// قائمة الألوان المؤسسية المتوافقة مع النظام البصري
  static const List<String> defaultPalette = [
    '0xFF0D7A5F', // الأخضر الزمردي الرسمي
    '0xFF1976D2', // الأزرق الكلاسيكي
    '0xFF7B1FA2', // البنفسجي الملكي
    '0xFFE65100', // الكهرماني البرتقالي
    '0xFFC2185B', // الوردي الياقوتي
    '0xFF00838F', // التيل المائي
    '0xFF283593', // النيلي العميق
    '0xFFD32F2F', // القرمزي الداكن
    '0xFFF57C00', // البرتقالي الدافئ
    '0xFF37474F', // الرمادي المعدني
  ];

  const CustomColorPicker({
    super.key,
    required this.selectedColorHex,
    required this.onColorChanged,
    this.label,
    this.customPalette,
    this.enableCustomWheel = true,
  });

  /// دالة مساعدة عامة لتحويل أي صيغة Hex إلى كائن [Color] بأمان تام
  static Color parseHex(
    String? hexString, {
    Color fallback = const Color(0xFF0D7A5F),
  }) {
    if (hexString == null || hexString.trim().isEmpty) return fallback;
    try {
      final clean = hexString
          .replaceAll('#', '')
          .replaceAll('0x', '')
          .replaceAll('0X', '')
          .trim();
      final hex = clean.length == 6 ? 'FF$clean' : clean;
      final val = int.tryParse(hex, radix: 16);
      if (val == null) return fallback;
      return Color(val);
    } catch (_) {
      return fallback;
    }
  }

  /// دالة مساعدة لتحويل كائن [Color] إلى نص Hex متوافق مع قاعدة البيانات
  static String toHex(Color color) {
    return '0x${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  /// فتح نافذة عجلة الألوان المتقدمة بصرياً ومؤسسياً
  static Future<String?> showColorPickerSheet({
    required BuildContext context,
    required String initialColorHex,
    String title = 'تخصيص اللون التعريفي',
  }) async {
    Color tempColor = parseHex(initialColorHex);

    final confirmedHex = await CustomBottomSheet.show<String>(
      title: title,
      subtitle: 'اختر درجة اللون المناسبة أو استخدم عجلة الألوان الدقيقة',
      leadingIcon: Icon(
        Icons.palette_rounded,
        color: context.colors.primary,
        size: 22.r,
      ),
      child: StatefulBuilder(
        builder: (context, setModalState) {
          final colors = context.colors;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // بطاقة معاينة اللون المختار
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: AppRadius.mdRadius,
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: tempColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: tempColor.withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اللون المختار حالياً',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          AppSpacing.vXxs,
                          Text(
                            toHex(tempColor),
                            style: AppTypography.titleSmall.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.vMd,

              // عجلة ومنتقي الألوان المؤسسي المعتمد
              ColorPicker(
                color: tempColor,
                onColorChanged: (Color newColor) {
                  setModalState(() {
                    tempColor = newColor;
                  });
                },
                width: 36.r,
                height: 36.r,
                borderRadius: 18.r,
                spacing: 8.w,
                runSpacing: 8.h,
                wheelDiameter: 175.r,
                wheelWidth: 16.r,
                enableShadesSelection: true,
                heading: Text(
                  'لوحة التدرجات القياسية:',
                  style: AppTypography.labelMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subheading: Text(
                  'ظلال اللون:',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                wheelSubheading: Text(
                  'عجلة الألوان الدقيقة:',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                showMaterialName: false,
                showColorName: false,
                showColorCode: false,
                pickersEnabled: const <ColorPickerType, bool>{
                  ColorPickerType.both: false,
                  ColorPickerType.primary: true,
                  ColorPickerType.accent: true,
                  ColorPickerType.bw: false,
                  ColorPickerType.custom: false,
                  ColorPickerType.wheel: true,
                },
              ),

              AppSpacing.vLg,

              // أزرار الحفظ والإلغاء
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
                    child: CustomButton.primary(
                      text: 'اعتماد اللون',
                      icon: Icons.check_rounded,
                      onPressed: () => Get.back(result: toHex(tempColor)),
                    ),
                  ),
                ],
              ),
              AppSpacing.vSm,
            ],
          );
        },
      ),
    );

    return confirmedHex;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final palette = customPalette ?? defaultPalette;
    final isCustomColor = !palette.any(
      (hex) => _normalize(hex) == _normalize(selectedColorHex),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vXs,
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              ...palette.map((hex) {
                final isSelected =
                    _normalize(selectedColorHex) == _normalize(hex);
                final color = parseHex(hex);

                return Padding(
                  padding: EdgeInsets.only(left: 10.w),
                  child: _ColorSwatch(
                    color: color,
                    isSelected: isSelected,
                    onTap: () => onColorChanged(hex),
                  ),
                );
              }),
              if (enableCustomWheel) ...[
                Padding(
                  padding: EdgeInsets.only(left: 10.w),
                  child: _CustomWheelButton(
                    currentColor: parseHex(selectedColorHex),
                    isCustomActive: isCustomColor,
                    onTap: () async {
                      final chosen = await showColorPickerSheet(
                        context: context,
                        initialColorHex: selectedColorHex,
                      );
                      if (chosen != null) {
                        onColorChanged(chosen);
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static String _normalize(String hex) {
    return hex
        .replaceAll('#', '')
        .replaceAll('0x', '')
        .replaceAll('0X', '')
        .toLowerCase()
        .trim();
  }
}

/// ودجت مستقل لعينة اللون الفردية (Color Swatch)
class _ColorSwatch extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2.5.w,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? const Center(
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              )
            : null,
      ),
    );
  }
}

/// زر عجلة الألوان المتخصص لفتح منتقي الألوان الموسع
class _CustomWheelButton extends StatelessWidget {
  final Color currentColor;
  final bool isCustomActive;
  final VoidCallback onTap;

  const _CustomWheelButton({
    required this.currentColor,
    required this.isCustomActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Tooltip(
        message: 'عجلة الألوان المخصصة',
        child: Container(
          width: 36.r,
          height: 36.r,
          decoration: BoxDecoration(
            color: isCustomActive ? currentColor : colors.surfaceContainerHigh,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCustomActive
                  ? colors.primary
                  : colors.outlineVariant.withValues(alpha: 0.8),
              width: isCustomActive ? 2.w : 1.w,
            ),
            boxShadow: isCustomActive
                ? [
                    BoxShadow(
                      color: currentColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Icon(
              Icons.palette_outlined,
              size: 18.r,
              color: isCustomActive ? Colors.white : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

