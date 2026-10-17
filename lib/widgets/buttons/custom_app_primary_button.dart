import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/widgets/buttons/custom_app_button.dart';

class CustomAppPrimaryButton extends StatelessWidget {
  const CustomAppPrimaryButton({
    super.key,

    required this.text,

    required this.onPressed,

    this.icon,

    this.loading = false,

    this.size = AppButtonSize.medium,

    this.enabled = true,
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

      gradient: LinearGradient(
        begin: Alignment.topRight,

        end: Alignment.bottomLeft,

        colors: [colors.primary, colors.secondary],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, color: colors.onPrimary),

          if (icon != null) AppSpacing.hSm,

          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
