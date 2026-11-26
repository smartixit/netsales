
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_controller.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_seetings_tile.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_settings_group.dart';
import 'package:netsales/widgets/inputs/custom_switch.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

class ProfileBody extends GetView<ProfileController> {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = controller.profile.value;

    return Column(
      children: [
        ProfileSettingsGroup(
          title: 'معلوماتك الشخصية',
          children: [
            ProfileSettingsTile(
              icon: Icons.edit,
              title: 'تعديل الملف الشخصي',
              subtitle: 'تعديل بيانات الحساب الشخصي',
            ),
            ProfileSettingsTile(
              icon: Icons.password,
              title: 'تغيير كلمة المرور',
              subtitle: 'تغيير كلمة مرور الحساب',
              onTap: () {
                CustomBottomSheet.showActions<void>(
                  title: 'تغيير كلمة المرور',
                  items: [],
                );
              },
            ),
            Obx(
              () => ProfileSettingsTile(
                icon: Icons.lock_outline,
                title: profile!.twoFactorEnabled
                    ? 'تعطيل التحقق بخطوتين'
                    : 'تفعيل التحقق بخطوتين',
                subtitle: 'تأمين الحساب بخطوتين',
                trailing: CustomSwitch(
                  value: controller.isTwoFactorEnabled.value,
                  onChanged: (value) => controller.updateTwoFactor,
                ),
                onTap: controller.updateTwoFactor,
              ),
            ),
          ],
        ),

        AppSpacing.vLg,
      ],
    );
  }
}
