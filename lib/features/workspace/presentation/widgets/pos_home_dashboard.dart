import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_active_supply_order_tracker.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_connected_networks_carousel_section.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_network_packages_catalog.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_quick_action_card.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_recent_transactions_section.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_selected_network_financial_summary.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_welcome_header.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_card.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

/// الشاشة الرئيسية لمساحة عمل نقطة البيع (PosHomeDashboard)
/// متوافقة هندسياً ومعمارياً بنسبة 100% مع معايير مساحات العمل وشاشة NetworkWorkspaceDashboard
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
          115.h + MediaQuery.paddingOf(context).bottom,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Obx(() {
              if (controller.isLoadingPos.value &&
                  controller.activePos.value == null) {
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
              if (controller.posError.value != null &&
                  controller.activePos.value == null) {
                return CustomErrorState.boxed(
                  title: 'تعذر تحميل نقاط البيع',
                  subtitle: 'تحقق من الاتصال ثم أعد المحاولة.',
                  onRetry: controller.loadPosTenants,
                );
              }
              if (controller.activePos.value == null) {
                return const CustomEmptyState(
                  icon: Icons.storefront_outlined,
                  title: 'لا توجد نقطة بيع مرتبطة بحسابك',
                  subtitle:
                      'لا يمكن عرض مؤشرات مساحة العمل قبل توفر نقطة بيع مصرح بها.',
                );
              }

              final activePos = controller.activePos.value!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. كرت الترحيب القيادي لنقطة البيع
                  PosWelcomeHeader(controller: controller),
                  AppSpacing.vLg,

                  // 2. محدد نقطة البيع النشطة عند تعدد نقاط البيع
                  if (controller.availablePos.length > 1) ...[
                    CustomDropdown<int>(
                      label: 'نقطة البيع النشطة للعمليات',
                      rxValue: Rx<int?>(activePos.posId),
                      searchEnabled: controller.availablePos.length > 5,
                      items: controller.availablePos
                          .map(
                            (pos) => DropdownItem<int>(
                              value: pos.posId,
                              child: Text(pos.posName),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: controller.selectPosById,
                    ),
                    AppSpacing.vMd,
                  ],

                  // 3. كاروسيل بطاقات الشبكات المرتبطة بنقطة البيع
                  PosConnectedNetworksCarouselSection(controller: controller),
                  AppSpacing.vLg,

                  // 4. كرت السيولة والملخص المالي للشبكة المحددة (VIP Luxury Carbon Card)
                  if (controller.selectedNetworkLink.value != null) ...[
                    PosSelectedNetworkFinancialSummary(
                      networkName: controller
                              .selectedNetworkLink
                              .value!
                              .network
                              ?.networkName ??
                          'الشبكة المحددة',
                      wallet: controller.selectedWallet.value,
                      isLoading: controller.isLoadingWallet.value,
                      error: controller.walletError.value,
                      onRetry: () => controller.selectNetwork(
                        controller.selectedNetworkLink.value!,
                        index: controller.currentNetworkIndex.value,
                      ),
                      onOpenAccount: controller.openWalletStatement,
                    ),
                    AppSpacing.vLg,
                  ],

                  // 5. متابعة طلبات التوريد المفتوحة من الـ API الحقيقي
                  PosActiveSupplyOrderTracker(controller: controller),
                  AppSpacing.vLg,

                  // 6. قسم آخر العمليات والحركات الحية من الـ API الحقيقي
                  PosRecentTransactionsSection(controller: controller),
                  AppSpacing.vLg,

                  // 7. كتالوج باقات الشبكة وأسعار الجملة المعتمدة
                  PosNetworkPackagesCatalog(controller: controller),
                  AppSpacing.vLg,

                  // 8. لوحة العمليات السريعة المتكاملة
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          color: colors.primary,
                          size: 20.r,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'العمليات السريعة',
                          style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                          onTap: controller.openNewProcurementOrder,
                        ),
                      ),
                      AppSpacing.hMd,
                      Expanded(
                        child: PosQuickActionCard(
                          icon: Icons.receipt_long_rounded,
                          title: 'فواتيري',
                          subtitle: 'سجل مشترياتك',
                          onTap: controller.openPurchaseInvoices,
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
                          onTap: controller.openPosDebtLedger,
                        ),
                      ),
                      AppSpacing.hMd,
                      Expanded(
                        child: PosQuickActionCard(
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'كشف الحساب',
                          subtitle: 'حركات المحفظة بالتفصيل',
                          onTap: controller.openWalletStatement,
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
}
