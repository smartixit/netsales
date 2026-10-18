import 'package:flutter/material.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
export 'package:netsales/widgets/buttons/custom_button.dart';

/// مهايئ توافقي (Adapter) يوجّه الاستدعاء مباشرة إلى الكلاس الموحد CustomButton.primary
class CustomPrimaryButton extends StatelessWidget {
  const CustomPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.size = AppButtonSize.medium,
    this.enabled = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool enabled;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    return CustomButton.primary(
      text: text,
      onPressed: onPressed,
      icon: icon,
      loading: loading,
      size: size,
      enabled: enabled,
    );
  }
}
