import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_controller.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_seetings_tile.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_settings_group.dart';
import 'package:netsales/widgets/inputs/custom_switch.dart';

/// بطاقة تفضيلات المظهر — مبنية على [ProfileSettingsGroup] و [ProfileSettingsTile].
class ProfileAppearanceCard extends GetView<ProfileController> {
  const ProfileAppearanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = controller.isDarkMode;

    return ProfileSettingsGroup(
      title: 'تفضيلات المظهر',
      children: [
        ProfileSettingsTile(
          icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          title: 'الوضع الداكن',
          subtitle: 'تبديل بين المظهر الفاتح والداكن',
          color: colors.primary,
          trailing: CustomSwitch(
            value: isDark,
            activeIcon: Icons.dark_mode_rounded,
            inactiveIcon: Icons.light_mode_rounded,
            onChanged: (_) => controller.toggleTheme(),
          ),
          onTap: controller.toggleTheme,
        ),
      ],
    );
  }
}
