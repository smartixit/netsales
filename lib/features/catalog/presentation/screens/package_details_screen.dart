import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_action_buttons.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_delete_confirm_dialog.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_details_header.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_pricing_summary_card.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_specs_section.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة تفاصيل باقة الكروت — مسؤوليتها تركيب الصفحة فقط
class PackageDetailsScreen extends GetView<PackageCatalogController> {
  const PackageDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final package = controller.selectedPackage.value;

      if (package == null) {
        return CustomAppScaffold(
          appBar: AppBar(
            title: const Text('تفاصيل باقة الكروت'),
            centerTitle: true,
          ),
          body: Center(
            child: CustomEmptyState(
              icon: Icons.wifi_tethering_off_rounded,
              title: 'لم يتم العثور على الباقة',
              subtitle:
                  'قد تكون هذه الباقة حُذفت أو لم يعد بالإمكان الوصول إليها.',
              actionLabel: 'العودة للكتالوج',
              onAction: () => Get.back<void>(),
            ),
          ),
        );
      }

      return CustomAppScaffold(
        appBar: AppBar(
          title: Text(
            package.packageName,
            style: AppTypography.titleMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            Obx(() {
              return CustomButton.icon(
                icon: package.status
                    ? Icons.toggle_on_rounded
                    : Icons.toggle_off_rounded,
                tooltip:
                    package.status ? 'تعطيل الباقة' : 'تفعيل الباقة',
                backgroundColor: Colors.transparent,
                foregroundColor:
                    package.status ? colors.success : colors.outline,
                iconSize: AppSpacing.xxl,
                onPressed: controller.isTogglingStatus.value
                    ? null
                    : () => controller.togglePackageStatus(package),
              );
            }),
            CustomButton.icon(
              icon: Icons.edit_outlined,
              tooltip: 'تعديل بيانات الباقة',
              backgroundColor: Colors.transparent,
              foregroundColor: colors.primary,
              onPressed: () {
                controller.initEditForm(package);
                Get.toNamed<void>(AppRoutes.packageForm);
              },
            ),
            CustomButton.icon(
              icon: Icons.delete_outline_rounded,
              tooltip: 'حذف الباقة',
              backgroundColor: Colors.transparent,
              foregroundColor: colors.error,
              onPressed: () => PackageDeleteConfirmDialog.show(
                packageName: package.packageName,
                onConfirm: () async {
                  final deleted =
                      await controller.deletePackage(package.packageId);
                  if (deleted) Get.back<void>();
                },
              ),
            ),
          ],
        ),
        body: RefreshIndicator.adaptive(
          onRefresh: () =>
              controller.loadPackageDetails(package.packageId),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PackageDetailsHeader(package: package),
                AppSpacing.vMd,
                PackagePricingSummaryCard(package: package),
                AppSpacing.vMd,
                PackageSpecsSection(package: package),
                AppSpacing.vLg,
                PackageActionButtons(package: package),
                AppSpacing.vXl,
              ],
            ),
          ),
        ),
      );
    });
  }
}
