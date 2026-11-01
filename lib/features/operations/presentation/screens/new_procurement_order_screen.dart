import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:netsales/features/operations/presentation/controllers/create_voucher_request_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/operations_sale_type_bar.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/package_selection_card.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/request_financial_summary_card.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// ============================================================================
/// شاشة إنشاء طلب توريد كروت جديد (POS-02: New Procurement Order Screen)
/// ============================================================================
/// الشاشة القانونية المعتمدة لنقطة البيع لطلب باقات كروت من مزودي الشبكات المرتبطين.
/// المسار المعتمد: /pos/procurement-orders/new (AppRoutes.newProcurementOrder).
class NewProcurementOrderScreen extends StatefulWidget {
  const NewProcurementOrderScreen({super.key});

  @override
  State<NewProcurementOrderScreen> createState() =>
      _NewProcurementOrderScreenState();
}

class _NewProcurementOrderScreenState extends State<NewProcurementOrderScreen> {
  late final CreateVoucherRequestController _controller;

  int get _resolvedPosId {
    if (Get.arguments is Map && (Get.arguments as Map)['pos_id'] != null) {
      return (Get.arguments as Map)['pos_id'] as int;
    }
    if (Get.arguments is int) {
      return Get.arguments as int;
    }
    if (Get.parameters['pos_id'] != null) {
      final parsed = int.tryParse(Get.parameters['pos_id']!);
      if (parsed != null && parsed > 0) return parsed;
    }
    if (Get.isRegistered<DashboardController>()) {
      final dashContext =
          Get.find<DashboardController>().overview.value?.context;
      if (dashContext?.posId != null && dashContext!.posId! > 0) {
        return dashContext.posId!;
      }
    }
    return 1;
  }

  int? get _initialNetworkId {
    if (Get.arguments is Map && (Get.arguments as Map)['network_id'] != null) {
      return (Get.arguments as Map)['network_id'] as int;
    }
    if (Get.parameters['network_id'] != null) {
      return int.tryParse(Get.parameters['network_id']!);
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _controller = Get.find<CreateVoucherRequestController>();
    _controller.init(
      posId: _resolvedPosId,
      networkId: _initialNetworkId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          'طلب توريد باقات كروت',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          'نقطة البيع -> مزود الشبكة المعتمد',
          style: AppTypography.labelSmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        centerTitle: true,
        backgroundColor: colors.surface,
        elevation: 0,
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const CustomSkeletonFeed(
            itemCount: 4,
            padding: EdgeInsets.all(AppSpacing.screenPadding),
          );
        }

        if (_controller.loadError.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: CustomEmptyState(
                icon: Icons.error_outline_rounded,
                title: 'تعذر تحميل بيانات الباقات',
                description: _controller.loadError.value,
                actionLabel: 'إعادة المحاولة',
                onAction: () => _controller.loadInitialData(),
              ),
            ),
          );
        }

