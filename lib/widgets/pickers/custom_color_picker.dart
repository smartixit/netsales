import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// منتقي الألوان المؤسسي الموحد (CustomColorPicker)
/// ============================================================================
/// ودجت عام وقابل لإعادة الاستخدام في كافة قطاعات النظام (باقات، شبكات، تصنيفات).
/// يدعم التحويل الآمن بين صيغ Hex و [Color] مع تفاعل لمسي ناعم، وشارات بصرية.
/// يحمي المستخدم من كتابة أي كود ألوان يدوي ويوفر له لوحة متناسقة بنقرة واحدة.
class CustomColorPicker extends StatelessWidget {
  /// اللون المحدد حالياً بصيغة Hex (مثل "0xFF0D7A5F" أو "#0D7A5F")
  final String selectedColorHex;

  /// حدث تغير اللون المختار
  final ValueChanged<String> onColorChanged;

  /// عنوان الحقل
  final String? label;

  /// قائمة الألوان المقترحة (اختيارية، توفر قائمة قياسية افتراضية)
  final List<String>? customPalette;

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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final palette = customPalette ?? defaultPalette;

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
            children: palette.map((hex) {
              final isSelected = _normalize(selectedColorHex) == _normalize(hex);
              final color = parseHex(hex);

              return Padding(
                padding: EdgeInsets.only(left: 10.w),
                child: _ColorSwatch(
                  color: color,
                  isSelected: isSelected,
                  onTap: () => onColorChanged(hex),
                ),
              );
            }).toList(),
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
