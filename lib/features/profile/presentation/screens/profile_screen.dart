import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/profile/domain/entities/profile_entity.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_controller.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_active_context_banner.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_details_section.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_identity_card.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_logout_tile.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_preferences_section.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_security_section.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// مركز الحساب والسيادة الرقمية (Account & Identity Centre)
/// مكوّن عرض نقي خاضع بالكامل لعقد الخادم ومطابق للتصميم التنفيذي المعتمد
class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key, this.embedded = false});

  final bool embedded;

  void _openAccountDetailsSheet(BuildContext context, ProfileEntity profile) {
    CustomBottomSheet.show<void>(
      title: 'تفاصيل الحساب والهوية',
      subtitle: 'البيانات المسجلة رسمياً لدى المنصة',
      leadingIcon: Icons.badge_outlined,
      child: ProfileDetailsSection(profile: profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = CustomRefreshablePage.slivers(
      embedded: embedded,
      maxContentWidth: 680,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. شريط سياق بيئة العمل النشطة حالياً
                ProfileActiveContextBanner(
                  activeWorkspaceLabel: controller.activeWorkspaceLabel,
                ),
                SizedBox(height: AppSpacing.md),

                // 2. بطاقة الهوية التنفيذية الرئيسية
                ProfileIdentityCard(
                  profile: profile,
                  onCopyPhone: () => controller.copyToClipboard(
                    profile.phoneNumber,
                    'تم نسخ رقم الهاتف بنجاح',
                  ),
                  onCopyEmail: () => controller.copyToClipboard(
                    profile.email ?? '',
                    'تم نسخ البريد الإلكتروني بنجاح',
                  ),
                  onAvatarChanged: controller.onAvatarChanged,
                  onCompleteProfile: () =>
                      _openAccountDetailsSheet(context, profile),
                ),
                SizedBox(height: AppSpacing.lg),

                // 3. مركز الأمان والحماية (2FA، كلمة المرور، الجلسات والأجهزة)
                ProfileSecuritySection(
                  profile: profile,
                  onOpenSecurity: controller.openSecuritySettings,
                  onOpenSessions: controller.openActiveSessions,
                ),
                SizedBox(height: AppSpacing.lg),

                // 4. تفضيلات المظهر (الوضع الليلي التفاعلي)
                Obx(
                  () => ProfilePreferencesSection(
                    isDarkMode: controller.isDarkMode,
                    onToggleTheme: controller.toggleTheme,
                  ),
                ),
                SizedBox(height: AppSpacing.md),

                // 5. زر تسجيل الخروج السيادي
                ProfileLogoutTile(onLogout: controller.logout),
                SizedBox(height: AppSpacing.xl),

                if (controller.isLoading.value) ...[
                  SizedBox(height: AppSpacing.xs),
                  const LinearProgressIndicator(minHeight: 2),
                ],
              ],
            ),
          );
        }),
      ],
    );

    if (embedded) return content;

    return CustomAppScaffold(
      appBarTitle: 'مركز الحساب',
      appBarSubtitle: 'الهوية الرقمية والحماية الشخصية',
      body: content,
    );
  }
}
