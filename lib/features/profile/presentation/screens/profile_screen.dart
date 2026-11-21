import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_controller.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_details_section.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_identity_card.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_memberships_section.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_security_section.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// Account & Identity Centre — composition only.
class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      appBarTitle: 'مركز الحساب',
      appBarSubtitle: 'هويتك الرقمية وإدارة الوصول والحماية',
      body: Obx(() {
        final profile = controller.profile.value;

        if (controller.isLoading.value && profile == null) {
          return const CustomStateView.loading(
            presentation: CustomStatePresentation.skeletonOnly,
            skeleton: CustomStateSkeleton(
              layout: CustomStateSkeletonLayout.cards,
              itemCount: 3,
              cardHeight: 132,
              hasLeading: true,
            ),
          );
        }

        if (controller.errorMessage.value != null && profile == null) {
          return CustomErrorState(
            title: 'تعذر تحميل مركز الحساب',
            subtitle: controller.errorMessage.value,
            onRetry: controller.loadProfile,
          );
        }

        if (profile == null) {
          return CustomErrorState(
            title: 'بيانات الحساب غير متاحة',
            subtitle: 'لم تصل بيانات صالحة من الخادم.',
            onRetry: controller.loadProfile,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadProfile,
          color: colors.primary,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final contentWidth =
                  constraints.maxWidth > 1180 ? 1180.0 : constraints.maxWidth;
              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: contentWidth,
                  child: ListView(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      112.h,
                    ),
                    children: [
                      ProfileIdentityCard(profile: profile),
                      AppSpacing.vLg,
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 11,
                              child: Column(
                                children: [
                                  ProfileDetailsSection(profile: profile),
                                  AppSpacing.vLg,
                                  ProfileSecuritySection(
                                    profile: profile,
                                    onOpenSecurity:
                                        controller.openSecuritySettings,
                                    onOpenSessions:
                                        controller.openActiveSessions,
                                  ),
                                ],
                              ),
                            ),
                            AppSpacing.hLg,
                            Expanded(
                              flex: 10,
                              child: ProfileMembershipsSection(
                                memberships: profile.memberships,
                                onOpenMembership: controller.openMembership,
                              ),
                            ),
                          ],
                        )
                      else ...[
                        ProfileDetailsSection(profile: profile),
                        AppSpacing.vLg,
                        ProfileMembershipsSection(
                          memberships: profile.memberships,
                          onOpenMembership: controller.openMembership,
                        ),
                        AppSpacing.vLg,
                        ProfileSecuritySection(
                          profile: profile,
                          onOpenSecurity: controller.openSecuritySettings,
                          onOpenSessions: controller.openActiveSessions,
                        ),
                      ],
                      if (controller.isLoading.value) ...[
                        AppSpacing.vSm,
                        const LinearProgressIndicator(minHeight: 2),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
