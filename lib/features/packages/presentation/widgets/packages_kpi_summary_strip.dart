import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/packages/presentation/controllers/packages_controller.dart';
import 'package:netsales/widgets/cards/custom_kpi_card.dart';

/// ============================================================================
/// شريط مؤشرات الأداء الحيوية للباقات والخصومات (PackagesKpiSummaryStrip)
/// ============================================================================
class PackagesKpiSummaryStrip extends StatelessWidget {
  final PackagesController controller;

  const PackagesKpiSummaryStrip({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final isPackagesTab = controller.activeSegmentIndex.value == 0;

      return SizedBox(
        height: AppSpacing.kpiStripHeight,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          children: isPackagesTab
              ? [
                  CustomKpiCard.compact(
                    title: 'إجمالي الباقات',
                    value: '${controller.totalPackagesCount}',
                    unit: 'باقة',
                    icon: Icons.inventory_2_outlined,
                    iconColor: colors.primary,
                  ),
                  AppSpacing.hSm,
                  CustomKpiCard.compact(
                    title: 'الباقات النشطة',
                    value: '${controller.activePackagesCount}',
                    unit: 'نشطة',
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: colors.success,
                  ),
                  AppSpacing.hSm,
                  CustomKpiCard.compact(
                    title: 'متوسط الأسعار',
                    value: AmountFormatter.formatValue(
                      controller.averagePackagePrice,
                      decimalPlaces: 0,
                    ),
                    unit: 'ر.ي',
                    icon: Icons.payments_outlined,
                    iconColor: colors.secondary,
                  ),
                ]
              : [
                  CustomKpiCard.compact(
                    title: 'الخصومات المخصصة',
                    value: '${controller.totalDiscountsCount}',
                    unit: 'خصم',
                    icon: Icons.loyalty_outlined,
                    iconColor: colors.primary,
                  ),
                  AppSpacing.hSm,
                  CustomKpiCard.compact(
                    title: 'الخصومات النشطة',
                    value: '${controller.activeDiscountsCount}',
                    unit: 'مفعل',
                    icon: Icons.verified_outlined,
                    iconColor: colors.success,
                  ),
                ],
        ),
      );
    });
  }
}
