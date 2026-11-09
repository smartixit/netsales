import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/subscription/presentation/controllers/network_subscription_controller.dart';
import 'package:netsales/features/subscription/presentation/widgets/early_activation_dialog.dart';
import 'package:netsales/features/subscription/presentation/widgets/quota_progress_card.dart';
import 'package:netsales/features/subscription/presentation/widgets/subscription_header_card.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة استعراض اشتراك الشبكة ومتابعة استهلاك الحصص (NetworkSubscriptionScreen)
class NetworkSubscriptionScreen extends GetView<NetworkSubscriptionController> {
  const NetworkSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      showBackButton: true,
      appBarTitle: 'اشتراك الشبكة والحصص',
      appBarSubtitle:
          'متابعة الباقة السحابية والحدود التشغيلية والاستهلاك الفعلي',
      body: Obx(() {
        if (controller.isLoading.value) {
          return const CustomSkeletonFeed(itemCount: 4, cardHeight: 120);
        }

        if (controller.errorMessage.value != null &&
            controller.subscription.value == null) {
          return CustomErrorState(
            title: 'تعذر تحميل بيانات الاشتراك',
            subtitle: controller.errorMessage.value,
            onRetry: controller.loadSubscription,
          );
        }

        final sub = controller.subscription.value;
        if (sub == null) {
          return RefreshIndicator(
            onRefresh: controller.loadSubscription,
            color: colors.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 120.h),
                CustomEmptyState(
                  icon: Icons.card_membership_outlined,
                  title: 'لا يوجد اشتراك نشط لهذه الشبكة',
                  subtitle: 'تأكد من ترقية أو اعتماد باقة اشتراك سارية من إدارة النظام.',
                  actionLabel: 'إعادة المحاولة',
                  onAction: controller.loadSubscription,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadSubscription,
          color: colors.primary,
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            children: [
              // 1. بطاقة رأس الاشتراك وتفاصيل الباقة
              SubscriptionHeaderCard(subscription: sub),

              AppSpacing.vLg,

              // 2. زر التفعيل المبكر إذا كانت هناك حصص نفدت أو على وشك النفاد
              if (sub.hasExhaustedQuotas || sub.hasNearExhaustionQuotas) ...[
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: colors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: colors.warning,
                        size: 24.sp,
                      ),
                      AppSpacing.hSm,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تنبيه الحصص التشغيلية',
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                            ),
                            AppSpacing.vXxs,
                            Text(
                              'شارفت بعض الحصص على النفاد. يمكنك تفعيل الخطة المجدولة التالية مبكراً.',
                              style: AppTypography.bodySmall.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.hSm,
                      CustomButton.primary(
                        text: 'تفعيل مبكر',
                        icon: Icons.flash_on_rounded,
                        loading: controller.isActionLoading.value,
                        onPressed: () => EarlyActivationDialog.show(
                          context,
                          onConfirm: () => controller.activateEarly(),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.vLg,
              ],

              // 3. قسم قائمة الحصص
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الحصص التشغيلية والاستهلاك',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${sub.quotas.length} ميزات',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              AppSpacing.vMd,

              if (sub.quotas.isEmpty)
                Container(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'لا توجد حصص محددة مقيدة لهذه الباقة (وصول مفتوح).',
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                ...sub.quotas.map((quota) => QuotaProgressCard(quota: quota)),

              AppSpacing.vXl,
            ],
          ),
        );
      }),
    );
  }
}
