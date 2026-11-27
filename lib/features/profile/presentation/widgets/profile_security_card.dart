import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_controller.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_seetings_tile.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_settings_group.dart';
import 'package:netsales/widgets/inputs/custom_switch.dart';

/// بطاقة الأمان والحماية — مبنية على [ProfileSettingsGroup] و [ProfileSettingsTile].
class ProfileSecurityCard extends GetView<ProfileController> {
  const ProfileSecurityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ProfileSettingsGroup(
      title: 'الأمان والحماية',
      children: [
        ProfileSettingsTile(
          icon: Icons.lock_outline_rounded,
          title: 'تغيير كلمة المرور',
          subtitle: 'اضبط كلمة مرور جديدة لحسابك',
          color: colors.primary,
          onTap: controller.openChangePasswordSheet,
        ),
        Obx(() {
          final enabled = controller.isTwoFactorEnabled.value;
          return ProfileSettingsTile(
            icon: Icons.verified_user_outlined,
            title: 'التحقق بخطوتين',
            subtitle: enabled
                ? 'مفعّل — حسابك محمي بطبقة إضافية'
                : 'غير مفعّل — ننصح بتفعيله لحماية أفضل',
            color: enabled ? colors.primary : colors.onSurfaceVariant,
            trailing: CustomSwitch(
              value: enabled,
              activeIcon: Icons.shield_rounded,
              inactiveIcon: Icons.shield_outlined,
              onChanged: controller.onTwoFactorSwitchRequested,
            ),
            onTap: () => controller.onTwoFactorSwitchRequested(!enabled),
          );
        }),
        ProfileSettingsTile(
          icon: Icons.devices_outlined,
          title: 'الأجهزة المقترنة',
          subtitle: 'مراجعة الأجهزة المعتمدة وفصلها',
          color: colors.secondary,
          onTap: controller.openUserDevices,
        ),
        ProfileSettingsTile(
          icon: Icons.sensors_rounded,
          title: 'جلسات تسجيل الدخول',
          subtitle: 'متابعة الجلسات النشطة والسابقة والتحكم بها',
          color: colors.tertiary,
          onTap: controller.openUserSessions,
        ),
      ],
    );
  }
}
