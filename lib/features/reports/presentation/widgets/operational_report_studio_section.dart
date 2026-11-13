import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';

/// Shared visual container for the feature-specific report configuration areas.
class OperationalReportStudioSection extends StatelessWidget {
  const OperationalReportStudioSection({
    required this.title,
    required this.icon,
    required this.children,
    super.key,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CustomSurfaceCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              AppSpacing.hSm,
              Expanded(
                child: Text(title, style: AppTypography.titleMedium),
              ),
            ],
          ),
          AppSpacing.vSm,
          ...children.map(
            (child) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Consistent validation feedback used by report criteria and output settings.
class OperationalReportValidationNotice extends StatelessWidget {
  const OperationalReportValidationNotice({
    required this.title,
    required this.messages,
    super.key,
  });

  final String title;
  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CustomSurfaceCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: colors.errorContainer.withValues(alpha: 0.45),
      borderColor: colors.error.withValues(alpha: 0.35),
      radius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          for (final message in messages)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                '• $message',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onErrorContainer,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
