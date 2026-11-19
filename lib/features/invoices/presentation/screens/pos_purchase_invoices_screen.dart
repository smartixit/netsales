import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/invoices/presentation/controllers/pos_invoices_controller.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_card.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoices_search_filter_header.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoices_summary_strip.dart';
import 'package:netsales/features/invoices/presentation/widgets/pos_embedded_invoices_header.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة قائمة فواتير المشتريات لنقطة البيع (POS Purchase Invoices Screen)
class PosPurchaseInvoicesScreen extends GetView<PosInvoicesController> {
  const PosPurchaseInvoicesScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final topPadding = embedded
        ? MediaQuery.paddingOf(context).top + 20.h
        : AppSpacing.md;
    final bottomPadding = embedded
        ? 115.h + MediaQuery.paddingOf(context).bottom
        : MediaQuery.paddingOf(context).bottom + AppSpacing.xl;
    final horizontalPadding = AppBreakpoints.screenMargin(context);

    final content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: RefreshIndicator.adaptive(
          edgeOffset: embedded ? topPadding - 14.h : 0.0,
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
              key: const PageStorageKey<String>('pos-purchase-invoices-scroll'),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    topPadding,
                    horizontalPadding,
                    0,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (embedded)
                        PosEmbeddedInvoicesHeader(controller: controller),

                      // 1. الترويسة القيادية لفواتير المشتريات
                      const CustomPageHeroCard(
                        title: 'فواتير المشتريات',
                        subtitle:
                            'متابعة فواتير كروت الشبكات، تفاصيل السداد المالي، وتفاصيل الكميات المعتمدة فورياً.',
                        icon: Icons.receipt_long_rounded,
                      ),

                      // 2. شريط ملخص المؤشرات
                      Obx(
                        () => InvoicesSummaryStrip(
                          isNetworkView: false,
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
                          searchHint: 'بحث برقم الفاتورة، UUID، أو اسم الشبكة المزودة...',
                        ),
                      ),
                    ]),
                  ),
                ),

                // 4. محتوى القائمة
                Obx(() {
                  if (controller.isLoading.value &&
                      controller.invoices.isEmpty) {
                    return SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        AppSpacing.xs,
                        horizontalPadding,
                        bottomPadding,
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
                        bottomPadding,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: CustomErrorState(
                          title: 'تعذر تحميل فواتير المشتريات',
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
                        bottomPadding,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: CustomEmptyState(
                          title: 'لا توجد فواتير مشتريات',
                          subtitle: controller.searchQuery.value.isNotEmpty ||
                                  controller.statusFilter.value != null
                              ? 'لم يتم العثور على أي فاتورة تطابق خيارات التصفية.'
                              : 'لم تسجل أي فواتير مشتريات لصالح نقطة البيع بعد.',
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
                      bottomPadding,
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
                                isNetworkView: false,
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
    );

    if (embedded) return content;

    return CustomAppScaffold(
      appBarTitle: 'فواتير المشتريات',
      body: content,
    );
  }
}
