import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/user_sessions/domain/entities/user_session_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_detail_info_section.dart';

/// ورقة تفاصيل الجلسة السفلية بأسلوب تطبيق قيد — عرض نقي.
class UserSessionDetailSheet extends StatelessWidget {
  const UserSessionDetailSheet({
    super.key,
    required this.session,
    required this.onCopyValue,
    this.onTerminate,
  });

  final UserSessionEntity session;
  final void Function(String label, String value) onCopyValue;
  final VoidCallback? onTerminate;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusPres = EnumPresentationRegistry.resolveUserSessionStatus(
      session.typedStatus,
      serverLabel: session.statusLabel,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomDetailInfoSection(
          icon: Icons.sensors_rounded,
          title: 'بيانات الجلسة',
          children: [
            CustomDetailInfoTile(
              icon: Icons.numbers_rounded,
              label: 'معرف الجلسة',
              value: '#${session.sessionId}',
              onCopy: () => onCopyValue('معرف الجلسة', '${session.sessionId}'),
            ),
            const CustomDetailInfoDivider(),
            CustomDetailInfoTile(
              icon: statusPres.icon ?? Icons.verified_user_outlined,
              label: 'حالة الجلسة',
              value: statusPres.label,
              highlight: session.isActive,
              valueColor: !session.isActive ? colors.error : null,
            ),
            const CustomDetailInfoDivider(),
            CustomDetailInfoTile(
              icon: Icons.verified_outlined,
              label: 'الجلسة الحالية',
              value: session.isCurrent ? 'نعم — جلستك النشطة الآن' : 'لا',
              highlight: session.isCurrent,
            ),
          ],
        ),
        AppSpacing.vMd,
        CustomDetailInfoSection(
          icon: Icons.wifi_rounded,
          title: 'الشبكة والنشاط',
          children: [
            CustomDetailInfoTile(
              icon: Icons.language_rounded,
              label: 'عنوان IP',
              value: session.ipAddress ?? '---',
              onCopy: (session.ipAddress?.trim().isNotEmpty == true)
                  ? () => onCopyValue('عنوان IP', session.ipAddress!)
                  : null,
            ),
            const CustomDetailInfoDivider(),
            CustomDetailInfoTile(
              icon: Icons.access_time_rounded,
              label: 'آخر نشاط',
              value: session.formattedLastActivity,
            ),
            const CustomDetailInfoDivider(),
            CustomDetailInfoTile(
              icon: Icons.login_rounded,
              label: 'وقت تسجيل الدخول',
              value: session.formattedLoggedAt,
            ),
            if (session.expiresAt != null && session.expiresAt!.isNotEmpty) ...[
              const CustomDetailInfoDivider(),
              CustomDetailInfoTile(
                icon: Icons.timer_outlined,
                label: 'تاريخ الانتهاء',
                value: session.formattedExpiresAt,
              ),
            ],
            if (session.revokedAt != null && session.revokedAt!.isNotEmpty) ...[
              const CustomDetailInfoDivider(),
              CustomDetailInfoTile(
                icon: Icons.block_rounded,
                label: 'تاريخ الإلغاء',
                value: session.formattedRevokedAt,
                valueColor: colors.error,
              ),
            ],
          ],
        ),
        AppSpacing.vMd,
        CustomDetailInfoSection(
          icon: Icons.desktop_windows_rounded,
          title: 'معلومات العميل والجهاز',
          children: [
            CustomDetailInfoTile(
              icon: Icons.terminal_rounded,
              label: 'User Agent',
              value: session.userAgent ?? '---',
              onCopy: (session.userAgent?.trim().isNotEmpty == true)
                  ? () => onCopyValue('User Agent', session.userAgent!)
                  : null,
            ),
            if (session.deviceUuid != null &&
                session.deviceUuid!.isNotEmpty) ...[
              const CustomDetailInfoDivider(),
              CustomDetailInfoTile(
                icon: Icons.fingerprint_rounded,
                label: 'معرف الجهاز (UUID)',
                value: session.deviceUuid!,
                onCopy: () => onCopyValue('معرف الجهاز', session.deviceUuid!),
              ),
            ],
          ],
        ),
        if (onTerminate != null) ...[
          AppSpacing.vLg,
          CustomButton(
            text: 'إنهاء هذه الجلسة',
            variant: AppButtonVariant.danger,
            icon: Icons.logout_rounded,
            width: double.infinity,
            onPressed: onTerminate,
          ),
        ],
      ],
    );
  }
}
