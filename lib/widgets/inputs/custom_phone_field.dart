import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// ============================================================================
/// حقل إدخال رقم الهاتف المؤسسي الموحد (CustomPhoneField)
/// ============================================================================
/// مكوّن قياسي موحد في طبقة `lib/widgets/inputs/` يمنع تكرار الكود:
/// 1. بادئة الدولة المدمجة الثابتة (+967 🇾🇪) مع فاصل عمودي دقيق.
/// 2. قصر الإدخال على 9 أرقام ومنع الرموز والمسافات (digitsOnly, max 9).
/// 3. التحقق المعياري عبر FormValidators.phoneValidator.
/// 4. التكامل مع إدارة الملء التلقائي بالنظام (AutofillHints.telephoneNumber).
/// 5. دعم زر اختياري في النهاية (مثل منتقي جهات الاتصال).
class CustomPhoneField extends StatelessWidget {
  const CustomPhoneField({
    super.key,
    required this.controller,
    this.label = 'رقم الهاتف',
    this.hint = '77XXXXXXX',
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onFieldSubmitted,
    this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.suffixIcon,
    this.focusNode,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final Widget? suffixIcon;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomTextField(
      controller: controller,
      label: label,
      hint: hint,
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      focusNode: focusNode,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      autofillHints: const [AutofillHints.telephoneNumber],
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9),
      ],
      prefixIcon: Padding(
        padding: EdgeInsetsDirectional.only(
          start: AppSpacing.sm,
          end: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🇾🇪',
              style: AppTypography.titleMedium,
            ),
            AppSpacing.hXxs,
            Text(
              '+967',
              style: AppTypography.labelLarge.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.hXs,
            Container(
              width: 1.w,
              height: 20.h,
              color: colors.outlineVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
      suffixIcon: suffixIcon ??
          Icon(
            Icons.phone_iphone_rounded,
            color: colors.onSurfaceVariant.withValues(alpha: 0.5),
            size: 20.r,
          ),
      validator: validator ??
          FormValidators.phoneValidator(
            fieldName: label,
          ),
    );
  }
}
