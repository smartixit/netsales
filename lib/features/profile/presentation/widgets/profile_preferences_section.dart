import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/inputs/custom_switch_list_tile.dart';

/// قسم تفضيلات المظهر في مركز الحساب (الوضع الليلي)
class ProfilePreferencesSection extends StatelessWidget {
  const ProfilePreferencesSection({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomSurfaceCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      backgroundColor: colors.surfaceContainerLow,
      borderColor: colors.outlineVariant.withValues(alpha: 0.4),
      onTap: onToggleTheme,
      child: CustomSwitchListTile(
        title: 'الوضع الليلي',
        subtitle: isDarkMode ? 'الوضع الداكن مفعّل' : 'الوضع الفاتح مفعّل',
        value: isDarkMode,
        icon: isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_outlined,
        onChanged: (_) => onToggleTheme(),
      ),
    );
  }
}
