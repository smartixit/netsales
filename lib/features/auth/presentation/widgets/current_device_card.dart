import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/auth/domain/entities/user_device_entity.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

/// بطاقة الجهاز الحالي المصادق عليه (Current Device Hero Card)
class CurrentDeviceCard extends StatelessWidget {
  const CurrentDeviceCard({super.key, required this.device});

  final UserDeviceEntity device;

  String _formatDeviceUuid(String uuid) {
    if (uuid.length <= 12) return uuid;
    return '${uuid.substring(0, 6)}...${uuid.substring(uuid.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
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
                  EnumPresentationRegistry.resolveDeviceType(
                        device.typedDeviceType,
                      ).icon ??
                      Icons.devices_rounded,
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
                    SizedBox(height: 6.h),
                    CustomChip.fromPresentation(
                      EnumPresentationRegistry.resolveDeviceType(
                        device.typedDeviceType,
                        serverLabel: device.deviceTypeLabel,
                      ),
                      isCompact: true,
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
              CustomStatusBadge.fromPresentation(
                EnumPresentationRegistry.resolveUserDeviceStatus(
                  device.typedStatus,
                  serverLabel: device.statusLabel,
                ),
                showDot: true,
                isCompact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

