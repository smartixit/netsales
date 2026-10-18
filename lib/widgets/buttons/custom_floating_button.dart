import 'package:flutter/material.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
export 'package:netsales/widgets/buttons/custom_button.dart';

/// مهايئ توافقي (Adapter) يوجّه الاستدعاء مباشرة إلى الكلاس الموحد CustomButton.floating
class CustomFloatingButton extends StatelessWidget {
  const CustomFloatingButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_rounded,
  });

  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return CustomButton.floating(
      icon: icon,
      onPressed: onPressed,
    );
  }
}
