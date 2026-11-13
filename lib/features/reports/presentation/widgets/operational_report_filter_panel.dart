import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_type.dart';
import 'package:netsales/features/reports/presentation/controllers/operational_reports_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_card.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/pickers/custom_date_picker_field.dart';

class OperationalReportFilterPanel extends StatelessWidget {
  const OperationalReportFilterPanel({
    required this.controller,
    required this.isNetworkWorkspace,
    super.key,
  });

  final OperationalReportsController controller;
  final bool isNetworkWorkspace;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final type = controller.selectedType.value;
      if (type == null) return const SizedBox.shrink();

      final canFilterByPos = isNetworkWorkspace && controller.canFilterByPos;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: controller.searchTextController,
            label: controller.reportFilterLabel('search', 'البحث في سجلات التقرير'),
            hint: 'ابحث بالرقم المرجعي أو الوصف أو نقطة البيع',
            prefixIcon: const Icon(Icons.search_rounded),
            isRequired: false,
            onChanged: controller.onSearchChanged,
            onFieldSubmitted: (_) => controller.loadReport(refresh: true),
          ),
          AppSpacing.vSm,
          Row(
            children: [
              Expanded(
                child: CustomDatePickerField.single(
                  label: controller.reportFilterLabel('from_date', 'من تاريخ'),
                  hint: 'بداية الفترة',
                  value: DateTime.tryParse(controller.fromDate.value ?? ''),
                  firstDate: DateTime(2010),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                  onChanged: (date) => controller.setDate(
                    isFrom: true,
                    date: date,
                  ),
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: CustomDatePickerField.single(
                  label: controller.reportFilterLabel('to_date', 'إلى تاريخ'),
                  hint: 'نهاية الفترة',
                  value: DateTime.tryParse(controller.toDate.value ?? ''),
                  firstDate: DateTime(2010),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                  onChanged: (date) => controller.setDate(
                    isFrom: false,
                    date: date,
                  ),
                ),
              ),
            ],
          ),
          if (canFilterByPos) ...[
            AppSpacing.vSm,
            _buildPosSelector(context),
          ],
          if (controller.selectedStatusOptions.isNotEmpty) ...[
            AppSpacing.vSm,
            Text(
              controller.reportFilterLabel('status', 'الحالة'),
              style: AppTypography.labelMedium.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.vXs,
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _filterButton(
                  label: 'كل الحالات',
                  selected: controller.selectedStatus.value == null,
                  onPressed: () => controller.selectStatus(null),
                ),
                ...controller.selectedStatusOptions.map(
                  (value) => _filterButton(
                    label: controller.reportChoiceLabel('status', value, value),
                    selected: controller.selectedStatus.value == value,
                    onPressed: () => controller.selectStatus(value),
                  ),
                ),
              ],
            ),
          ],
          if (controller.selectedSaleTypeOptions.isNotEmpty) ...[
            AppSpacing.vSm,
            Text(
              controller.reportFilterLabel('sale_type', 'نوع البيع / الطلب'),
              style: AppTypography.labelMedium.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.vXs,
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _filterButton(
                  label: 'الكل',
                  selected: controller.selectedSaleType.value == null,
                  onPressed: () => controller.selectSaleType(null),
                ),
                ...controller.selectedSaleTypeOptions.map((value) => _filterButton(
                  label: controller.reportChoiceLabel('sale_type', value, value),
                  selected: controller.selectedSaleType.value == value,
                  onPressed: () => controller.selectSaleType(value),
                )),
              ],
            ),
          ],
          AppSpacing.vSm,
          Text(
            'الإجماليات من الخادم. PDF ملخص تنفيذي كامل الإجماليات، وCSV للتفاصيل الكاملة.',
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          if (controller.canExport) ...[
            AppSpacing.vXs,
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  if (controller.summary.value != null) ...[
                    CustomButton.outline(
                      text: 'ملخص PDF',
                      prefix: Icons.picture_as_pdf_outlined,
                      loading: controller.isPdfActionRunning.value,
                      onPressed: controller.isPdfActionRunning.value
                          ? null
                          : controller.exportSummaryPdf,
                    ),
                    CustomButton.icon(
                      icon: Icons.share_outlined,
                      tooltip: 'مشاركة ملخص PDF',
                      onPressed: controller.isPdfActionRunning.value
                          ? null
                          : controller.shareSummaryPdf,
                    ),
                    CustomButton.icon(
                      icon: Icons.print_outlined,
                      tooltip: 'طباعة ملخص PDF',
                      onPressed: controller.isPdfActionRunning.value
                          ? null
                          : controller.printSummaryPdf,
                    ),
                  ],
                  CustomButton.primary(
                    text: 'تصدير CSV',
                    prefix: Icons.file_download_outlined,
                    loading: controller.isExportActionRunning.value,
                    onPressed: controller.isExportActionRunning.value
                        ? null
                        : controller.requestExport,
                  ),
                ],
              ),
            ),
          ],
          if (controller.exportJob.value != null) ...[
            AppSpacing.vXs,
            _buildExportStatus(context),
          ],
        ],
      );
    });
  }

  Widget _buildPosSelector(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingPos.value) {
        return const CustomSkeletonCard(height: 70);
      }

      if (controller.posError.value != null &&
          controller.posOptions.isEmpty) {
        return CustomErrorState.compact(
          title: 'تعذر تحميل نقاط البيع',
          subtitle: controller.posError.value,
          onRetry: () => controller.loadPosOptions(refresh: true),
        );
      }

      if (controller.posOptions.isEmpty) {
        return const CustomEmptyState.compact(
          title: 'لا توجد نقاط بيع مرتبطة',
          subtitle: 'لا توجد نقطة بيع نشطة متاحة لهذه الشبكة.',
          icon: Icons.storefront_outlined,
        );
      }

      final requiresOne = controller.selectedReportEntry?.access.posSelection == 'required';
      final options = <DropdownItem<int>>[
        if (!requiresOne)
          DropdownItem<int>(
            value: 0,
            child: const Text('كل نقاط البيع'),
          ),
        ...controller.posOptions.map(
          (link) => DropdownItem<int>(
            value: link.posId,
            child: Text(
              link.pos?.posName ?? ('نقطة بيع #' + link.posId.toString()),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDropdown<int>(
            label: requiresOne ? 'نقطة البيع المطلوبة' : 'تصفية حسب نقطة البيع',
            hint: requiresOne ? 'اختر نقطة بيع' : 'كل نقاط البيع',
            prefixIcon: Icons.storefront_outlined,
            rxValue: controller.selectedPosId,
            items: options,
            isRequired: requiresOne,
            onRemoteSearch: controller.searchPosOptions,
            isSearching: controller.isLoadingPos.value,
            itemSearchText: (posId) {
              final item = controller.posOptions.firstWhereOrNull(
                (link) => link.posId == posId,
              );
              return item?.pos?.posName ?? ('نقطة بيع #' + posId.toString());
            },
            onChanged: (value) => controller.selectPos(
              value == null || value == 0 ? null : value,
            ),
          ),
          if (controller.hasMorePos) ...[
            AppSpacing.vXs,
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: CustomButton.text(
                text: 'تحميل بقية نقاط البيع',
                suffix: Icons.expand_more_rounded,
                loading: controller.isLoadingMorePos.value,
                onPressed: controller.isLoadingMorePos.value
                    ? null
                    : () => controller.loadPosOptions(),
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildExportStatus(BuildContext context) {
    final colors = context.colors;
    final job = controller.exportJob.value;
    if (job == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
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
    _ => status,
  };
}
