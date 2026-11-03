import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/commercial/presentation/controllers/commercial_directory_controller.dart';
import 'package:netsales/features/commercial/presentation/widgets/pos_details_bottom_sheet.dart';
import 'package:netsales/features/commercial/presentation/widgets/pos_linked_network_card.dart';
import 'package:netsales/features/commercial/presentation/widgets/pos_linked_networks_search_filter_header.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';

/// شاشة استعراض الشبكات المزودة لنقطة البيع (POS Linked Networks Screen)
/// مسؤوليتها: تركيب الصفحة وتنسيق المكونات وتوصيلها بالمتحكم (Page Composition)
class PosLinkedNetworksScreen extends GetView<CommercialDirectoryController> {
  const PosLinkedNetworksScreen({super.key, this.posId});

  final int? posId;

  void _ensureDataLoaded() {
    if (posId != null && posId! > 0 && controller.activePosId.value != posId) {
      controller.activePosId.value = posId!;
      controller.fetchPosNetworks(posId: posId);
    } else if (controller.links.isEmpty &&
        !controller.isLoading.value &&
        controller.errorMessage.value == null) {
      controller.fetchPosNetworks(posId: posId);
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureDataLoaded();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الشبكات المزودة المرتبطة'),
        centerTitle: true,
        actions: [
          CustomButton.icon(
            icon: Icons.storefront_outlined,
            tooltip: 'بيانات نقطة البيع',
            onPressed: () async {
              final pos = await controller.fetchPosDetails(
                controller.activePosId.value,
              );
              if (pos != null) {
                await PosDetailsBottomSheet.show(pos: pos, canEdit: true);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. شريط البحث والفلترة المفصول (Feature Widget)
          const PosLinkedNetworksSearchFilterHeader(),

          // 2. قائمة الشبكات المزودة وحالات التحميل والخطأ والفراغ
          Expanded(
            child: Obx(() {
              // أ. حالة التحميل الأولي مع الوميض الشيمر
              if (controller.isLoading.value) {
                return Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: const CustomSkeletonFeed(
                    itemCount: 4,
                    cardHeight: 110,
                  ),
                );
              }

              // ب. حالة الخطأ مع خيار إعادة المحاولة
              if (controller.errorMessage.value != null &&
                  controller.links.isEmpty) {
                return CustomErrorState(
                  title: 'تعذر جلب الشبكات المزودة',
                  subtitle: controller.errorMessage.value,
                  onRetry: () => controller.fetchPosNetworks(posId: posId),
                );
              }

              final displayLinks = controller.filteredLinks;

              // ج. حالة القائمة الفارغة
              if (displayLinks.isEmpty) {
                return CustomEmptyState(
                  title: controller.links.isEmpty
                      ? 'لا توجد شبكات مزودة مرتبطة'
                      : 'لا توجد نتائج مطابقة للبحث',
                  subtitle: controller.links.isEmpty
                      ? 'يجب أن يقوم مزود الشبكة بربط نقطة البيع الخاصة بك أولاً لتتمكن من طلب باقات الكروت بالجملة'
                      : 'جرب استخدام كلمات بحث مختلفة',
                  icon: Icons.hub_outlined,
                );
              }

              // د. عرض قائمة بطاقات الشبكات المفصولة
              return RefreshIndicator.adaptive(
                onRefresh: () => controller.fetchPosNetworks(
                  posId: posId,
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
                    return PosLinkedNetworkCard(link: link);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
