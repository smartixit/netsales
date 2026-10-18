import 'package:flutter/material.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
export 'package:netsales/widgets/buttons/custom_button.dart';

/// مهايئ توافقي (Adapter) يوجّه الاستدعاء مباشرة إلى الكلاس الموحد CustomButton.outline
class CustomOutlineButton extends StatelessWidget {
  const CustomOutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.enabled = true,
    this.width,
    this.height,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool enabled;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return CustomButton.outline(
      text: text,
      onPressed: onPressed,
      icon: icon,
      loading: loading,
      enabled: enabled,
      width: width,
      height: height,
    );
  }
}
