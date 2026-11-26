import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// حقل بحث موحّد مرن وخالٍ من الحالة الداخلية (CustomSearchField)
///
/// مصمم بأسلوب كبسولي نظيف ومريح للعين، وقابل لإعادة الاستخدام في أي مشروع:
/// - يراقب تغيرات النص تلقائياً عبر [ValueListenableBuilder] لإظهار زر المسح.
/// - يدعم التخصيص الكامل للألوان، الحواف، الحشو، والأيقونات.
class CustomSearchField extends StatelessWidget {
  const CustomSearchField({
    super.key,
    required this.controller,
    this.hintText = 'ابحث...',
    this.searchQuery,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.prefixIcon,
    this.fillColor,
    this.borderRadius,
    this.contentPadding,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction = TextInputAction.search,
  });

  final TextEditingController controller;
  final String hintText;
  final String? searchQuery;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final Widget? prefixIcon;
  final Color? fillColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final bool enabled;
  final bool autofocus;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveRadius = borderRadius ?? BorderRadius.circular(AppRadius.full);
    final effectiveFill =
        fillColor ?? colors.surfaceContainerHighest.withValues(alpha: 0.5);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText =
            value.text.trim().isNotEmpty ||
            (searchQuery?.trim().isNotEmpty ?? false);

        return TextField(
          controller: controller,
          enabled: enabled,
          autofocus: autofocus,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon ?? const Icon(Icons.search_rounded),
            suffixIcon: hasText
                ? CustomButton.icon(
                    icon: Icons.close_rounded,
                    tooltip: 'مسح البحث',
                    iconSize: 18.r,
                    dimension: 36.r,
                    backgroundColor: Colors.transparent,
                    foregroundColor: colors.onSurfaceVariant,
                    onPressed: () {
                      controller.clear();
                      onChanged?.call('');
                      onClear?.call();
                    },
                  )
                : null,
            filled: true,
            fillColor: effectiveFill,
            contentPadding:
                contentPadding ??
                EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
            border: OutlineInputBorder(
              borderRadius: effectiveRadius,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: effectiveRadius,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: effectiveRadius,
              borderSide: BorderSide(
                color: colors.primary.withValues(alpha: 0.45),
                width: 1.2,
              ),
            ),
          ),
        );
      },
    );
  }
}
