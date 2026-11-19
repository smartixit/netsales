import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/invoices/presentation/controllers/network_invoices_controller.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_card.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoices_search_filter_header.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoices_summary_strip.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

/// شاشة استعراض وإدارة فواتير مبيعات الجملة لمشغل الشبكة (Network Wholesale Invoices Screen)
class NetworkWholesaleInvoicesScreen
    extends GetView<NetworkInvoicesController> {
  const NetworkWholesaleInvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final horizontalPadding = AppBreakpoints.screenMargin(context);

    return CustomAppScaffold(
      appBarTitle: 'فواتير مبيعات الجملة',
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: RefreshIndicator.adaptive(
            displacement: 36.h,
            color: colors.primary,
            backgroundColor: colors.surface,
            strokeWidth: 2.5,
            onRefresh: controller.refreshInvoices,
            child: NotificationListener<ScrollNotification>(
              onNotification: (scroll) {
                if (scroll.depth == 0 &&
                    scroll.metrics.extentAfter <= 220 &&
                    controller.hasMore) {
                  controller.loadMoreInvoices();
                }
                return false;
              },
              child: CustomScrollView(
                key: const PageStorageKey<String>('network-wholesale-invoices-scroll'),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      AppSpacing.md,
                      horizontalPadding,
                      0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // 1. الترويسة القيادية لفواتير مبيعات الجملة
                        CustomPageHeroCard(
                          title: 'فواتير مبيعات الجملة',
                          subtitle:
                              'متابعة فواتير كروت الشبكة، حالات السداد المالي، وتفاصيل الكميات المعتمدة فورياً.',
                          icon: Icons.receipt_long_rounded,
                          action: controller.canCreateInvoice
                              ? CustomButton.primary(
                                  text: 'فاتورة جديدة +',
                                  icon: Icons.add_rounded,
                                  shape: AppButtonShape.pill,
                                  size: AppButtonSize.small,
                                  onPressed: controller.navigateToCreateInvoice,
                                )
                              : null,
                        ),

                        // 2. شريط ملخص المؤشرات
                        Obx(
                          () => InvoicesSummaryStrip(
                            isNetworkView: true,
                            totalCount: controller.totalInvoicesCount,
                            paidCount: controller.paidInvoicesCount,
                            partiallyPaidCount:
                                controller.partiallyPaidInvoicesCount,
                            unpaidCount: controller.unpaidInvoicesCount,
                            isLoading: controller.isLoading.value &&
                                controller.invoices.isEmpty,
                            selectedStatus: controller.statusFilter.value,
                            onStatusTap: controller.setStatusFilter,
                          ),
                        ),

                        // 3. شريط البحث والفلترة السريعة
                        Obx(
                          () => InvoicesSearchFilterHeader(
                            searchController: controller.searchController,
                            searchQuery: controller.searchQuery.value,
                            selectedStatus: controller.statusFilter.value,
                            onStatusChanged: controller.setStatusFilter,
                            onClearSearch: controller.searchController.clear,
                            searchHint: 'بحث برقم الفاتورة، UUID، أو اسم نقطة البيع...',
                          ),
                        ),

                        // 4. منتقي الشبكات في حالة وجود أكثر من شبكة للمشغل
                        Obx(() {
                          final networks = controller.authorizedNetworks;
                          if (networks.length <= 1) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: EdgeInsets.only(bottom: AppSpacing.sm),
                            child: CustomDropdown<int>(
                              label: 'تصفية بحسب الشبكة',
                              searchEnabled: false,
                              rxValue: controller.selectedNetworkId,
                              items: networks.map((net) {
                                return DropdownItem<int>(
                                  value: net.networkId,
                                  child: Text(net.networkName),
                                );
                              }).toList(),
                              onChanged: controller.onNetworkFilterChanged,
                            ),
                          );
                        }),
                      ]),
                    ),
                  ),

                  // 5. محتوى القائمة
                  Obx(() {
                    if (controller.isLoading.value &&
                        controller.invoices.isEmpty) {
                      return SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          AppSpacing.xs,
                          horizontalPadding,
                          AppSpacing.xl,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: CustomStateView.loading(
                            presentation: CustomStatePresentation.skeletonOnly,
                            skeleton: CustomStateSkeleton(
                              layout: CustomStateSkeletonLayout.list,
                              itemCount: 3,
                              cardHeight: 160.h,
                              maxColumns: 1,
                            ),
                          ),
                        ),
                      );
                    }

                    if (controller.errorMessage.value != null &&
                        controller.invoices.isEmpty) {
                      return SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          AppSpacing.md,
                          horizontalPadding,
                          AppSpacing.xl,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: CustomErrorState(
                            title: 'تعذر تحميل فواتير المبيعات',
                            subtitle: controller.errorMessage.value,
                            onRetry: () => controller.loadInvoices(isRefresh: true),
                          ),
                        ),
                      );
                    }

                    if (controller.invoices.isEmpty) {
                      return SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          AppSpacing.md,
                          horizontalPadding,
                          AppSpacing.xl,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: CustomEmptyState(
                            title: 'لا توجد فواتير مبيعات',
                            subtitle: controller.searchQuery.value.isNotEmpty ||
                                    controller.statusFilter.value != null
                              ? 'لم يتم العثور على أي فاتورة تطابق خيارات التصفية المحددة.'
                              : 'لم تصدر أي فواتير مبيعات جملة حتى الآن.',
                            actionLabel: controller.searchQuery.value.isNotEmpty ||
                                    controller.statusFilter.value != null
                              ? 'إعادة التعيين'
                              : null,
                            onAction: controller.searchQuery.value.isNotEmpty ||
                                    controller.statusFilter.value != null
                              ? controller.resetFilters
                              : null,
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        AppSpacing.xs,
                        horizontalPadding,
                        AppSpacing.xl,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == controller.invoices.length) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                child: CustomStateView.loading(
                                  presentation:
                                      CustomStatePresentation.skeletonOnly,
                                  skeleton: CustomStateSkeleton(
                                    layout: CustomStateSkeletonLayout.list,
                                    itemCount: 1,
                                    cardHeight: 120.h,
                                    maxColumns: 1,
                                  ),
                                ),
                              );
                            }

                            final invoice = controller.invoices[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: AppSpacing.sm),
                              child: Obx(
                                () => InvoiceCard(
                                  invoice: invoice,
                                  isNetworkView: true,
                                  isExpanded:
                                      controller.expandedInvoiceId.value ==
                                          invoice.invoiceId,
                                  onToggleExpansion: () => controller
                                      .toggleInvoiceExpansion(invoice.invoiceId),
                                  onTap: () =>
                                      controller.openInvoiceDetails(invoice),
                                ),
                              ),
                            );
                          },
                          childCount: controller.invoices.length +
                              (controller.hasMore ? 1 : 0),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
