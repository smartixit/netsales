import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/debts/presentation/controllers/network_debts_controller.dart';
import 'package:netsales/features/debts/presentation/sheets/collect_repayment_sheet.dart';
import 'package:netsales/features/debts/presentation/sheets/repayment_receipt_dialog.dart';
import 'package:netsales/features/debts/presentation/sheets/reverse_repayment_dialog.dart';
import 'package:netsales/features/debts/presentation/sheets/update_credit_limit_sheet.dart';
import 'package:netsales/features/debts/presentation/widgets/aging_summary_strip.dart';
import 'package:netsales/features/debts/presentation/widgets/outstanding_invoice_tile.dart';
import 'package:netsales/features/debts/presentation/widgets/pos_debt_card.dart';
import 'package:netsales/features/debts/presentation/widgets/repayment_record_tile.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';

class NetworkDebtsScreen extends GetView<NetworkDebtsController> {
  const NetworkDebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الذمم المدينة وسداد المديونيات',
                style: AppTypography.titleMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'M4-C • تتبع الديون، السداد التلقائي، وأعمار الفواتير',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'تحديث البيانات',
              onPressed: () {
                controller.loadReceivablesSummary();
                controller.loadRepayments();
                if (controller.selectedPos.value != null) {
                  controller.loadOutstandingInvoices(controller.selectedPos.value!.posId);
                }
              },
            ),
          ],
          bottom: TabBar(
            onTap: (idx) => controller.activeTabIndex.value = idx,
            labelColor: colors.primary,
            unselectedLabelColor: colors.onSurfaceVariant,
            indicatorColor: colors.primary,
            indicatorWeight: 3.h,
            tabs: const [
              Tab(text: 'نظرة عامة والذمم'),
              Tab(text: 'الفواتير الآجلة'),
              Tab(text: 'سجل السدادات'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(context),
            _buildOutstandingInvoicesTab(context),
            _buildRepaymentsTab(context),
          ],
        ),
      ),
    );
  }

  /// التبويب الأول: نظرة عامة، شريط أعمار الديون، وبطاقات نقاط البيع
  Widget _buildOverviewTab(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      if (controller.isLoadingSummary.value && controller.summary.value == null) {
        return Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: const CustomSkeletonFeed(itemCount: 4, cardHeight: 110),
        );
      }

      final summary = controller.summary.value;
      if (summary == null) {
        return RefreshIndicator(
          onRefresh: controller.loadReceivablesSummary,
          child: ListView(
            children: [
              SizedBox(height: 100.h),
              const CustomEmptyState(
                title: 'لا تتوفر بيانات للذمم المدينة',
                subtitle: 'اسحب للأسفل لإعادة المحاولة وتحديث البيانات',
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadReceivablesSummary,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            // بطاقات الـ KPI الرئيسية
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: colors.error.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.trending_down_rounded, color: colors.error, size: 18.r),
                            SizedBox(width: 4.w),
                            Text(
                              'إجمالي الذمم المدينة',
                              style: AppTypography.labelSmall.copyWith(color: colors.error),
                            ),
                          ],
                        ),
                        AppSpacing.vXs,
                        Text(
                          '${AmountFormatter.formatValue(summary.totalOutstandingDebt, decimalPlaces: 0)} ر.ي',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.receipt_long_rounded, color: colors.primary, size: 18.r),
                            SizedBox(width: 4.w),
                            Text(
                              'فواتير آجلة مستحقة',
                              style: AppTypography.labelSmall.copyWith(color: colors.primary),
                            ),
                          ],
                        ),
                        AppSpacing.vXs,
                        Text(
                          '${summary.unpaidInvoicesCount} فاتورة',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.vMd,
            // شريط تحليل أعمار الديون
            AgingSummaryStrip(aging: summary.agingSummary),
            AppSpacing.vLg,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'نقاط البيع والذمم المستحقة (${summary.posBreakdown.length})',
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            AppSpacing.vSm,
            if (summary.posBreakdown.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: const CustomEmptyState(
                  title: 'لا توجد ديون مستحقة',
                  subtitle: 'جميع نقاط البيع مسددة لحساباتها بالكامل',
                ),
              )
            else
              ...summary.posBreakdown.map((pos) {
                return PosDebtCard(
                  pos: pos,
                  onCollectPayment: () => CollectRepaymentSheet.show(context, pos),
                  onManageCreditLimit: () => UpdateCreditLimitSheet.show(context, pos),
                  onViewInvoices: () {
                    controller.selectPos(pos);
                    DefaultTabController.of(context).animateTo(1);
                  },
                );
              }),
          ],
        ),
      );
    });
  }

  /// التبويب الثاني: فواتير البيع الآجل مع شارة العمر
  Widget _buildOutstandingInvoicesTab(BuildContext context) {
    return Obx(() {
      final selectedPos = controller.selectedPos.value;
      final invoices = controller.outstandingInvoices;
      final isLoading = controller.isLoadingInvoices.value;

      if (selectedPos == null) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app_rounded, size: 48.r, color: context.colors.onSurfaceVariant),
                AppSpacing.vMd,
                Text(
                  'حدد نقطة بيع من تبويب "نظرة عامة والذمم"',
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'لعرض فواتيرها الآجلة وتحليل أعمار استحقاقها',
                  style: AppTypography.labelSmall.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        );
      }

      if (isLoading && invoices.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: const CustomSkeletonFeed(itemCount: 4, cardHeight: 100),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadOutstandingInvoices(selectedPos.posId),
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(selectedPos.posName, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        'إجمالي الفواتير غير المسددة: ${invoices.length}',
                        style: AppTypography.labelSmall.copyWith(color: context.colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => CollectRepaymentSheet.show(context, selectedPos),
                    icon: const Icon(Icons.payments_rounded, size: 16),
                    label: const Text('تحصيل سداد'),
                  ),
                ],
              ),
            ),
            AppSpacing.vMd,
            if (invoices.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: const CustomEmptyState(
                  title: 'لا توجد فواتير آجلة مستحقة',
                  subtitle: 'تم سداد جميع فواتير هذه النقطة بالكامل',
                ),
              )
            else
              ...invoices.map((inv) => OutstandingInvoiceTile(invoice: inv)),
          ],
        ),
      );
    });
  }

  /// التبويب الثالث: سجل سندات السداد وإمكانية العكس
  Widget _buildRepaymentsTab(BuildContext context) {
    return Obx(() {
      final repayments = controller.repayments;
      final isLoading = controller.isLoadingRepayments.value;

      if (isLoading && repayments.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          child: const CustomSkeletonFeed(itemCount: 4, cardHeight: 110),
        );
      }

      if (repayments.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.loadRepayments,
          child: ListView(
            children: [
              SizedBox(height: 100.h),
              const CustomEmptyState(
                title: 'لا توجد سندات سداد مسجلة',
                subtitle: 'عند تحصيل أي سداد من نقاط البيع ستظهر السجلات وتوزيعاتها هنا',
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadRepayments,
        child: ListView.builder(
          padding: EdgeInsets.all(AppSpacing.screenPadding),
          itemCount: repayments.length,
          itemBuilder: (context, index) {
            final item = repayments[index];
            return RepaymentRecordTile(
              repayment: item,
              onReverse: () => ReverseRepaymentDialog.show(context, item),
              onViewReceipt: () => RepaymentReceiptDialog.show(context, item),
            );
          },
        ),
      );
    });
  }
}
