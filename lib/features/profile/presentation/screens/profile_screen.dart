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
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';

/// Account & Identity Centre — composition only.
class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({
    super.key,
    this.embedded = false,
  });

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = CustomRefreshablePage.slivers(
      embedded: embedded,
      maxContentWidth: 1180,
      onRefresh: controller.loadProfile,
      scrollKey: const PageStorageKey<String>('profile-account-centre-scroll'),
      slivers: [
        Obx(() {
          final profile = controller.profile.value;

          if (controller.isLoading.value && profile == null) {
            return const SliverToBoxAdapter(
              child: CustomStateView.loading(
                presentation: CustomStatePresentation.skeletonOnly,
                skeleton: CustomStateSkeleton(
                  layout: CustomStateSkeletonLayout.cards,
                  itemCount: 3,
                  cardHeight: 132,
                  hasLeading: true,
                ),
              ),
            );
          }

          if (controller.errorMessage.value != null && profile == null) {
            return SliverToBoxAdapter(
              child: CustomErrorState(
                title: 'تعذر تحميل مركز الحساب',
                subtitle: controller.errorMessage.value,
                onRetry: controller.loadProfile,
              ),
            );
          }

          if (profile == null) {
            return SliverToBoxAdapter(
              child: CustomErrorState(
                title: 'بيانات الحساب غير متاحة',
                subtitle: 'لم تصل بيانات صالحة من الخادم.',
                onRetry: controller.loadProfile,
              ),
            );
          }

          return SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                );
              },
            ),
          );
        }),
      ],
    );

    if (embedded) return content;

    return CustomAppScaffold(
      appBarTitle: 'مركز الحساب',
      appBarSubtitle: 'هويتك الرقمية وإدارة الوصول والحماية',
      body: content,
    );
  }
}
