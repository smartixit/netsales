import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/controllers/network_procurement_review_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/modification_sheet/network_request_catalog_package_row.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';

/// قسم استعراض كتالوج الشبكة وإضافة باقات لمسودة الطلب
class NetworkRequestCatalogSection
    extends GetView<NetworkProcurementReviewController> {
  const NetworkRequestCatalogSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final available = controller.unselectedAvailablePackages;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: colors.secondary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.add_shopping_cart_rounded,
                  size: 16.r,
                  color: colors.secondary,
                ),
              ),
              AppSpacing.hXs,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إضافة باقة من كتالوج الشبكة',
                      style: AppTypography.titleSmall.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'باقات متوفرة في كتالوج الشبكة يمكن تضمينها في الطلب.',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          if (controller.isLoadingPackages.value)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: CustomStateView.loading(
                presentation: CustomStatePresentation.skeletonOnly,
                skeleton: const CustomStateSkeleton(
                  layout: CustomStateSkeletonLayout.cards,
                  itemCount: 2,
                  showCardSurface: true,
                ),
              ),
            )
          else if (available.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: .35),
                ),
              ),
              child: Text(
                'تمت إضافة جميع باقات الكتالوج المتاحة إلى مسودة الطلب.',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...available.map(
              (pkg) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xs),
                child: NetworkRequestCatalogPackageRow(package: pkg),
              ),
            ),
        ],
      );
    });
  }
}
