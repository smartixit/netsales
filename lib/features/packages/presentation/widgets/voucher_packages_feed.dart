import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/features/packages/presentation/controllers/packages_controller.dart';
import 'package:netsales/features/packages/presentation/widgets/create_edit_discount_sheet.dart';
import 'package:netsales/features/packages/presentation/widgets/create_edit_package_sheet.dart';
import 'package:netsales/features/packages/presentation/widgets/voucher_package_card.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';

/// ============================================================================
/// قائمة تغذية باقات كروت الإنترنت (VoucherPackagesFeed)
/// ============================================================================
class VoucherPackagesFeed extends StatelessWidget {
  final PackagesController controller;

  const VoucherPackagesFeed({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      if (controller.isLoadingPackages.value && controller.packages.isEmpty) {
        return Center(
          child: CircularProgressIndicator(color: colors.primary),
        );
      }

      if (controller.packagesError.value.isNotEmpty &&
          controller.packages.isEmpty) {
        return Center(
          child: CustomEmptyState(
            title: 'تعذر جلب باقات الكروت',
            subtitle: controller.packagesError.value,
            actionLabel: 'إعادة المحاولة',
            onAction: () => controller.loadPackages(isRefresh: true),
          ),
        );
      }

      final items = controller.filteredPackages;

      if (items.isEmpty) {
        return Center(
          child: CustomEmptyState(
            title: 'لا توجد باقات كروت مطابقة',
            subtitle: controller.searchController.text.isNotEmpty
                ? 'لم نجد أي باقة تطابق بحثك الحالي، جرّب كلمات أخرى.'
                : 'لم يتم تعريف أي باقات كروت للشبكة بعد. أضف أول باقة الآن.',
            actionLabel: controller.searchController.text.isNotEmpty
                ? 'مسح البحث'
                : 'إضافة باقة جديدة',
            onAction: () {
              if (controller.searchController.text.isNotEmpty) {
                controller.searchController.clear();
                controller.packages.refresh();
              } else {
                CreateEditPackageSheet.show(context, controller: controller);
              }
            },
          ),
        );
      }

      return RefreshIndicator(
        color: colors.primary,
        onRefresh: () => controller.loadPackages(isRefresh: true),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.sm,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final package = items[index];
            return VoucherPackageCard(
              package: package,
              onToggleStatus: () =>
                  controller.togglePackageStatus(package.packageId),
              onEdit: () => CreateEditPackageSheet.show(
                context,
                controller: controller,
                package: package,
              ),
              onDelete: () => _confirmDelete(context, package),
              onAddDiscount: () => CreateEditDiscountSheet.show(
                context,
                controller: controller,
                preselectedPackageId: package.packageId,
              ),
            );
          },
        ),
      );
    });
  }

  void _confirmDelete(BuildContext context, VoucherPackageEntity package) async {
    final confirmed = await CustomDialog.showDanger(
      title: 'حذف باقة الكروت',
      message:
          'هل أنت متأكد من رغبتك في نقل باقة "${package.packageName}" إلى سلة المحذوفات؟ يمكنك استعادتها لاحقاً.',
      confirmLabel: 'نعم، حذف',
      cancelLabel: 'إلغاء',
    );

    if (confirmed == true) {
      controller.deletePackage(package.packageId);
    }
  }
}
