import 'package:flutter/material.dart';

import '../models/dashboard_user_profile.dart';
import '../theme/dashboard_layout_theme.dart';

class DashboardTopbar extends StatelessWidget {
  const DashboardTopbar({
    required this.height,
    this.leading,
    this.search,
    this.notifications,
    this.actions,
    this.profile,
    this.onProfileTap,
    super.key,
  });

  final double height;
  final Widget? leading;
  final Widget? search;
  final Widget? notifications;
  final List<Widget>? actions;
  final DashboardUserProfile? profile;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final layoutTheme = DashboardLayoutTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: height,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: layoutTheme.topbarBackground,
        border: Border(bottom: BorderSide(color: layoutTheme.border)),
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          if (search != null) Expanded(child: search!) else const Spacer(),
          ...[notifications].whereType<Widget>(),
          ...?actions,
          if (profile != null) ...[
            const SizedBox(width: 12),
            InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: scheme.primaryContainer,
                      backgroundImage: profile!.avatarUrl == null
                          ? null
                          : NetworkImage(profile!.avatarUrl!),
                      child: profile!.avatarUrl != null
                          ? null
                          : Text(
                              profile!.initials ??
                                  (profile!.name.isEmpty ? '?' : profile!.name.substring(0, 1)),
                              style: TextStyle(color: scheme.onPrimaryContainer),
                            ),
                    ),
                    const SizedBox(width: 9),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile!.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                          if (profile!.subtitle != null)
                            Text(
                              profile!.subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
