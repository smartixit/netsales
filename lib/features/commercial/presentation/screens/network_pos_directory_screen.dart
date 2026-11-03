import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/features/commercial/presentation/controllers/commercial_directory_controller.dart';
import 'package:netsales/features/commercial/presentation/widgets/link_pos_bottom_sheet.dart';
import 'package:netsales/features/commercial/presentation/widgets/network_details_bottom_sheet.dart';
import 'package:netsales/features/commercial/presentation/widgets/network_pos_card.dart';
import 'package:netsales/features/commercial/presentation/widgets/network_pos_search_filter_header.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';

/// شاشة دليل نقاط البيع وإدارة روابط الشراكة بمساحة عمل الشبكة
/// مسؤوليتها: تركيب الصفحة وتنسيق المكونات وتوصيلها بالمتحكم (Page Composition)
class NetworkPosDirectoryScreen extends GetView<CommercialDirectoryController> {
  const NetworkPosDirectoryScreen({super.key, this.networkId});

  final int? networkId;

  void _ensureDataLoaded() {
    if (networkId != null &&
        networkId! > 0 &&
        controller.activeNetworkId.value != networkId) {
      controller.activeNetworkId.value = networkId!;
      controller.fetchNetworkPosLinks(networkId: networkId);
    } else if (controller.links.isEmpty &&
        !controller.isLoading.value &&
        controller.errorMessage.value == null) {
      controller.fetchNetworkPosLinks(networkId: networkId);
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureDataLoaded();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('دليل نقاط البيع المرتبطة'),
        centerTitle: true,
        actions: [
          CustomButton.icon(
            icon: Icons.business_outlined,
            tooltip: 'بيانات الشبكة',
            onPressed: () async {
              final network = await controller.fetchNetworkDetails(
                controller.activeNetworkId.value,
              );
              if (network != null) {
                await NetworkDetailsBottomSheet.show(
                  network: network,
                  canEdit: true,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. شريط البحث والفلترة المفصول (Feature Widget)
          const NetworkPosSearchFilterHeader(),

          // 2. قائمة نقاط البيع وحالات التحميل والخطأ والفراغ
          Expanded(
            child: Obx(() {
              // أ. حالة التحميل الأولي مع الوميض الشيمر
              if (controller.isLoading.value) {
                return Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: const CustomSkeletonFeed(
                    itemCount: 4,
                    cardHeight: 130,
                  ),
                );
              }

              // ب. حالة الخطأ مع خيار إعادة المحاولة
              if (controller.errorMessage.value != null &&
                  controller.links.isEmpty) {
                return CustomErrorState(
                  title: 'تعذر جلب نقاط البيع',
                  subtitle: controller.errorMessage.value,
                  onRetry: () =>
                      controller.fetchNetworkPosLinks(networkId: networkId),
                );
              }

              final displayLinks = controller.filteredLinks;

              // ج. حالة القائمة الفارغة
              if (displayLinks.isEmpty) {
                return CustomEmptyState(
                  title: controller.links.isEmpty
                      ? 'لا توجد نقاط بيع مرتبطة'
                      : 'لا توجد نتائج مطابقة لبحثك',
                  subtitle: controller.links.isEmpty
                      ? 'قم بربط نقاط البيع المرخصة بشبكتك لتفعيل التوزيع بالجملة'
                      : 'جرب استخدام كلمات بحث مختلفة أو إلغاء فلتر التفعيل',
                  icon: Icons.storefront_outlined,
                  actionLabel: 'ربط نقطة بيع جديدة',
                  onAction: () => LinkPosBottomSheet.show(
                    networkId: controller.activeNetworkId.value,
                  ),
                );
              }

              // د. عرض قائمة البطاقات المفصولة
              return RefreshIndicator.adaptive(
                onRefresh: () => controller.fetchNetworkPosLinks(
                  networkId: networkId,
                  showLoading: false,
                ),
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  itemCount: displayLinks.length,
                  separatorBuilder: (context, index) => AppSpacing.vMd,
                  itemBuilder: (ctx, index) {
                    final link = displayLinks[index];
                    return NetworkPosCard(link: link);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: CustomButton.primary(
        text: 'ربط نقطة بيع',
        icon: Icons.add_link_rounded,
        shape: AppButtonShape.pill,
        size: AppButtonSize.medium,
        shadow: AppElevation.level4(context),
        onPressed: () => LinkPosBottomSheet.show(
          networkId: controller.activeNetworkId.value,
        ),
      ),
    );
  }
}
