import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_active_supply_order_tracker.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_network_carousel_card.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_network_packages_catalog.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_quick_action_card.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_recent_transactions_section.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_selected_network_financial_summary.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_welcome_header.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_card.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/carousels/custom_carousel_slider.dart';

/// الشاشة الرئيسية لمساحة عمل نقطة البيع (PosHomeDashboard - Pure API-Driven Clean Architecture)
class PosHomeDashboard extends StatelessWidget {
  const PosHomeDashboard({super.key, required this.controller});
  final PosWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return RefreshIndicator.adaptive(
      onRefresh: controller.loadWorkspace,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          AppBreakpoints.screenMargin(context),
          MediaQuery.paddingOf(context).top + 20.h,
          AppBreakpoints.screenMargin(context),
          AppSpacing.xxxl,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Obx(() {
              if (controller.isLoadingPos.value) {
                return const Column(
                  children: [
                    CustomSkeletonCard(height: 126),
                    SizedBox(height: 20),
                    CustomSkeletonCard(height: 210),
                    SizedBox(height: 16),
                    CustomSkeletonCard(height: 156),
                  ],
                );
              }
              if (controller.posError.value != null) {
                return CustomErrorState.boxed(
                  title: 'تعذر تحميل نقاط البيع',
                  subtitle: 'تحقق من الاتصال ثم أعد المحاولة.',
                  onRetry: controller.loadPosTenants,
                );
              }
              if (controller.activePos.value == null) {
                return CustomEmptyState.boxed(
                  title: controller.availablePos.isEmpty
                      ? 'لا توجد نقطة بيع مرتبطة بحسابك'
                      : 'اختر نقطة البيع',
                  subtitle: controller.availablePos.isEmpty
                      ? 'لا توجد نقطة بيع متاحة حاليًا لهذا الحساب.'
                      : 'لديك أكثر من نقطة بيع. اختر الكيان الذي تريد إدارته.',
                  icon: Icons.storefront_rounded,
                  animationPath: null,
                  customAction: controller.availablePos.isEmpty
                      ? null
                      : Wrap(
                          spacing: AppSpacing.sm,
                          children: controller.availablePos.map((pos) {
                            return CustomButton.outline(
                              text: pos.posName,
                              onPressed: () => controller.selectPos(pos),
                            );
                          }).toList(),
                        ),
                );
              }

              final activePos = controller.activePos.value!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PosWelcomeHeader(controller: controller),
                  AppSpacing.vXl,
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'نقطة البيع النشطة',
                              style: AppTypography.bodySmall.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              activePos.posName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.titleMedium.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (controller.availablePos.length > 1)
                        CustomButton.outline(
                          text: 'تبديل',
                          prefix: Icons.swap_horiz_rounded,
                          onPressed: () => _showPosPicker(context),
                        ),
                    ],
                  ),
                  AppSpacing.vXl,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'شبكاتك المرتبطة',
                              style: AppTypography.titleLarge.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              'اسحب لاستعراض حساباتك ومحافظك لدى كل شبكة',
                              style: AppTypography.bodySmall.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (controller.networkLinks.isNotEmpty)
                        Text(
                          '${controller.networkLinks.length}${controller.hasMoreNetworks.value ? '+' : ''} شبكة',
                          style: AppTypography.labelMedium.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  AppSpacing.vMd,
                  if (controller.isLoadingNetworks.value)
                    const CustomSkeletonCard(height: 190)
                  else if (controller.networksError.value != null)
                    CustomErrorState.boxed(
                      title: 'تعذر تحميل الشبكات',
                      subtitle: 'لم نتمكن من جلب علاقات نقطة البيع.',
                      onRetry: controller.retryNetworks,
                    )
                  else if (controller.networkLinks.isEmpty)
                    const CustomEmptyState.boxed(
                      title: 'لا توجد شبكات مرتبطة',
                      subtitle: 'ستظهر هنا الشبكات التي ترتبط بها نقطة البيع.',
                      icon: Icons.hub_outlined,
                      animationPath: null,
                    )
                  else
                    CustomCarouselSlider<NetworkPosLinkEntity>(
                      items: controller.networkLinks,
                      currentIndex: controller.currentNetworkIndex.value,
                      height: 205,
                      viewportFraction: 0.88,
                      itemBuilder: (context, link, index) =>
                          PosNetworkCarouselCard(
                            link: link,
                            isSelected:
                                controller
                                    .selectedNetworkLink
                                    .value
                                    ?.networkId ==
                                link.networkId,
                            wallet:
                                controller
                                        .selectedNetworkLink
                                        .value
                                        ?.networkId ==
                                    link.networkId
                                ? controller.selectedWallet.value
                                : null,
                            onTap: () => controller.onNetworkPageChanged(index),
                          ),
                      onPageChanged: controller.onNetworkPageChanged,
                    ),
                  AppSpacing.vXl,
                  if (controller.selectedNetworkLink.value != null) ...[
                    PosSelectedNetworkFinancialSummary(
                      networkName:
                          controller
                              .selectedNetworkLink
                              .value!
                              .network
                              ?.networkName ??
                          'شبكة #${controller.selectedNetworkLink.value!.networkId}',
                      wallet: controller.selectedWallet.value,
                      isLoading: controller.isLoadingWallet.value,
                      error: controller.walletError.value,
                      onRetry: () => controller.selectNetwork(
                        controller.selectedNetworkLink.value!,
                        index: controller.currentNetworkIndex.value,
                      ),
                      onOpenAccount: () => Get.toNamed<void>(
                        AppRoutes.posWalletStatement,
                        arguments: {
                          'pos_id': activePos.posId,
                          'network_id':
                              controller.selectedNetworkLink.value!.networkId,
                        },
                      ),
                    ),
                    AppSpacing.vXl,
                  ],

                  // قسم آخر العمليات والحركات الحية من الـ API الحقيقي
                  PosRecentTransactionsSection(controller: controller),
                  AppSpacing.vXl,

                  // كتالوج باقات الشبكة وأسعار الجملة المعتمدة من الخادم
                  PosNetworkPackagesCatalog(controller: controller),
                  AppSpacing.vXl,

                  // تتبع طلبات التوريد المفتوحة من الـ API الحقيقي
                  PosActiveSupplyOrderTracker(controller: controller),
                  AppSpacing.vXl,

                  // لوحة العمليات السريعة المتكاملة
                  Text(
                    'العمليات السريعة',
                    style: AppTypography.titleLarge.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.vMd,
                  Row(
                    children: [
                      Expanded(
                        child: PosQuickActionCard(
                          icon: Icons.add_shopping_cart_rounded,
                          title: 'طلب توريد',
                          subtitle: 'اطلب باقات بالجملة',
                          onTap: () =>
                              Get.toNamed<void>(AppRoutes.newProcurementOrder),
                        ),
                      ),
                      AppSpacing.hMd,
                      Expanded(
                        child: PosQuickActionCard(
                          icon: Icons.receipt_long_rounded,
                          title: 'فواتيري',
                          subtitle: 'سجل مشترياتك',
                          onTap: () =>
                              Get.toNamed<void>(AppRoutes.purchaseInvoices),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vMd,
                  Row(
                    children: [
                      Expanded(
                        child: PosQuickActionCard(
                          icon: Icons.payment_rounded,
                          title: 'سداد دفعة للشبكة',
                          subtitle: 'تسوية ديون وزيادة السقف',
                          onTap: () =>
                              Get.toNamed<void>(AppRoutes.posDebtLedger),
                        ),
                      ),
                      AppSpacing.hMd,
                      Expanded(
                        child: PosQuickActionCard(
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'كشف الحساب',
                          subtitle: 'حركات المحفظة بالتفصيل',
                          onTap: () {
                            final networkId =
                                controller.selectedNetworkLink.value?.networkId;
                            final args = <String, dynamic>{
                              'pos_id': activePos.posId,
                            };
                            if (networkId != null) {
                              args['network_id'] = networkId;
                            }
                            Get.toNamed<void>(
                              AppRoutes.posWalletStatement,
                              arguments: args,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  void _showPosPicker(BuildContext context) {
    CustomBottomSheet.show<void>(
      title: 'تبديل نقطة البيع',
      subtitle: 'اختر نقطة البيع التي تريد إدارتها',
      leadingIcon: Icons.storefront_rounded,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: controller.availablePos.map((pos) {
          final selected = controller.activePos.value?.posId == pos.posId;
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: CustomInteractiveBounce(
              onTap: () {
                Get.back<void>();
                controller.selectPos(pos);
              },
              child: ListTile(
                leading: const Icon(Icons.storefront_rounded),
                title: Text(pos.posName),
                trailing: selected
                    ? const Icon(Icons.check_circle_rounded)
                    : const Icon(Icons.chevron_left_rounded),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
