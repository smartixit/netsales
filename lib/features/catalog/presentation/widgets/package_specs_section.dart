import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_specs_mobile_layout.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_specs_tablet_layout.dart';

/// قسم استعراض المواصفات الفنية للكرت بتخطيط متكيف مع الهواتف والأجهزة اللوحية
class PackageSpecsSection extends StatelessWidget {
  final PackageEntity package;

  const PackageSpecsSection({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isTablet = AppBreakpoints.isTablet(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.tune_rounded,
              size: AppSpacing.xl,
              color: colors.primary,
            ),
            AppSpacing.hXs,
            Text(
              'المواصفات الفنية للكرت',
              style: AppTypography.titleSmall.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        AppSpacing.vSm,
        if (isTablet)
          PackageSpecsTabletLayout(package: package)
        else
          PackageSpecsMobileLayout(package: package),
      ],
    );
  }
}
