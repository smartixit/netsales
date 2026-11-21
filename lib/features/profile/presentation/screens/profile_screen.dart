import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_controller.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_details_section.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_identity_card.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_memberships_section.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_security_section.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = Obx(() {
      final profile = controller.profile.value;

      if (controller.isLoading.value && profile == null) {
        return const CustomStateView.loading(
          presentation: CustomStatePresentation.skeletonOnly,
          skeleton: CustomStateSkeleton(
            layout: CustomStateSkeletonLayout.cards,
            itemCount: 2,
            cardHeight: 150,
            maxColumns: 1,
          ),
        );
      }

      if (controller.errorMessage.value != null && profile == null) {
        return CustomErrorState.boxed(
          title: 'تعذر تحميل البروفايل',
          subtitle: controller.errorMessage.value,
          onRetry: controller.loadProfile,
        );
      }

      if (profile == null) {
        return CustomErrorState.boxed(
          title: 'بيانات الحساب غير متاحة',
          subtitle: 'لم تصل استجابة صالحة من خدمة البروفايل.',
          onRetry: controller.loadProfile,
        );
      }

      return RefreshIndicator.adaptive(
        onRefresh: controller.loadProfile,
        child: ListView(
          key: const PageStorageKey<String>('profile-screen-scroll'),
          padding: EdgeInsets.all(AppSpacing.cardPadding),
          children: [
            ProfileIdentityCard(profile: profile),
            AppSpacing.vLg,
            ProfileDetailsSection(
              title: 'بيانات الحساب',
              items: [
                MapEntry('الهاتف', profile.phoneNumber),
                if (profile.email?.trim().isNotEmpty == true)
                  MapEntry('البريد الإلكتروني', profile.email!),
                MapEntry(
                  'حالة الحساب',
                  profile.statusLabel ?? 'حالة غير معروفة',
                ),
                if (profile.lastLoginAt?.trim().isNotEmpty == true)
                  MapEntry('آخر تسجيل دخول', profile.lastLoginAt!),
              ],
            ),
            AppSpacing.vLg,
            ProfileMembershipsSection(memberships: profile.memberships),
            AppSpacing.vLg,
            ProfileSecuritySection(
              profile: profile,
              onOpenSecuritySettings: controller.openSecuritySettings,
              onOpenActiveSessions: controller.openActiveSessions,
            ),
            AppSpacing.vXl,
          ],
        ),
      );
    });

    if (embedded) {
      return content;
    }

    return CustomAppScaffold(
      appBarTitle: 'البروفايل',
      appBarSubtitle: 'بيانات الحساب والعضويات والأمان',
      body: content,
    );
  }
}
