import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/presentation/controllers/commercial_directory_controller.dart';
import 'package:netsales/features/commercial/presentation/screens/link_pos_dialog.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/toasts/custom_toast.dart';

/// شاشة دليل نقاط البيع وإدارة روابط الشراكة بمساحة عمل الشبكة
class NetworkPosDirectoryScreen extends StatefulWidget {
  const NetworkPosDirectoryScreen({super.key, this.networkId});

  final int? networkId;

  @override
  State<NetworkPosDirectoryScreen> createState() =>
      _NetworkPosDirectoryScreenState();
}

class _NetworkPosDirectoryScreenState extends State<NetworkPosDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final CommercialDirectoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<CommercialDirectoryController>();
    if (widget.networkId != null && widget.networkId! > 0) {
      _controller.activeNetworkId.value = widget.networkId!;
    }
    _controller.fetchNetworkPosLinks(networkId: widget.networkId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // 1. شريط البحث والفلترة العلوية الموحدة
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
                // حقل البحث الموحد
                CustomTextField(
                  controller: _searchController,
                  label: 'البحث عن نقطة بيع',
                  hint: 'ابحث بالاسم، المعرف UUID، أو رقم الهاتف...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: Obx(() {
                    return _controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              _controller.setSearchQuery('');
                            },
                          )
                        : const SizedBox.shrink();
                  }),
                  isRequired: false,
                  onChanged: _controller.setSearchQuery,
                ),

                AppSpacing.vSm,

                // شريط التبويب القطاعي لفلترة الحالة
                Obx(() {
                  final activeFilter = _controller.selectedStatusFilter.value;
                  final selectedIndex = activeFilter == null
                      ? 0
                      : activeFilter
                          ? 1
                          : 2;

                  final allCount = _controller.links.length;
                  final activeCount =
                      _controller.links.where((l) => l.status).length;
                  final inactiveCount = allCount - activeCount;

                  return CustomSegmentedBar(
                    selectedIndex: selectedIndex,
                    onSegmentChanged: (index) {
                      if (index == 0) {
                        _controller.setStatusFilter(null);
                      } else if (index == 1) {
                        _controller.setStatusFilter(true);
                      } else {
                        _controller.setStatusFilter(false);
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

          // 2. المحتوى الرئيسي مع معالجة حالات التحميل والخطأ والفراغ
          Expanded(
            child: Obx(() {
              // أ. حالة التحميل الأولي مع الوميض الشيمر (Shimmer Skeleton)
              if (_controller.isLoading.value) {
                return Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: const CustomSkeletonFeed(
                    itemCount: 4,
                    cardHeight: 130,
                  ),
                );
              }

              // ب. حالة الخطأ مع خيار إعادة المحاولة
              if (_controller.errorMessage.value != null &&
                  _controller.links.isEmpty) {
                return CustomErrorState(
                  title: 'تعذر جلب نقاط البيع',
                  subtitle: _controller.errorMessage.value,
                  onRetry: () => _controller.fetchNetworkPosLinks(
                    networkId: widget.networkId,
                  ),
                );
              }

              final displayLinks = _controller.filteredLinks;

              // ج. حالة القائمة الفارغة
              if (displayLinks.isEmpty) {
                return CustomEmptyState(
                  title: _controller.links.isEmpty
                      ? 'لا توجد نقاط بيع مرتبطة'
                      : 'لا توجد نتائج مطابقة لبحثك',
                  subtitle: _controller.links.isEmpty
                      ? 'قم بربط نقاط البيع المرخصة بشبكتك لتفعيل التوزيع بالجملة'
                      : 'جرب استخدام كلمات بحث مختلفة أو إلغاء فلتر التفعيل',
                  icon: Icons.storefront_outlined,
                  actionLabel: 'ربط نقطة بيع جديدة',
                  onAction: () => LinkPosDialog.show(
                    networkId: _controller.activeNetworkId.value,
                  ),
                );
              }

              // د. عرض قائمة نقاط البيع
              return RefreshIndicator.adaptive(
                onRefresh: () => _controller.fetchNetworkPosLinks(
                  networkId: widget.networkId,
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
                    return _buildPosCard(context, link);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 3,
        icon: const Icon(Icons.add_link_rounded),
        label: Text(
          'ربط نقطة بيع',
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onPrimary,
          ),
        ),
        onPressed: () => LinkPosDialog.show(
          networkId: _controller.activeNetworkId.value,
        ),
      ),
    );
  }

  /// بطاقة نقطة البيع التفاعلية الموحدة
  Widget _buildPosCard(BuildContext context, NetworkPosLinkEntity link) {
    final colors = context.colors;
    final pos = link.pos;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ترويسة البطاقة: الشعار، الاسم، وشارة الحالة
            Row(
              children: [
                // صورة أو أيقونة نقطة البيع
                if (pos?.posProfileLogoUrl != null &&
                    pos!.posProfileLogoUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: CustomCachedImage(
                      url: pos.posProfileLogoUrl!,
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
                      color: colors.primaryContainer.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      color: colors.primary,
                      size: 26.r,
                    ),
                  ),

                AppSpacing.hMd,

                // اسم نقطة البيع ورقم الهاتف
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pos?.posName ?? 'نقطة بيع #${link.posId}',
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
                            pos?.posPhoneNumber.isNotEmpty == true
                                ? pos!.posPhoneNumber
                                : 'لا يوجد هاتف',
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // شارة الحالة (Badge)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
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

            AppSpacing.vSm,

            // المعرف الفريد UUID مع زر النسخ
            if (pos?.posUuid.isNotEmpty == true)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.fingerprint_rounded,
                      size: 16.r,
                      color: colors.onSurfaceVariant,
                    ),
                    AppSpacing.hXs,
                    Expanded(
                      child: Text(
                        pos!.posUuid,
                        style: AppTypography.labelSmall.copyWith(
                          fontFamily: 'monospace',
                          color: colors.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: pos.posUuid));
                        CustomToast.show(
                          message: 'تم نسخ معرف نقطة البيع',
                          icon: Icons.copy_rounded,
                        );
                      },
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xxs),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 16.r,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            AppSpacing.vMd,

            // أزرار التحكم والإجراءات الموحدة
            Row(
              children: [
                // زر تبديل الحالة الموحد
                Expanded(
                  child: CustomButton.outline(
                    text: isActive ? 'تعطيل الارتباط' : 'تفعيل الارتباط',
                    icon: isActive
                        ? Icons.pause_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    onPressed: () =>
                        _controller.toggleLinkStatus(link.networkPosId),
                  ),
                ),

                AppSpacing.hSm,

                // زر فك الارتباط الموحد مع حوار التأكيد التحذيري
                CustomButton.danger(
                  text: 'فك الارتباط',
                  icon: Icons.link_off_rounded,
                  onPressed: () {
                    CustomDialog.danger(
                      title: 'فك ارتباط نقطة البيع',
                      message:
                          'هل أنت متأكد من رغبتك في فك ارتباط "${pos?.posName ?? 'نقطة البيع'}" بالشبكة؟ سيؤدي ذلك لتعليق طلبات التوريد بالجملة.',
                      confirmLabel: 'تأكيد فك الارتباط',
                      cancelLabel: 'إلغاء',
                      onConfirm: () =>
                          _controller.unlinkPos(link.networkPosId),
                    ).showDialog(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
