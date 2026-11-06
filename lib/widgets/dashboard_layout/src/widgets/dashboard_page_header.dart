import 'package:flutter/material.dart';

@immutable
class DashboardPageHeaderData {
  const DashboardPageHeaderData({
    required this.title,
    this.description,
    this.icon,
    this.actions = const [],
  });

  final String title;
  final String? description;
  final IconData? icon;
  final List<Widget> actions;
}

class DashboardPageHeader extends StatelessWidget {
  const DashboardPageHeader({required this.data, super.key});

  final DashboardPageHeaderData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (data.icon != null) ...[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.title, style: theme.textTheme.headlineSmall),
              if (data.description != null) ...[
                const SizedBox(height: 4),
                Text(data.description!, style: theme.textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        if (data.actions.isNotEmpty)
          Wrap(spacing: 8, runSpacing: 8, children: data.actions),
      ],
    );
  }
}
