import 'package:flutter/material.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
export 'package:netsales/widgets/buttons/custom_button.dart';

/// مهايئ توافقي (Adapter) يوجّه الاستدعاء مباشرة إلى الكلاس الموحد CustomButton.icon
class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 55,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomButton.icon(
      icon: icon,
      onPressed: onPressed,
      tooltip: tooltip,
      dimension: size,
    );
  }
}
