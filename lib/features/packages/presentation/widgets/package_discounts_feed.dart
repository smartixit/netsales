import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_discount_entity.dart';
import 'package:netsales/features/packages/presentation/controllers/packages_controller.dart';
import 'package:netsales/features/packages/presentation/widgets/create_edit_discount_sheet.dart';
import 'package:netsales/features/packages/presentation/widgets/package_discount_card.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_loading_state.dart';

/// ============================================================================
/// قائمة تغذية خصومات نقاط البيع المخصصة (PackageDiscountsFeed)
/// ============================================================================
class PackageDiscountsFeed extends StatelessWidget {
  final PackagesController controller;

  const PackageDiscountsFeed({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      if (controller.isLoadingDiscounts.value && controller.discounts.isEmpty) {
        return const CustomLoadingState();
      }

      if (controller.discountsError.value.isNotEmpty &&
          controller.discounts.isEmpty) {
        return CustomErrorState(
          title: 'تعذر جلب قائمة الخصومات',
          subtitle: controller.discountsError.value,
          onRetry: () => controller.loadDiscounts(isRefresh: true),
        );
      }

      final items = controller.filteredDiscounts;

      if (items.isEmpty) {
        return Center(
          child: CustomEmptyState(
            title: 'لا توجد خصومات استثنائية مسجلة',
            subtitle: controller.searchController.text.isNotEmpty
                ? 'لم نجد أي خصم يطابق بحثك الحالي، جرّب كلمات أخرى.'
                : 'يتم حالياً تطبيق الخصم الافتراضي للباقات على كافة نقاط البيع. يمكنك تخصيص خصم استثنائي لوكيل محدد الآن.',
            actionLabel: controller.searchController.text.isNotEmpty
                ? 'مسح البحث'
                : 'تخصيص خصم جديد',
            onAction: () {
              if (controller.searchController.text.isNotEmpty) {
                controller.searchController.clear();
                controller.discounts.refresh();
              } else {
                CreateEditDiscountSheet.show(context, controller: controller);
              }
            },
          ),
        );
      }

      return RefreshIndicator(
        color: colors.primary,
        onRefresh: () => controller.loadDiscounts(isRefresh: true),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.sm,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final discount = items[index];
            return PackageDiscountCard(
              discount: discount,
              onToggleStatus: () =>
                  controller.toggleDiscountStatus(discount.discountId),
              onEdit: () => CreateEditDiscountSheet.show(
                context,
                controller: controller,
                discount: discount,
              ),
              onDelete: () => _confirmDelete(context, discount),
            );
          },
        ),
      );
    });
  }

  void _confirmDelete(
    BuildContext context,
    VoucherPackageDiscountEntity discount,
  ) async {
    final confirmed = await CustomDialog.showDanger(
      title: 'حذف الخصم المخصص',
      message:
          'هل أنت متأكد من حذف الخصم الاستثنائي لنقطة البيع على هذه الباقة؟ سيتم الرجوع للخصم الافتراضي للباقة.',
      confirmLabel: 'نعم، حذف',
      cancelLabel: 'إلغاء',
    );

    if (confirmed == true) {
      controller.deleteDiscount(discount.discountId);
    }
  }
}
