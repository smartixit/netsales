import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/packages/presentation/controllers/packages_controller.dart';
import 'package:netsales/features/packages/presentation/widgets/create_edit_discount_sheet.dart';
import 'package:netsales/features/packages/presentation/widgets/create_edit_package_sheet.dart';
import 'package:netsales/features/packages/presentation/widgets/package_discounts_feed.dart';
import 'package:netsales/features/packages/presentation/widgets/packages_kpi_summary_strip.dart';
import 'package:netsales/features/packages/presentation/widgets/packages_search_and_filter_bar.dart';
import 'package:netsales/features/packages/presentation/widgets/packages_segmented_header.dart';
import 'package:netsales/features/packages/presentation/widgets/voucher_packages_feed.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// ============================================================================
/// شاشة مركز باقات الكروت والخصومات المخصصة (VoucherPackagesHubScreen)
/// ============================================================================
/// مجمّع تركيبي رشيق (Lean Composite Assembler) يلتزم الصرامة المعمارية:
/// - صفر دوال مساعدة محلية (_build*).
/// - معمارية تجميعية للمكونات المستقلة.
/// - تفاعل فوري دون احتكاك وفق المبدأ الحاكم للنظام.
class VoucherPackagesHubScreen extends GetView<PackagesController> {
  const VoucherPackagesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppScaffold(
      showBackButton: true,
      appBarTitle: 'باقات الكروت والأسعار',
      appBarSubtitle: 'إدارة فئات الكروت وتخصيص هوامش ربح الوكلاء',
      centerTitle: false,
      actions: [
        CustomButton.icon(
          icon: Icons.refresh_rounded,
          dimension: 40.r,
          iconSize: 20.r,
          backgroundColor: Colors.transparent,
          tooltip: 'تحديث البيانات',
          onPressed: () {
            if (controller.activeSegmentIndex.value == 0) {
              controller.loadPackages(isRefresh: true);
            } else {
              controller.loadDiscounts(isRefresh: true);
            }
            controller.loadPosList();
          },
        ),
      ],
      body: Column(
        children: [
          AppSpacing.vXs,
          // ── 1. شريط التبديل القطاعي الموحد ──
          PackagesSegmentedHeader(controller: controller),
          AppSpacing.vXs,

          // ── 2. شريط مؤشرات الأداء الحيوية الفورية ──
          PackagesKpiSummaryStrip(controller: controller),
          AppSpacing.vXs,

          // ── 3. شريط البحث والتصفية الموحد ──
          PackagesSearchAndFilterBar(controller: controller),
          AppSpacing.vXs,

          // ── 4. قائمة التغذية التفاعلية ──
          Expanded(
            child: Obx(
              () => controller.activeSegmentIndex.value == 0
                  ? VoucherPackagesFeed(controller: controller)
                  : PackageDiscountsFeed(controller: controller),
            ),
          ),
        ],
      ),
      floatingActionButton:
          PermissionService.to.can(AppPermissions.voucherPackagesCreate)
          ? Obx(
              () => CustomButton.floating(
                icon: Icons.add_rounded,
                tooltip: controller.activeSegmentIndex.value == 0
                    ? 'إنشاء باقة كروت جديدة'
                    : 'تخصيص خصم استثنائي لوكيل',
                onPressed: () {
                  if (controller.activeSegmentIndex.value == 0) {
                    CreateEditPackageSheet.show(
                      context,
                      controller: controller,
                    );
                  } else {
                    CreateEditDiscountSheet.show(
                      context,
                      controller: controller,
                    );
                  }
                },
              ),
            )
          : null,
    );
  }
}