        final linkedNetworks = _controller.linkedNetworks;
        final packages = _controller.packages;
        final quantities = _controller.packageQuantities;
        final saleType = _controller.saleType.value;
        final totalVouchers = _controller.totalVoucherCount;
        final grossAmount = _controller.totalGrossAmount;
        final discountAmount = _controller.totalDiscountAmount;
        final netAmount = _controller.totalNetAmount;

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(AppSpacing.screenPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1. بطاقة اختيار الشبكة الموردة
                  if (linkedNetworks.length > 1) ...[
                    CustomDropdown<int>(
                      label: 'مزود الشبكة المورد',
                      hint: 'اختر الشبكة المطلوب الشراء منها',
                      prefixIcon: Icons.cell_tower_rounded,
                      valueListenable: _controller.selectedNetworkId,
                      items: linkedNetworks
                          .map(
                            (net) => DropdownItem<int>(
                              value: net.networkId,
                              label: net.networkName ?? 'شبكة #${net.networkId}',
                              description: 'رقم الشبكة: ${net.networkId}',
                            ),
                          )
                          .toList(),
                      onChanged: (newNetId) =>
                          _controller.onNetworkChanged(newNetId),
                    ),
                    AppSpacing.vMd,
                  ] else if (linkedNetworks.isNotEmpty) ...[
                    _buildSingleNetworkCard(context, linkedNetworks.first.networkName ?? 'الشبكة المعتمدة'),
                    AppSpacing.vMd,
                  ],

                  // 2. محدد نمط الشراء (نقدي / آجل)
                  Text(
                    'نمط السداد والفوترة',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppSpacing.vXs,
                  OperationsSaleTypeBar(
                    selectedSaleType: saleType,
                    onChanged: (newType) {
                      _controller.saleType.value = newType;
                    },
                  ),
                  AppSpacing.vLg,

                  // 3. قسم الباقات المتاحة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'باقات كروت الإنترنت المتاحة',
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          borderRadius: AppRadius.fullRadius,
                        ),
                        child: Text(
                          '${packages.length} باقة',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vSm,

                  if (packages.isEmpty)
                    Container(
                      padding: EdgeInsets.all(24.r),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: AppRadius.mdRadius,
                      ),
                      child: Center(
                        child: Text(
                          'لا توجد باقات كروت معتمدة ونشطة في هذه الشبكة حالياً.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...packages.map((pkg) {
                      final qty = quantities[pkg.packageId] ?? 0;
                      final discountPercent = saleType == 'CASH'
                          ? pkg.packageDefaultCashDiscount
                          : pkg.packageDefaultCreditDiscount;

                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: PackageSelectionCard(
                          package: pkg,
                          quantity: qty,
                          discountPercent: discountPercent,
                          onIncrement: () =>
                              _controller.incrementQuantity(pkg.packageId),
                          onDecrement: () =>
                              _controller.decrementQuantity(pkg.packageId),
                          onAddPreset: (preset) => _controller.addPresetQuantity(
                            pkg.packageId,
                            preset,
                          ),
                          onSetQuantity: (val) => _controller.setExactQuantity(
                            pkg.packageId,
                            val,
                          ),
                        ),
                      );
                    }),

                  AppSpacing.vMd,

                  // 4. حقل ملاحظات الطلب
                  CustomTextField(
                    controller: _controller.notesController,
                    label: 'ملاحظات وتوجيهات للشبكة (اختياري)',
                    hint: 'أدخل أي تعليمات خاصة بتسليم أو تدقيق الكروت...',
                    prefixIcon: Icons.edit_note_rounded,
                    maxLines: 2,
                  ),

                  AppSpacing.vLg,

                  // 5. بطاقة تقدير القيمة المالية مع التنبيه الصارم لسيادة الخادم
                  RequestFinancialSummaryCard(
                    voucherCount: totalVouchers,
                    grossAmount: grossAmount,
                    discountAmount: discountAmount,
                    netAmount: netAmount,
                    saleType: saleType,
                  ),

                  AppSpacing.vSm,

                  // 6. بطاقة تنبيه سيادة الخادم المالية
                  _buildServerAuthorityNoticeCard(context),

                  // مسافة سفلية لأجل شريط الإجراءات
                  SizedBox(height: 100.h),
                ]),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: _buildBottomActionDock(context),
    );
  }

  Widget _buildSingleNetworkCard(BuildContext context, String networkName) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.05),
        borderRadius: AppRadius.mdRadius,
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.2),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.smRadius,
            ),
            child: Icon(
              Icons.cell_tower_rounded,
              color: colors.primary,
              size: 20.r,
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الشبكة الموردة للكروت',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  networkName,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: colors.success.withValues(alpha: 0.1),
              borderRadius: AppRadius.fullRadius,
            ),
            child: Text(
              'مرتبطة',
              style: AppTypography.labelSmall.copyWith(
                color: colors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerAuthorityNoticeCard(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: AppRadius.mdRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
          width: 0.8.w,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18.r,
            color: colors.onSurfaceVariant,
          ),
          AppSpacing.hSm,
          Expanded(
            child: Text(
              'معاينة الأسعار والخصومات أعلاه هي أرقام تقديرية استرشادية. '
              'يتم احتساب وتثبيت الإجمالي الفعلي والخصم النهائي حصرياً بواسطة الخادم عند اعتماد الطلب.',
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionDock(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final totalVouchers = _controller.totalVoucherCount;
      final netAmount = _controller.totalNetAmount;
      final isSubmitting = _controller.isSubmitting.value;
      final canSubmit = totalVouchers > 0 && !isSubmitting;

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.3),
              width: 0.8.w,
            ),
          ),
          boxShadow: AppElevation.level2(context),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // ملخص سريع للكمية والصافي
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الإجمالي ($totalVouchers كرت)',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      AmountFormatter.formatYemenRial(netAmount),
                      style: AppTypography.titleSmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AppSpacing.hSm,
              // زر الإرسال
              Expanded(
                flex: 3,
                child: CustomButton.primary(
                  text: 'إرسال طلب التوريد',
                  icon: Icons.send_rounded,
                  isLoading: isSubmitting,
                  onPressed: canSubmit ? _handleSubmit : null,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _handleSubmit() async {
    final newRequest = await _controller.submitRequest();
    if (newRequest != null) {
      // توجيه تلقائي لتفاصيل الطلب المعتمدة POS-08
      Get.offNamed(
        AppRoutes.voucherRequestDetails,
        arguments: newRequest.requestId,
      );
    }
  }
}

