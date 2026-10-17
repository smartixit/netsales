import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/widgets/buttons/custom_app_button.dart';

class CustomAppDangerButton extends StatelessWidget {
  const CustomAppDangerButton({
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

      backgroundColor: colors.error,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          if (icon != null) ...[
            Icon(icon, color: colors.onError),

            AppSpacing.hSm,
          ],

          Text(
            text,

            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colors.onError,

              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
