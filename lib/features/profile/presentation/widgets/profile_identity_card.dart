import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_controller.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_seetings_tile.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_settings_group.dart';

/// بطاقة هوية المستخدم — مبنية على [ProfileSettingsGroup] و [ProfileSettingsTile].
class ProfileIdentityCard extends GetView<ProfileController> {
  const ProfileIdentityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final profile = controller.profile.value;
      if (profile == null) return const SizedBox.shrink();

      return ProfileSettingsGroup(
        title: 'معلوماتك الشخصية',
        children: [
          ProfileSettingsTile(
            icon: Icons.edit_outlined,
            title: 'تعديل الملف الشخصي',
            subtitle: 'تحديث الاسم ورقم الهاتف والبريد الإلكتروني',
            color: colors.primary,
            onTap: controller.openEditProfile,
          ),
          ProfileSettingsTile(
            icon: Icons.badge_outlined,
            title: 'الاسم الكامل',
            subtitle: profile.fullName,
            color: colors.tertiary,
            trailing: const SizedBox.shrink(),
          ),
          ProfileSettingsTile(
            icon: Icons.phone_outlined,
            title: 'رقم الهاتف',
            subtitle: profile.phoneNumber,
            color: colors.secondary,
            trailing: Icon(
              Icons.copy_rounded,
              size: 18.sp,
              color: colors.onSurfaceVariant,
            ),
            onTap: () => controller.copyToClipboard(
              profile.phoneNumber,
              'تم نسخ رقم الهاتف',
            ),
          ),
          if (profile.hasEmail)
            ProfileSettingsTile(
              icon: Icons.email_outlined,
              title: 'البريد الإلكتروني',
              subtitle: profile.email!,
              color: colors.error,
              trailing: Icon(
                Icons.copy_rounded,
                size: 18.sp,
                color: colors.onSurfaceVariant,
              ),
              onTap: () => controller.copyToClipboard(
                profile.email!,
                'تم نسخ البريد الإلكتروني',
              ),
            ),
          if (profile.lastLoginAt != null)
            ProfileSettingsTile(
              icon: Icons.access_time_rounded,
              title: 'آخر تسجيل دخول',
              subtitle: profile.lastLoginAt!,
              color: colors.onSurfaceVariant,
              trailing: const SizedBox.shrink(),
            ),
        ],
      );
    });
  }
}
