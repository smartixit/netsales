
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_controller.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_body.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';
import 'package:netsales/widgets/pickers/custom_image_picker.dart';
import 'package:netsales/widgets/shapes/custom_circle_shape.dart';

/// مركز الحساب والسيادة الرقمية (Account & Identity Centre)
/// مكوّن عرض نقي خاضع بالكامل لعقد الخادم ومطابق للتصميم التنفيذي المعتمد
class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final content = CustomRefreshablePage.slivers(
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      embedded: embedded,
      maxContentWidth: 680,
      onRefresh: () => Future.value(),
      scrollKey: const PageStorageKey<String>('profile-account-centre-scroll'),
      slivers: [
        Obx(() {
          final profile = controller.profile.value;

          if (controller.isLoading.value && profile == null) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  top: AppSpacing.appBarHeight + AppSpacing.md,
                ),
                child: CustomStateView.loading(
                  presentation: CustomStatePresentation.skeletonOnly,
                  skeleton: CustomStateSkeleton(
                    layout: CustomStateSkeletonLayout.cards,
                    itemCount: 3,
                    cardHeight: 132,
                    hasLeading: true,
                  ),
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

          return SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.of(context).executiveHeroGradient,
              ),
              child: Stack(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                children: [
                  CustomCircleShape(left: -40.r, top: -20.r, size: 150.r),
                  CustomCircleShape(
                    right: -40.r,
                    top: MediaQuery.of(context).size.height * 0.20,
                    size: 150.r,
                  ),
                  CustomCircleShape(
                    left: MediaQuery.of(context).size.width * 0.10,
                    top: MediaQuery.of(context).size.height * 0.16,
                    size: 150.r,
                  ),

                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.30,
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Container(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppRadius.xxxl),
                        ),
                        border: Border(
                          top: BorderSide(color: colors.outlineVariant),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .10),
                            blurRadius: 22,
                            offset: const Offset(0, -7),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        padding: EdgeInsetsDirectional.only(
                          top:
                              AppSpacing.appBarHeight +
                              AppSpacing.appBarHeight +
                              AppSpacing.huge,
                          start: AppSpacing.cardPadding,
                          end: AppSpacing.cardPadding,
                          bottom:
                              AppSpacing.appBarHeight + AppSpacing.sectionXl,
                        ),
                        physics: BouncingScrollPhysics(),
                        child: ProfileBody(),
                      ),
                    ),
                  ),

                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.30,
                    right: 0,
                    left: 0,
                    child: Container(
                      height: 220.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppRadius.xxxl),
                        ),
                        border: Border(
                          top: BorderSide(color: colors.outlineVariant),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            colors.surfaceContainerLow,
                            colors.surfaceContainerLow.withValues(alpha: 0.01),
                          ],
                          stops: [0.80, 20],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.30,
                    right: 0,
                    left: 0,
                    child: Container(
                      height: 220.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppRadius.xxxl),
                        ),
                        border: Border(
                          top: BorderSide(color: colors.outlineVariant),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            colors.primary.withValues(alpha: 0.18),
                            colors.surfaceContainerLow.withValues(alpha: 0.01),
                          ],
                          stops: [0, 60],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.22,
                    right: 0,
                    left: 0,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.of(context).executiveGoldAccent,
                              width: 6,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .10),
                                blurRadius: 22,
                                offset: const Offset(0, -7),
                              ),
                            ],
                          ),
                          child: CustomImagePicker.avatar(
                            label: '',
                            hint: '',
                            size: 130.r,
                            existingImageUrl: profile.avatarUrl,
                            valueListenable: controller.avatar,
                          ),
                        ),
                        AppSpacing.vMd,
                        Text(
                          profile.fullName,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 20.sp,
                          ),
                        ),
                        AppSpacing.vSm,
                        CustomChip(
                          label: profile.phoneNumber,
                          icon: Icons.phone_android_rounded,
                          backgroundColor: colors.primary.withValues(
                            alpha: .10,
                          ),
                          foregroundColor: colors.primary,
                        ),
                        AppSpacing.vSm,

                        Divider(
                          color: colors.outlineVariant,
                          indent: MediaQuery.of(context).size.width * 0.3,
                          endIndent: MediaQuery.of(context).size.width * 0.3,
                          thickness: 3,
                          radius: BorderRadius.circular(AppRadius.full),
                        ),
                      ],
                    ),
                  ),

                  // 1. شريط سياق بيئة العمل النشطة حالياً
                  // ProfileActiveContextBanner(
                  //   activeWorkspaceLabel: controller.activeWorkspaceLabel,
                  // ),
                  // SizedBox(height: AppSpacing.md),

                  // // 2. بطاقة الهوية التنفيذية الرئيسية
                  // ProfileIdentityCard(
                  //   profile: profile,
                  //   onCopyPhone: () => controller.copyToClipboard(
                  //     profile.phoneNumber,
                  //     'تم نسخ رقم الهاتف بنجاح',
                  //   ),
                  //   onCopyEmail: () => controller.copyToClipboard(
                  //     profile.email ?? '',
                  //     'تم نسخ البريد الإلكتروني بنجاح',
                  //   ),
                  //   onAvatarChanged: controller.onAvatarChanged,
                  //   onCompleteProfile: () =>
                  //       _openAccountDetailsSheet(context, profile),
                  // ),
                  // SizedBox(height: AppSpacing.lg),

                  // // 3. مركز الأمان والحماية (2FA، كلمة المرور، الجلسات والأجهزة)
                  // ProfileSecuritySection(
                  //   profile: profile,
                  //   onOpenSecurity: controller.openSecuritySettings,
                  //   onOpenSessions: controller.openActiveSessions,
                  // ),
                  // SizedBox(height: AppSpacing.lg),

                  // // 4. تفضيلات المظهر (الوضع الليلي التفاعلي)
                  // Obx(
                  //   () => ProfilePreferencesSection(
                  //     isDarkMode: controller.isDarkMode,
                  //     onToggleTheme: controller.toggleTheme,
                  //   ),
                  // ),
                  // SizedBox(height: AppSpacing.md),

                  // // 5. زر تسجيل الخروج السيادي
                  // ProfileLogoutTile(onLogout: controller.logout),
                  // SizedBox(height: AppSpacing.xl),

                  // if (controller.isLoading.value) ...[
                  //   SizedBox(height: AppSpacing.xs),
                  //   const LinearProgressIndicator(minHeight: 2),
                  // ],
                ],
              ),
            ),
          );
        }),
      ],
    );

    if (embedded) return content;

    return CustomAppScaffold(appBarTitle: 'مركز الحساب', body: content);
  }
}
