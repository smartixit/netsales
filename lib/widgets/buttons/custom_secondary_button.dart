import 'package:flutter/material.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
export 'package:netsales/widgets/buttons/custom_button.dart';

/// مهايئ توافقي (Adapter) يوجّه الاستدعاء مباشرة إلى الكلاس الموحد CustomButton.secondary
class CustomSecondaryButton extends StatelessWidget {
  const CustomSecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.enabled = true,
    this.size = AppButtonSize.medium,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool enabled;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    return CustomButton.secondary(
      text: text,
      onPressed: onPressed,
      icon: icon,
      loading: loading,
      enabled: enabled,
      size: size,
    );
  }
}
