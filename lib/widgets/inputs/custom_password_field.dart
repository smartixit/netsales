import 'package:flutter/material.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// ============================================================================
/// حقل إدخال كلمة المرور المؤسسي الموحد (CustomPasswordField)
/// ============================================================================
/// مكوّن قياسي مركزي في طبقة `lib/widgets/inputs/` يمنع تكرار الكود:
/// 1. إخفاء كلمة المرور وتفعيل زر التبديل المدمج تلقائياً (obscureText + enablePasswordToggle).
/// 2. توحيد أيقونة القفل الهندسية والتلميح (••••••••).
/// 3. تعيين نوع لوحة المفاتيح والتحقق التلقائي (passwordValidator / confirmPasswordValidator).
/// 4. التكامل مع مديري كلمات المرور بالأنظمة (AutofillHints.password / newPassword).
class CustomPasswordField extends StatelessWidget {
  const CustomPasswordField({
    super.key,
    required this.controller,
    this.label = 'كلمة المرور',
    this.hint = '••••••••',
    this.textInputAction = TextInputAction.done,
    this.validator,
    this.prefixIcon,
    this.onFieldSubmitted,
    this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.focusNode,
    this.autofillHints = const [AutofillHints.password],
  });

  /// فئة مصنعية لكلمة المرور الجديدة (New Password)
  const CustomPasswordField.newPassword({
    super.key,
    required this.controller,
    this.label = 'كلمة المرور الجديدة',
    this.hint = '••••••••',
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.prefixIcon,
    this.onFieldSubmitted,
    this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.focusNode,
    this.autofillHints = const [AutofillHints.newPassword],
  });

  /// فئة مصنعية لتأكيد كلمة المرور الجديدة (Confirm Password)
  const CustomPasswordField.confirm({
    super.key,
    required this.controller,
    this.label = 'تأكيد كلمة المرور الجديدة',
    this.hint = '••••••••',
    this.textInputAction = TextInputAction.done,
    this.validator,
    this.prefixIcon,
    this.onFieldSubmitted,
    this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.focusNode,
    this.autofillHints = const [AutofillHints.password],
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hint: hint,
      obscureText: true,
      enablePasswordToggle: true,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: textInputAction,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      focusNode: focusNode,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      autofillHints: autofillHints,
      prefixIcon: prefixIcon ?? Icon(Icons.lock_outline_rounded),
      validator:
          validator ?? FormValidators.passwordValidator(fieldName: label),
    );
  }
}
