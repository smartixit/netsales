import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/auth/presentation/controllers/active_sessions_controller.dart';
import 'package:netsales/features/auth/presentation/widgets/current_device_card.dart';
import 'package:netsales/features/auth/presentation/widgets/logout_other_devices_card.dart';
import 'package:netsales/features/auth/presentation/widgets/other_device_card.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة إدارة الأجهزة والجلسات النشطة (ActiveSessionsScreen)
/// مسؤوليتها: تركيب الصفحة وتنسيق المكونات وتوصيلها بالمتحكم (Pure Page Composition)
class ActiveSessionsScreen extends GetView<ActiveSessionsController> {
  const ActiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      showBackButton: true,
      appBarTitle: 'الأجهزة والجلسات النشطة',
      appBarSubtitle: 'إدارة أجهزتك المقترنة والتحكم في جلسات الدخول الفعالة',
      body: Obx(() {
        if (controller.isLoading.value) {
          return const CustomSkeletonFeed();
        }

        if (controller.errorMessage.value != null) {
          return CustomErrorState(
            title: 'تعذر تحميل الأجهزة المقترنة',
            subtitle: controller.errorMessage.value,
            onRetry: controller.loadDevices,
          );
        }

        final currentDevice = controller.currentDevice;
        final otherDevices = controller.otherDevices;

        return RefreshIndicator(
          onRefresh: controller.loadDevices,
          color: colors.primary,
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            children: [
              // 1. بطاقة الجهاز الحالي المميزة (Decomposed Feature Widget)
              if (currentDevice != null) ...[
                CurrentDeviceCard(device: currentDevice),
                AppSpacing.vLg,
              ],

              // 2. زر إنهاء الجلسات الأخرى عند توفر أجهزة متعددة (Decomposed Feature Widget)
              if (otherDevices.isNotEmpty) ...[
                LogoutOtherDevicesCard(
                  deviceCount: otherDevices.length,
                  isLoading: controller.isActionLoading.value,
                  onLogoutOtherDevices: controller.logoutOtherDevices,
                ),
                AppSpacing.vLg,
              ],

              // 3. ترويسة قائمة الأجهزة الأخرى
              Row(
                children: [
                  Icon(
                    Icons.devices_other_rounded,
                    size: 20.sp,
                    color: colors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'الأجهزة المقترنة الأخرى (${otherDevices.length})',
                    style: AppTypography.titleMedium.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              AppSpacing.vMd,

              // 4. حالة الخلو أو قائمة الأجهزة المقترنة
              if (otherDevices.isEmpty)
                const CustomEmptyState.boxed(
                  title: 'لا توجد أجهزة أخرى مقترنة بهذا الحساب حالياً.',
                  subtitle: 'كافة عمليات الدخول محصورة ومؤمنة في هذا الجهاز الحالي المصادق عليه.',
                  icon: Icons.devices_other_rounded,
                )
              else
                ...otherDevices.map(
                  (device) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: OtherDeviceCard(
                      device: device,
                      onDisconnect: () => controller.disconnectDevice(device),
                    ),
                  ),
                ),

              SizedBox(height: 32.h),
            ],
          ),
        );
      }),
    );
  }
}
