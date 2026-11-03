import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/presentation/controllers/commercial_directory_controller.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// شاشة استعراض الشبكات المزودة لنقطة البيع (POS Linked Networks Screen)
/// مبنية بالكامل كـ StatelessWidget وفق معايير Clean Architecture و GetX
class PosLinkedNetworksScreen extends GetView<CommercialDirectoryController> {
  const PosLinkedNetworksScreen({super.key, this.posId});

  final int? posId;

  void _ensureDataLoaded() {
    if (posId != null && posId! > 0 && controller.activePosId.value != posId) {
      controller.activePosId.value = posId!;
      controller.fetchPosNetworks(posId: posId);
    } else if (controller.links.isEmpty && !controller.isLoading.value && controller.errorMessage.value == null) {
      controller.fetchPosNetworks(posId: posId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    _ensureDataLoaded();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الشبكات المزودة المرتبطة'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. شريط البحث والفلترة العلوية
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              boxShadow: AppElevation.level1(context),
            ),
            child: Column(
              children: [
                CustomTextField(
                  controller: controller.searchController,
                  label: 'البحث عن شبكة مزودة',
                  hint: 'ابحث باسم الشبكة أو هاتفها...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: Obx(() {
                    return controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: controller.clearSearch,
                          )
                        : const SizedBox.shrink();
                  }),
                  isRequired: false,
                  onChanged: controller.setSearchQuery,
                ),

                AppSpacing.vSm,

                // شريط التبويب القطاعي لفلترة الحالة
                Obx(() {
                  final activeFilter = controller.selectedStatusFilter.value;
                  final selectedIndex = activeFilter == null
                      ? 0
                      : activeFilter
                          ? 1
                          : 2;

                  final allCount = controller.links.length;
                  final activeCount =
                      controller.links.where((l) => l.status).length;
                  final inactiveCount = allCount - activeCount;

                  return CustomSegmentedBar(
                    selectedIndex: selectedIndex,
                    onSegmentChanged: (index) {
                      if (index == 0) {
                        controller.setStatusFilter(null);
                      } else if (index == 1) {
                        controller.setStatusFilter(true);
                      } else {
                        controller.setStatusFilter(false);
                      }
                    },
                    items: [
                      CustomSegmentItem(
                        label: 'الكل',
                        count: allCount,
                        icon: Icons.list_alt_rounded,
                      ),
                      CustomSegmentItem(
                        label: 'نشطة',
                        count: activeCount,
                        icon: Icons.check_circle_rounded,
                      ),
                      CustomSegmentItem(
                        label: 'معطلة',
                        count: inactiveCount,
                        icon: Icons.cancel_rounded,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),

          // 2. المحتوى الرئيسي
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: const CustomSkeletonFeed(
                    itemCount: 4,
                    cardHeight: 110,
                  ),
                );
              }

              if (controller.errorMessage.value != null &&
                  controller.links.isEmpty) {
                return CustomErrorState(
                  title: 'تعذر جلب الشبكات المزودة',
                  subtitle: controller.errorMessage.value,
                  onRetry: () => controller.fetchPosNetworks(
                    posId: posId,
                  ),
                );
              }

              final displayLinks = controller.filteredLinks;

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
                    return _buildNetworkCard(context, link);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// بطاقة الشبكة المزودة الموحدة
  Widget _buildNetworkCard(BuildContext context, NetworkPosLinkEntity link) {
    final colors = context.colors;
    final network = link.network;

    final isActive = link.status;
    final statusColor = isActive ? colors.success : colors.error;

    return CustomInteractiveBounce(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: AppElevation.level1(context),
        ),
        child: Row(
          children: [
            // شعار أو أيقونة الشبكة
            if (network?.networkProfileLogoUrl != null &&
                network!.networkProfileLogoUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: CustomCachedImage(
                  url: network.networkProfileLogoUrl!,
                  width: 48.r,
                  height: 48.r,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.hub_rounded,
                  color: colors.secondary,
                  size: 26.r,
                ),
              ),

            AppSpacing.hMd,

            // اسم الشبكة ومعلوماتها
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    network?.networkName ?? 'مزود شبكة #${link.networkId}',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.vXxs,
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 14.r,
                        color: colors.onSurfaceVariant,
                      ),
                      AppSpacing.hXxs,
                      Text(
                        network?.networkPhoneNumber.isNotEmpty == true
                            ? network!.networkPhoneNumber
                            : 'لا يوجد هاتف',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (network?.networkAddress != null &&
                      network!.networkAddress!.isNotEmpty) ...[
                    AppSpacing.vXxs,
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14.r,
                          color: colors.onSurfaceVariant,
                        ),
                        AppSpacing.hXxs,
                        Expanded(
                          child: Text(
                            network.networkAddress!,
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            AppSpacing.hSm,

            // شارة حالة الشراكة
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7.r,
                    height: 7.r,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  AppSpacing.hXxs,
                  Text(
                    isActive ? 'نشط' : 'معطل',
                    style: AppTypography.labelSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
