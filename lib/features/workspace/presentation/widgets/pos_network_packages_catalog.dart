import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_card.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// كتالوج باقات الشبكة وأسعار الجملة المعتمدة حقيقياً من الـ API (PosNetworkPackagesCatalog)
class PosNetworkPackagesCatalog extends StatelessWidget {
  final PosWorkspaceController controller;

  const PosNetworkPackagesCatalog({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingPackages.value && controller.networkPackages.isEmpty) {
        return const CustomSkeletonCard(height: 160);
      }

      final packages = controller.networkPackages;

      if (packages.isEmpty) {
        return CustomSurfaceCard(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              AppSpacing.vMd,
              const CustomEmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'لا توجد باقات معتمدة حالياً',
                subtitle: 'لم يقم مزود الشبكة بنشر أي باقات كروت نشطة حتى الآن.',
              ),
            ],
          ),
        );
      }

      return CustomSurfaceCard(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            AppSpacing.vMd,
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
                mainAxisExtent: 110.h,
              ),
              itemCount: packages.length > 4 ? 4 : packages.length,
              itemBuilder: (context, index) {
                return PackageWholesaleCard(package: packages[index]);
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'باقات الشبكة وأسعار الجملة المعتمدة',
                style: AppTypography.titleMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'أسعار الشراء ونسب الخصم المعتمدة سيادياً من الخادم لنقطة البيع',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        CustomButton.outline(
          text: 'طلب توريد',
          prefix: Icons.add_shopping_cart_rounded,
          onPressed: () => Get.toNamed<void>(AppRoutes.newProcurementOrder),
        ),
      ],
    );
  }
}

/// بطاقة الباقة بأسعار الجملة الحقيقية من الـ API (PackageWholesaleCard)
class PackageWholesaleCard extends StatelessWidget {
  final PackageEntity package;

  const PackageWholesaleCard({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final discountPercent = package.packageDefaultCashDiscount > 0
        ? '${package.packageDefaultCashDiscount.toStringAsFixed(0)}%'
        : '';

    final specs = [
      if (package.uptimeDisplay.isNotEmpty) package.uptimeDisplay,
      if (package.validityDisplay.isNotEmpty) package.validityDisplay,
    ].join(' • ');

    return CustomInteractiveBounce(
      onTap: () {
        Get.toNamed<void>(
          AppRoutes.newProcurementOrder,
          arguments: {'package_id': package.packageId},
        );
      },
      child: Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    package.packageName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                if (discountPercent.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'خصم $discountPercent',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 9.sp,
                      ),
                    ),
                  ),
              ],
            ),
            if (specs.isNotEmpty)
              Text(
                specs,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelSmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 10.sp,
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سعر التوريد',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 9.sp,
                      ),
                    ),
                    Text(
                      AmountFormatter.formatValue(package.effectiveCashPrice),
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'البيع الرسمي',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 9.sp,
                      ),
                    ),
                    Text(
                      AmountFormatter.formatValue(package.packageVoucherPrice),
                      style: AppTypography.bodySmall.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: colors.onSurfaceVariant,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
