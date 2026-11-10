import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_spec_tile.dart';

/// تخطيط المواصفات الفنية للكرت على شاشات الهواتف
class PackageSpecsMobileLayout extends StatelessWidget {
  final PackageEntity package;

  const PackageSpecsMobileLayout({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PackageSpecTile(
                icon: Icons.data_usage_rounded,
                title: 'حجم الرصيد',
                value: package.balanceDisplay,
                subtitle: package.packageBalance > 0 ? 'ميجابايت' : null,
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              child: PackageSpecTile(
                icon: Icons.timer_outlined,
                title: 'وقت الاستخدام',
                value: package.uptimeDisplay,
                subtitle: package.packageUptime != null ? 'دقيقة' : null,
              ),
            ),
          ],
        ),
        AppSpacing.vSm,
        Row(
          children: [
            Expanded(
              child: PackageSpecTile(
                icon: Icons.event_available_rounded,
                title: 'فترة الصلاحية',
                value: package.validityDisplay,
                subtitle: package.packageValidity != null ? 'ساعة' : null,
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              child: PackageSpecTile(
                icon: Icons.layers_outlined,
                title: 'سعة الورقة',
                value: '${package.packageVoucherCount}',
                subtitle: 'كرت / ورقة',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
