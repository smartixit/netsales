import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/user_sessions/domain/entities/user_session_entity.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_card_info_bar.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';

/// بطاقة الجلسة التنفيذية بأسلوب تطبيق قيد — عرض نقي دون أي منطق.
class UserSessionCard extends StatelessWidget {
  const UserSessionCard({
    super.key,
    required this.session,
    required this.onTap,
    this.onCopyIp,
    this.onTerminate,
  });

  final UserSessionEntity session;
  final VoidCallback onTap;
  final VoidCallback? onCopyIp;
  final VoidCallback? onTerminate;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusPres = EnumPresentationRegistry.resolveUserSessionStatus(
      session.typedStatus,
      serverLabel: session.statusLabel,
    );
    final accent = session.isCurrent
        ? colors.primary
        : (session.isActive ? colors.secondary : colors.onSurfaceVariant);

    return CustomSurfaceCard(
      onTap: onTap,
      padding: EdgeInsets.all(AppSpacing.md),
      borderColor: session.isCurrent
          ? colors.primary.withValues(alpha: 0.45)
          : colors.outlineVariant.withValues(alpha: 0.55),
      borderWidth: session.isCurrent ? 1.4 : 1,
      backgroundColor: session.isCurrent
          ? colors.primary.withValues(alpha: 0.04)
          : colors.surfaceContainerLowest,
      child: Stack(
        children: [
          PositionedDirectional(
            end: -8.w,
            bottom: -10.h,
            child: Icon(
              statusPres.icon ?? Icons.sensors_rounded,
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
                      statusPres.icon ?? Icons.sensors_rounded,
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
                                session.displayClient,
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
                            if (session.isCurrent)
                              CustomChip(
                                label: 'الجلسة الحالية',
                                icon: Icons.verified_rounded,
                                backgroundColor: colors.primary,
                                foregroundColor: colors.onPrimary,
                              ),
                            if (session.shortDeviceUuid.isNotEmpty)
                              CustomChip(
                                label: session.shortDeviceUuid,
                                icon: Icons.devices_rounded,
                                backgroundColor: colors.surfaceContainerHigh,
                                foregroundColor: colors.onSurfaceVariant,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onTerminate != null) ...[
                    AppSpacing.hXs,
                    CustomButton.icon(
                      icon: Icons.logout_rounded,
                      foregroundColor: colors.error,
                      backgroundColor: colors.error.withValues(alpha: 0.08),
                      size: AppButtonSize.small,
                      tooltip: 'إنهاء الجلسة',
                      onPressed: onTerminate,
                    ),
                  ],
                ],
              ),
              AppSpacing.vSm,
              CustomCardInfoBar(
                items: [
                  CustomCardInfoItem(
                    icon: Icons.access_time_rounded,
                    text: 'آخر نشاط: ${session.formattedLastActivity}',
                    color: colors.onSurfaceVariant,
                  ),
                  if (session.ipAddress != null &&
                      session.ipAddress!.trim().isNotEmpty)
                    CustomCardInfoItem(
                      icon: Icons.wifi_rounded,
                      text: session.ipAddress!,
                      showCopyIcon: true,
                      isMonospace: true,
                      color: colors.primary,
                      onTap: onCopyIp,
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
