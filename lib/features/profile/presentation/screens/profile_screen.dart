import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/profile/domain/entities/profile_entity.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_controller.dart';
import 'package:netsales/features/profile/presentation/widgets/profile_body.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';
import 'package:netsales/widgets/pickers/custom_image_picker.dart';
import 'package:netsales/widgets/shapes/custom_circle_shape.dart';

/// شاشة مركز الحساب — تحافظ على التصميم التنفيذي المتدرج واللوحة المتراكبة
/// مع تجاوب كامل وخلو تام من المنطق والاعتماد الكامل على مكونات المشروع.
class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = CustomRefreshablePage.slivers(
      padding: EdgeInsets.zero,
      embedded: embedded,
      maxContentWidth: 680,
      onRefresh: controller.loadProfile,
      scrollKey: const PageStorageKey<String>('profile-account-centre-scroll'),
      slivers: [
        Obx(() {
          final profile = controller.profile.value;

          if (controller.isLoading.value && profile == null) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: CustomStateView.loading(
                  presentation: CustomStatePresentation.skeletonOnly,
                  skeleton: const CustomStateSkeleton(
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

          return SliverToBoxAdapter(
            child: _ProfileExecutiveCanvas(profile: profile),
          );
        }),
      ],
    );

    if (embedded) return content;

    return CustomAppScaffold(
      appBarTitle: 'مركز الحساب',
      showBackButton: true,
      body: content,
    );
  }
}

class _ProfileExecutiveCanvas extends GetView<ProfileController> {
  const _ProfileExecutiveCanvas({required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final avatarSize = 122.r;
    final headerHeight = 148.h;
    final overlapOffset = avatarSize / 2;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: colors.executiveHeroGradient),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          CustomCircleShape(left: -40.r, top: -20.r, size: 150.r),
          CustomCircleShape(right: -40.r, top: 64.h, size: 140.r),
          CustomCircleShape(left: 48.w, top: 44.h, size: 110.r),

          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: headerHeight),
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: double.infinity,
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
                          color: colors.shadow.withValues(alpha: 0.12),
                          blurRadius: 22,
                          offset: const Offset(0, -7),
                        ),
                      ],
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppRadius.xxxl),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            colors.primary.withValues(alpha: 0.14),
                            colors.surfaceContainerLow.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.24],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          top: overlapOffset + AppSpacing.md,
                          start: AppSpacing.cardPadding,
                          end: AppSpacing.cardPadding,
                          bottom: AppSpacing.sectionXl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              profile.fullName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colors.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            AppSpacing.vSm,
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.xs,
                              alignment: WrapAlignment.center,
                              children: [
                                CustomChip(
                                  label: profile.phoneNumber,
                                  icon: Icons.phone_android_rounded,
                                  backgroundColor: colors.primary.withValues(
                                    alpha: 0.10,
                                  ),
                                  foregroundColor: colors.primary,
                                ),
                                if (profile.primaryRoleName != null)
                                  CustomChip(
                                    label: profile.primaryRoleName!,
                                    icon: Icons.workspace_premium_outlined,
                                    backgroundColor: colors.secondary
                                        .withValues(alpha: 0.12),
                                    foregroundColor: colors.secondary,
                                  ),
                              ],
                            ),
                            AppSpacing.vMd,
                            Center(
                              child: SizedBox(
                                width: 120.w,
                                child: Divider(
                                  color: colors.outlineVariant,
                                  thickness: 3,
                                  radius: BorderRadius.circular(AppRadius.full),
                                ),
                              ),
                            ),
                            AppSpacing.vLg,
                            const ProfileBody(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // الأفاتار المتراكب بإطار ذهبي تنفيذي
                  Positioned(
                    top: -overlapOffset,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.executiveGoldAccent,
                          width: 5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withValues(alpha: 0.16),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: CustomImagePicker.avatar(
                        label: '',
                        hint: '',
                        size: avatarSize,
                        existingImageUrl: profile.avatarUrl,
                        valueListenable: controller.avatarFile,
                        onChanged: controller.onAvatarPicked,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
