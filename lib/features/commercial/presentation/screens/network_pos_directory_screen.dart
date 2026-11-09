import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/features/commercial/presentation/controllers/commercial_directory_controller.dart';
import 'package:netsales/features/commercial/presentation/widgets/link_pos_bottom_sheet.dart';
import 'package:netsales/features/commercial/presentation/widgets/network_details_bottom_sheet.dart';
import 'package:netsales/features/commercial/presentation/widgets/network_pos_card.dart';
import 'package:netsales/features/commercial/presentation/widgets/network_pos_card_skeleton.dart';
import 'package:netsales/features/commercial/presentation/widgets/network_pos_qr_challenge_sheet.dart';
import 'package:netsales/features/commercial/presentation/widgets/network_pos_search_filter_header.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';

/// شاشة دليل نقاط البيع وإدارة روابط الشراكة بمساحة عمل الشبكة
/// مسؤوليتها: تركيب الصفحة وتنسيق المكونات وتوصيلها بالمتحكم (Page Composition)
class NetworkPosDirectoryScreen extends GetView<CommercialDirectoryController> {
  const NetworkPosDirectoryScreen({
    super.key,
    this.networkId,
    this.embedded = false,
  });

  final int? networkId;
  final bool embedded;

  void _ensureDataLoaded() {
    if (networkId == null || networkId! <= 0) return;
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

    if (networkId == null || networkId! <= 0) {
      return const CustomEmptyState(
        icon: Icons.hub_outlined,
        title: 'حدد الشبكة أولاً',
        subtitle:
            'اختر شبكة متاحة من لوحة الرئيسية لعرض نقاط البيع المرتبطة بها.',
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: embedded
          ? null
          : AppBar(
              title: const Text('دليل نقاط البيع المرتبطة'),
              centerTitle: true,
              actions: [
                CustomButton.icon(
                  icon: Icons.qr_code_2_rounded,
                  tooltip: 'دعوة ربط عبر QR',
                  onPressed: () async {
                    final netId = controller.activeNetworkId.value;
                    final net = await controller.fetchNetworkDetails(netId);
                    if (net != null) {
                      await NetworkPosQrChallengeSheet.show(
                        networkId: netId,
                        networkName: net.networkName,
                        networkPhone: net.networkPhoneNumber,
                      );
                    }
                  },
                ),
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
          if (embedded)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.cardPadding,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  const Expanded(child: Text('دليل نقاط البيع المرتبطة')),
                  CustomButton.icon(
                    icon: Icons.qr_code_2_rounded,
                    tooltip: 'دعوة ربط عبر QR',
                    onPressed: () async {
                      final netId = controller.activeNetworkId.value;
                      final network = await controller.fetchNetworkDetails(
                        netId,
                      );
                      if (network != null) {
                        await NetworkPosQrChallengeSheet.show(
                          networkId: netId,
                          networkName: network.networkName,
                          networkPhone: network.networkPhoneNumber,
                        );
                      }
                    },
                  ),
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
                  CustomButton.icon(
                    icon: Icons.add_link_rounded,
                    tooltip: 'ربط نقطة بيع',
                    onPressed: () => LinkPosBottomSheet.show(
                      networkId: controller.activeNetworkId.value,
                    ),
                  ),
                ],
              ),
            ),
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

              final displayLinks = controller.links;

              // ج. حالة القائمة الفارغة
              if (displayLinks.isEmpty) {
                return CustomEmptyState(
                  title: 'لا توجد نقاط بيع مرتبطة',
                  subtitle: 'قم بربط نقاط البيع المرخصة بشبكتك لتفعيل التوزيع بالجملة',
                  icon: Icons.storefront_outlined,
                  actionLabel: 'ربط نقطة بيع جديدة',
                  onAction: () => LinkPosBottomSheet.show(
                    networkId: controller.activeNetworkId.value,
                  ),
                );
              }

              // د. عرض قائمة البطاقات مع دعم تحميل المزيد
              final hasMore = controller.hasMoreNetworkPosLinks;
              final isLoadingMore = controller.isLoadingMore.value;

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
                  // إضافة عنصر إضافي في النهاية لعرض skeleton تحميل المزيد
                  itemCount:
                      displayLinks.length + (hasMore || isLoadingMore ? 1 : 0),
                  separatorBuilder: (context, index) => AppSpacing.vMd,
                  itemBuilder: (ctx, index) {
                    // عنصر نهاية القائمة: skeleton تحميل المزيد أو trigger
                    if (index == displayLinks.length) {
                      if (isLoadingMore) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: NetworkPosCardSkeleton(),
                        );
                      }
                      // trigger تحميل الصفحة التالية
                      if (hasMore) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          controller.loadMoreNetworkPosLinks();
                        });
                        return const SizedBox.shrink();
                      }
                    }

                    final link = displayLinks[index];
                    return NetworkPosCard(link: link);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: embedded
          ? null
          : CustomButton.primary(
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
