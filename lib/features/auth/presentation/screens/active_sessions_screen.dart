import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/auth/domain/entities/user_device_entity.dart';
import 'package:netsales/features/auth/presentation/controllers/active_sessions_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة إدارة الأجهزة والجلسات النشطة (ActiveSessionsScreen)
/// مصممة وفق المعيار القياسي لتصميم واجهات المستخدم للمؤسسات (NetSales Premium UI/UX)
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
              // 1. بطاقة الجهاز الحالي المميزة (Current Device Hero Card)
              if (currentDevice != null) ...[
                _buildCurrentDeviceCard(context, currentDevice),
                AppSpacing.vLg,
              ],

              // 2. زر إنهاء الجلسات الأخرى عند توفر أجهزة متعددة
              if (otherDevices.isNotEmpty) ...[
                _buildLogoutOtherDevicesCard(context, otherDevices.length),
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
                  subtitle:
                      'كافة عمليات الدخول محصورة ومؤمنة في هذا الجهاز الحالي المصادق عليه.',
                  icon: Icons.devices_other_rounded,
                )
              else
                ...otherDevices.map(
                  (device) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _buildOtherDeviceCard(context, device),
                  ),
                ),

              SizedBox(height: 32.h),
            ],
          ),
        );
      }),
    );
  }

  /// بناء بطاقة الجهاز الحالي البارزة
  Widget _buildCurrentDeviceCard(
    BuildContext context,
    UserDeviceEntity device,
  ) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _resolveDeviceIcon(device.deviceType),
                  color: colors.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            device.deviceName ?? 'الجهاز الحالي',
                            style: AppTypography.titleMedium.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            'هذا الجهاز',
                            style: AppTypography.badgeText.copyWith(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'النوع: ${device.deviceTypeLabel ?? device.deviceType ?? "غير محدد"}',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          Divider(
            color: colors.outlineVariant.withValues(alpha: 0.2),
            height: 1,
          ),
          AppSpacing.vSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المعرف: ${_formatDeviceUuid(device.deviceUuid)}',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                'نشط الآن',
                style: AppTypography.badgeText.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// بناء بطاقة إجراء إنهاء الجلسات الأخرى
  Widget _buildLogoutOtherDevicesCard(BuildContext context, int count) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: colors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.phonelink_erase_rounded,
              color: colors.error,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أجهزة أخرى متصلة ($count)',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'يمكنك تسجيل الخروج من كافة الجلسات الأخرى بنقرة واحدة.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          CustomButton.secondary(
            text: 'إنهاء الجلسات',
            loading: controller.isActionLoading.value,
            onPressed: controller.logoutOtherDevices,
          ),
        ],
      ),
    );
  }

  /// بناء بطاقة جهاز مقترن آخر
  Widget _buildOtherDeviceCard(BuildContext context, UserDeviceEntity device) {
    final colors = context.colors;

    final lastUsedText = device.lastUsedAt != null
        ? _formatLastUsed(device.lastUsedAt!)
        : 'غير معروف';

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _resolveDeviceIcon(device.deviceType),
              color: colors.onSurfaceVariant,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.deviceName ?? 'جهاز مقترن',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  'النوع: ${device.deviceTypeLabel ?? device.deviceType ?? "جهاز ذكي"} • آخر نشاط: $lastUsedText',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'المعرف: ${_formatDeviceUuid(device.deviceUuid)}',
                  style: AppTypography.badgeText.copyWith(
                    color: colors.outline,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          CustomButton.icon(
            icon: Icons.remove_circle_outline_rounded,
            foregroundColor: colors.error,
            backgroundColor: colors.error.withValues(alpha: 0.08),
            size: AppButtonSize.small,
            tooltip: 'فصل وإلغاء اقتران هذا الجهاز',
            onPressed: () => controller.disconnectDevice(device),
          ),
        ],
      ),
    );
  }

  IconData _resolveDeviceIcon(String? deviceType) {
    final type = (deviceType ?? '').toUpperCase();
    return switch (type) {
      'ANDROID' => Icons.phone_android_rounded,
      'IOS' => Icons.phone_iphone_rounded,
      'LINUX' => Icons.laptop_chromebook_rounded,
      'WINDOWS' => Icons.desktop_windows_rounded,
      'MAC' => Icons.laptop_mac_rounded,
      _ => Icons.devices_rounded,
    };
  }

  String _formatDeviceUuid(String uuid) {
    if (uuid.length <= 12) return uuid;
    return '${uuid.substring(0, 6)}...${uuid.substring(uuid.length - 4)}';
  }

  String _formatLastUsed(String rawDate) {
    try {
      final parsed = DateTime.parse(rawDate);
      return DateFormatter.smart(parsed);
    } catch (_) {
      return rawDate;
    }
  }
}
