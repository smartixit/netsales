import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/widgets/buttons/custom_app_button.dart';

class CustomAppSecondaryButton extends StatelessWidget {
  const CustomAppSecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.enabled = true,
    this.size = AppButtonSize.medium,
  });

  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool loading;
  final bool enabled;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return CustomAppButton(
      size: size,

      loading: loading,

      enabled: enabled,

      onPressed: onPressed,

      backgroundColor: colors.secondaryContainer,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, color: colors.onSecondaryContainer),

          if (icon != null) AppSpacing.hSm,

          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.onSecondaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
