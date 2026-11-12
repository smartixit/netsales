import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_type.dart';
import 'package:netsales/features/reports/presentation/controllers/operational_reports_controller.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_record_card.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_summary_strip.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_card.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

class OperationalReportsScreen extends GetView<OperationalReportsController> {
  const OperationalReportsScreen({
    required this.networkId,
    required this.isNetworkWorkspace,
    this.posId,
    super.key,
  });

  final int? networkId;
  final int? posId;
  final bool isNetworkWorkspace;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        controller.configureScope(
          networkId: networkId,
          posId: posId,
          isNetworkWorkspace: isNetworkWorkspace,
        ),
      );
    });

    return CustomAppScaffold(
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التقارير التشغيلية',
              style: AppTypography.titleLarge.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            AppSpacing.vXs,
            Text(
              'بيانات موثقة من الخادم، مع تصفية وتصدير وفق صلاحية مساحة العمل.',
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            AppSpacing.vMd,
            Expanded(
              child: Obx(() {
          final types = controller.availableTypes;
          if (types.isEmpty) {
            return const CustomEmptyState.boxed(
              title: 'لا توجد تقارير متاحة',
              subtitle: 'لا توجد لديك صلاحية لعرض أي من التقارير التشغيلية في مساحة العمل الحالية.',
              icon: Icons.lock_outline_rounded,
            );
          }

          if (!controller.hasNetworkScope) {
            return const CustomEmptyState.boxed(
              title: 'حدد مساحة العمل أولاً',
              subtitle: 'اختر شبكة أو نقطة بيع مصرحاً بها حتى يمكن تحميل تقاريرها.',
              icon: Icons.business_outlined,
            );
          }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeSelector(types),
                    AppSpacing.vMd,
                    _buildSearchAndFilters(context),
                    Obx(() {
                      final message = controller.summaryError.value;
                      if (message == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          message,
                          style: AppTypography.labelSmall.copyWith(
                            color: context.colors.error,
                          ),
                        ),
                      );
                    }),
                    Obx(() {
                      final summary = controller.summary.value;
                      final type = controller.selectedType.value;
                      if (summary == null || type == null) {
                        final failure = controller.summaryError.value;
                        if (failure == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: CustomErrorState.compact(
                            title: 'تعذر تحميل الملخص المالي',
                            subtitle: failure,
                            onRetry: () => controller.loadReport(refresh: true),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: OperationalReportSummaryStrip(
                          summary: summary,
                          type: type,
                        ),
                      );
                    }),
                    Expanded(child: _buildRecords(context)),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector(List<OperationalReportType> types) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = types[index];
          final isSelected = controller.selectedType.value == type;
          return isSelected
              ? Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Text(
                    type.label,
                    style: AppTypography.labelMedium.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : CustomButton.outline(
                  text: type.label,
                  onPressed: () => controller.selectType(type),
                );
        },
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    final colors = context.colors;
    final type = controller.selectedType.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: controller.searchTextController,
          label: 'البحث في سجلات التقرير',
          hint: 'ابحث بالرقم المرجعي أو الوصف أو نقطة البيع',
          prefixIcon: const Icon(Icons.search_rounded),
          isRequired: false,
          onChanged: controller.onSearchChanged,
          onFieldSubmitted: (_) => controller.loadReport(refresh: true),
        ),
        AppSpacing.vSm,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Obx(
              () => CustomButton.outline(
                text: 'من: ' + (controller.fromDate.value ?? 'البداية'),
                prefix: Icons.calendar_month_outlined,
                onPressed: () => controller.selectDate(isFrom: true),
                foregroundColor: colors.onSurface,
              ),
            ),
            Obx(
              () => CustomButton.outline(
                text: 'إلى: ' + (controller.toDate.value ?? 'النهاية'),
                prefix: Icons.event_outlined,
                onPressed: () => controller.selectDate(isFrom: false),
                foregroundColor: colors.onSurface,
              ),
            ),
            if (controller.fromDate.value != null ||
                controller.toDate.value != null ||
                controller.searchTextController.text.isNotEmpty ||
                controller.selectedStatus.value != null ||
                controller.selectedSaleType.value != null)
              CustomButton.text(
                text: 'مسح عوامل التصفية',
                prefix: Icons.filter_alt_off_rounded,
                onPressed: controller.clearFilters,
                foregroundColor: colors.error,
              ),
          ],
        ),
        if (isNetworkWorkspace &&
            type != OperationalReportType.expenses &&
            type != OperationalReportType.networkWallet) ...[
          AppSpacing.vSm,
          _buildPosFilter(context),
        ],
        if (type != null && type.statusOptions.isNotEmpty) ...[
          AppSpacing.vSm,
          Text(
            'الحالة',
            style: AppTypography.labelMedium.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.vXs,
          Obx(
            () => Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _filterButton(
                  label: 'كل الحالات',
                  selected: controller.selectedStatus.value == null,
                  onPressed: () => controller.selectStatus(null),
                ),
                ...type.statusOptions.map(
                  (value) => _filterButton(
                    label: _statusLabel(value),
                    selected: controller.selectedStatus.value == value,
                    onPressed: () => controller.selectStatus(value),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (type == OperationalReportType.sales ||
            type == OperationalReportType.requests) ...[
          AppSpacing.vSm,
          Text(
            type == OperationalReportType.sales ? 'نوع البيع' : 'نوع الطلب',
            style: AppTypography.labelMedium.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.vXs,
          Obx(
            () => Wrap(
              spacing: 6,
              children: [
                _filterButton(
                  label: 'الكل',
                  selected: controller.selectedSaleType.value == null,
                  onPressed: () => controller.selectSaleType(null),
                ),
                _filterButton(
                  label: 'نقدي',
                  selected: controller.selectedSaleType.value == 'CASH',
                  onPressed: () => controller.selectSaleType('CASH'),
                ),
                _filterButton(
                  label: 'آجل',
                  selected: controller.selectedSaleType.value == 'CREDIT',
                  onPressed: () => controller.selectSaleType('CREDIT'),
                ),
              ],
            ),
          ),
        ],
        AppSpacing.vSm,
        Row(
          children: [
            Expanded(
              child: Text(
                'القيم والإجماليات من الخادم؛ المعروض هنا هو السجلات المحمّلة فقط.',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            if (controller.canExport)
              Obx(
                () => CustomButton.primary(
                  text: 'تصدير CSV',
                  prefix: Icons.file_download_outlined,
                  loading: controller.isExportActionRunning.value,
                  onPressed: controller.isExportActionRunning.value
                      ? null
                      : controller.requestExport,
                ),
              ),
          ],
        ),
        Obx(() {
          final job = controller.exportJob.value;
          if (job == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    job.statusLabel ?? job.status,
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                CustomButton.outline(
                  text: job.isReady ? 'تنزيل الملف' : 'تحديث الحالة',
                  prefix: job.isReady
                      ? Icons.download_done_rounded
                      : Icons.sync_rounded,
                  loading: controller.isCheckingExport.value,
                  onPressed: controller.isCheckingExport.value
                      ? null
                      : controller.refreshExportStatus,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPosFilter(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingPos.value) {
        return const LinearProgressIndicator(minHeight: 2);
      }
      if (controller.posError.value != null) {
        return CustomErrorState.compact(
          title: 'تعذر تحميل نقاط البيع',
          subtitle: controller.posError.value,
          onRetry: () => controller.loadPosOptions(refresh: true),
        );
      }

      final items = <DropdownMenuItem<int>>[
        const DropdownMenuItem<int>(
          value: 0,
          child: Text('كل نقاط البيع'),
        ),
        ...controller.posOptions.map(
          (link) => DropdownMenuItem<int>(
            value: link.posId,
            child: Text(
              link.pos?.posName ?? ('نقطة بيع #' + link.posId.toString()),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ];

      return Row(
        children: [
          Expanded(
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: controller.selectedType.value ==
                        OperationalReportType.posWallet
                    ? 'نقطة البيع المطلوبة'
                    : 'تصفية حسب نقطة البيع',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                contentPadding: const EdgeInsetsDirectional.fromSTEB(
                  12,
                  4,
                  12,
                  4,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: controller.selectedPosId.value ?? 0,
                  items: items,
                  onChanged: (value) =>
                      controller.selectPos(value == 0 ? null : value),
                  hint: const Text('اختر نقطة بيع'),
                ),
              ),
            ),
          ),
          if (controller.hasMorePos) ...[
            const SizedBox(width: 8),
            CustomButton.outline(
              text: 'المزيد',
              prefix: Icons.expand_more_rounded,
              onPressed: controller.isLoadingMorePos.value
                  ? null
                  : () => controller.loadPosOptions(),
            ),
          ],
        ],
      );
    });
  }

  Widget _filterButton({
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return selected
        ? CustomButton.secondary(text: label, onPressed: onPressed)
        : CustomButton.outline(text: label, onPressed: onPressed);
  }

  String _statusLabel(String status) => switch (status) {
    'PAID' => 'مسددة',
    'PARTIALLY_PAID' => 'مسددة جزئياً',
    'UNPAID' => 'غير مسددة',
    'DEPOSIT' => 'إيداع',
    'WITHDRAW' => 'سحب',
    'COMPLETED' => 'مكتمل',
    'REVERSED' => 'معكوس',
    'PENDING' => 'قيد الانتظار',
    'APPROVED' => 'معتمد',
    'REJECTED' => 'مرفوض',
    'CANCELLED' => 'ملغى',
    'CANCELLED' => 'ملغى',
    _ => status,
  };

  Widget _buildRecords(BuildContext context) {
    return Obx(() {
      if (controller.requiresPosSelection) {
        return const CustomEmptyState.compact(
          title: 'حدد نقطة بيع',
          subtitle: 'كشف محفظة نقطة البيع يتطلب اختيار نقطة البيع أولاً.',
          icon: Icons.storefront_outlined,
        );
      }

      if (controller.isLoading.value && controller.reports.isEmpty) {
        return const CustomSkeletonFeed(itemCount: 5);
      }

      if (controller.errorMessage.value != null &&
          controller.reports.isEmpty) {
        return CustomErrorState.compact(
          title: 'تعذر تحميل التقرير',
          subtitle: controller.errorMessage.value,
          onRetry: () => controller.loadReport(refresh: true),
        );
      }

      if (controller.reports.isEmpty) {
        return const CustomEmptyState.compact(
          title: 'لا توجد سجلات مطابقة',
          subtitle: 'غيّر الفترة أو عوامل التصفية لعرض نتائج أخرى.',
          icon: Icons.query_stats_rounded,
        );
      }

      final type = controller.selectedType.value!;
      return RefreshIndicator(
        onRefresh: () => controller.loadReport(refresh: true),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 180 &&
                controller.hasMore &&
                !controller.isLoadingMore.value &&
                controller.loadMoreError.value == null) {
              controller.loadReport();
            }
            return false;
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.reports.length +
                ((controller.hasMore ||
                        controller.loadMoreError.value != null ||
                        controller.isLoadingMore.value)
                    ? 1
                    : 0),
            separatorBuilder: (_, _) => AppSpacing.vSm,
            itemBuilder: (context, index) {
              if (index == controller.reports.length) {
                if (controller.loadMoreError.value != null) {
                  return CustomErrorState.compact(
                    title: 'تعذر تحميل بقية السجلات',
                    subtitle: controller.loadMoreError.value,
                    onRetry: () => controller.loadReport(),
                  );
                }
                if (controller.isLoadingMore.value) {
                  return const CustomSkeletonCard(height: 104);
                }
                return CustomButton.outline(
                  text: 'تحميل المزيد من السجلات',
                  suffix: Icons.expand_more_rounded,
                  onPressed: () => controller.loadReport(),
                );
              }
              return OperationalReportRecordCard(
                record: controller.reports[index],
                type: type,
              );
            },
          ),
        ),
      );
    });
  }
}
