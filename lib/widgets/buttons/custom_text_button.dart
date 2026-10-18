import 'package:flutter/material.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
export 'package:netsales/widgets/buttons/custom_button.dart';

/// مهايئ توافقي (Adapter) يوجّه الاستدعاء مباشرة إلى الكلاس الموحد CustomButton.text
class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.style,
    this.icon,
    this.loading = false,
    this.enabled = true,
    this.padding,
  });

  final String text;
  final TextStyle? style;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool enabled;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return CustomButton.text(
      text: text,
      onPressed: onPressed,
      icon: icon,
      textStyle: style,
      loading: loading,
      enabled: enabled,
      padding: padding,
    );
  }
}
