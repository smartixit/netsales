import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/user_devices/domain/entities/user_device_entity.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_card_info_bar.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';

/// بطاقة الجهاز التنفيذية بأسلوب تطبيق قيد — عرض نقي دون أي منطق.
class UserDeviceCard extends StatelessWidget {
  const UserDeviceCard({
    super.key,
    required this.device,
    required this.isCurrent,
    required this.onTap,
    required this.onCopyUuid,
    this.onDisconnect,
  });

  final UserDeviceEntity device;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback onCopyUuid;
  final VoidCallback? onDisconnect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typePres = EnumPresentationRegistry.resolveDeviceType(
      device.typedDeviceType,
      serverLabel: device.deviceTypeLabel,
    );
    final statusPres = EnumPresentationRegistry.resolveUserDeviceStatus(
      device.typedStatus,
      serverLabel: device.statusLabel,
    );
    final accent = isCurrent ? colors.primary : colors.onSurfaceVariant;

    return CustomSurfaceCard(
      onTap: onTap,
      padding: EdgeInsets.all(AppSpacing.md),
      borderColor: isCurrent
          ? colors.primary.withValues(alpha: 0.45)
          : colors.outlineVariant.withValues(alpha: 0.55),
      borderWidth: isCurrent ? 1.4 : 1,
      backgroundColor: isCurrent
          ? colors.primary.withValues(alpha: 0.04)
          : colors.surfaceContainerLowest,
      child: Stack(
        children: [
          PositionedDirectional(
            end: -8.w,
            bottom: -10.h,
            child: Icon(
              typePres.icon ?? Icons.devices_rounded,
              size: 64.sp,
              color: accent.withValues(alpha: 0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      typePres.icon ?? Icons.devices_rounded,
                      color: accent,
                      size: 22.sp,
                    ),
                  ),
                  AppSpacing.hMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                device.displayName,
                                style: AppTypography.titleSmall.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            AppSpacing.hXs,
                            CustomStatusBadge.fromPresentation(
                              statusPres,
                              showDot: true,
                              isCompact: true,
                            ),
                          ],
                        ),
                        AppSpacing.vXs,
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            if (isCurrent)
                              CustomChip(
                                label: 'هذا الجهاز',
                                icon: Icons.verified_rounded,
                                backgroundColor: colors.primary,
                                foregroundColor: colors.onPrimary,
                              ),
                            CustomChip.fromPresentation(
                              typePres,
                              isCompact: true,
                            ),
                            if (device.isPrimary)
                              CustomChip(
                                label: 'جهاز أساسي',
                                icon: Icons.star_rounded,
                                backgroundColor:
                                    colors.secondary.withValues(alpha: 0.14),
                                foregroundColor: colors.secondary,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onDisconnect != null) ...[
                    AppSpacing.hXs,
                    CustomButton.icon(
                      icon: Icons.link_off_rounded,
                      foregroundColor: colors.error,
                      backgroundColor: colors.error.withValues(alpha: 0.08),
                      size: AppButtonSize.small,
                      tooltip: 'فصل الجهاز',
                      onPressed: onDisconnect,
                    ),
                  ],
                ],
              ),
              AppSpacing.vSm,
              CustomCardInfoBar(
                items: [
                  CustomCardInfoItem(
                    icon: Icons.access_time_rounded,
                    text: 'آخر نشاط: ${device.formattedLastUsed}',
                    color: colors.onSurfaceVariant,
                  ),
                  CustomCardInfoItem(
                    icon: Icons.fingerprint_rounded,
                    text: device.shortUuid,
                    showCopyIcon: true,
                    isMonospace: true,
                    color: colors.primary,
                    onTap: onCopyUuid,
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
