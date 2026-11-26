import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// زر تسجيل الخروج — يستدعي [ProfileController.confirmAndLogout].
class ProfileLogoutTile extends GetView<ProfileController> {
  const ProfileLogoutTile({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomButton(
      text: 'تسجيل الخروج',
      variant: AppButtonVariant.outline,
      icon: Icons.logout_rounded,
      foregroundColor: colors.error,
      borderColor: colors.error.withValues(alpha: 0.4),
      width: double.infinity,
      onPressed: controller.confirmAndLogout,
    );
  }
}
