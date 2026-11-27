import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/user_devices/domain/entities/user_device_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_detail_info_section.dart';

/// ورقة تفاصيل الجهاز السفلية بأسلوب تطبيق قيد — عرض نقي.
class UserDeviceDetailSheet extends StatelessWidget {
  const UserDeviceDetailSheet({
    super.key,
    required this.device,
    required this.isCurrent,
    required this.onCopyValue,
    this.onDisconnect,
  });

  final UserDeviceEntity device;
  final bool isCurrent;
  final void Function(String label, String value) onCopyValue;
  final VoidCallback? onDisconnect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusPres = EnumPresentationRegistry.resolveUserDeviceStatus(
      device.typedStatus,
      serverLabel: device.statusLabel,
    );
    final typePres = EnumPresentationRegistry.resolveDeviceType(
      device.typedDeviceType,
      serverLabel: device.deviceTypeLabel,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomDetailInfoSection(
          icon: Icons.devices_rounded,
          title: 'بيانات الجهاز',
          children: [
            CustomDetailInfoTile(
              icon: Icons.numbers_rounded,
              label: 'معرف الجهاز',
              value: '#${device.deviceId}',
              onCopy: () => onCopyValue('معرف الجهاز', '${device.deviceId}'),
            ),
            const CustomDetailInfoDivider(),
            CustomDetailInfoTile(
              icon: Icons.fingerprint_rounded,
              label: 'المعرف الفريد (UUID)',
              value: device.deviceUuid,
              onCopy: () => onCopyValue('المعرف الفريد', device.deviceUuid),
            ),
            const CustomDetailInfoDivider(),
            CustomDetailInfoTile(
              icon: Icons.smartphone_rounded,
              label: 'اسم الجهاز',
              value: device.displayName,
            ),
            const CustomDetailInfoDivider(),
            CustomDetailInfoTile(
              icon: typePres.icon ?? Icons.category_outlined,
              label: 'نوع الجهاز',
              value: typePres.label,
            ),
          ],
        ),
        AppSpacing.vMd,
        CustomDetailInfoSection(
          icon: Icons.security_rounded,
          title: 'الأمان وحالة الاقتران',
          children: [
            CustomDetailInfoTile(
              icon: statusPres.icon ?? Icons.verified_user_outlined,
              label: 'حالة الجهاز',
              value: statusPres.label,
              highlight: device.isActive,
              valueColor: device.isBanned ? colors.error : null,
            ),
            const CustomDetailInfoDivider(),
            CustomDetailInfoTile(
              icon: Icons.verified_outlined,
              label: 'الجهاز الحالي',
              value: isCurrent ? 'نعم — هذا هو جهازك المستخدم الآن' : 'لا',
              highlight: isCurrent,
            ),
            const CustomDetailInfoDivider(),
            CustomDetailInfoTile(
              icon: Icons.star_outline_rounded,
              label: 'الجهاز الأساسي',
              value: device.isPrimary ? 'نعم' : 'لا',
            ),
          ],
        ),
        AppSpacing.vMd,
        CustomDetailInfoSection(
          icon: Icons.history_rounded,
          title: 'سجل النشاط والتواريخ',
          children: [
            CustomDetailInfoTile(
              icon: Icons.access_time_rounded,
              label: 'آخر استخدام',
              value: device.formattedLastUsed,
            ),
            const CustomDetailInfoDivider(),
            CustomDetailInfoTile(
              icon: Icons.calendar_today_outlined,
              label: 'تاريخ تسجيل الجهاز',
              value: device.formattedCreatedAt,
            ),
          ],
        ),
        if (onDisconnect != null) ...[
          AppSpacing.vLg,
          CustomButton(
            text: 'فصل وإلغاء اقتران الجهاز',
            variant: AppButtonVariant.danger,
            icon: Icons.link_off_rounded,
            width: double.infinity,
            onPressed: onDisconnect,
          ),
        ],
      ],
    );
  }
}
