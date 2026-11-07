import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/auth/domain/entities/user_device_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// بطاقة جهاز مقترن آخر (Other Paired Device Card)
class OtherDeviceCard extends StatelessWidget {
  const OtherDeviceCard({
    super.key,
    required this.device,
    required this.onDisconnect,
  });

  final UserDeviceEntity device;
  final VoidCallback onDisconnect;

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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lastUsedText = device.lastUsedAt != null
        ? _formatLastUsed(device.lastUsedAt!)
        : 'غير معروف';

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
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
              EnumPresentationRegistry.resolveDeviceType(device.typedDeviceType)
                      .icon ??
                  Icons.devices_rounded,
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
            onPressed: onDisconnect,
          ),
        ],
      ),
    );
  }
}
