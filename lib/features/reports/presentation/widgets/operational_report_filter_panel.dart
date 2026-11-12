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

      final canFilterByPos = isNetworkWorkspace &&
          type != OperationalReportType.expenses &&
          type != OperationalReportType.networkWallet;

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
          Row(
            children: [
              Expanded(
                child: CustomDatePickerField.single(
                  label: 'من تاريخ',
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
                  label: 'إلى تاريخ',
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
            _buildPosSelector(context, type),
          ],
          if (type.statusOptions.isNotEmpty) ...[
            AppSpacing.vSm,
            Text(
              'الحالة',
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
                ...type.statusOptions.map(
                  (value) => _filterButton(
                    label: _statusLabel(value),
                    selected: controller.selectedStatus.value == value,
                    onPressed: () => controller.selectStatus(value),
                  ),
                ),
              ],
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
            Wrap(
              spacing: 6,
              runSpacing: 6,
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
          ],
          AppSpacing.vSm,
          Row(
            children: [
              Expanded(
                child: Text(
                  'الإجماليات من الخادم؛ القائمة أدناه تعرض سجلات التقرير.',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              if (controller.searchQuery.value.isNotEmpty ||
                  controller.fromDate.value != null ||
                  controller.toDate.value != null ||
                  controller.selectedStatus.value != null ||
                  controller.selectedSaleType.value != null ||
                  (canFilterByPos && controller.selectedPosId.value != null))
                CustomButton.text(
                  text: 'مسح الفلاتر',
                  prefix: Icons.filter_alt_off_rounded,
                  onPressed: controller.clearFilters,
                  foregroundColor: colors.error,
                ),
              if (controller.canExport) ...[
                AppSpacing.hXs,
                CustomButton.primary(
                  text: 'تصدير CSV',
                  prefix: Icons.file_download_outlined,
                  loading: controller.isExportActionRunning.value,
                  onPressed: controller.isExportActionRunning.value
                      ? null
                      : controller.requestExport,
                ),
              ],
            ],
          ),
          if (controller.exportJob.value != null) ...[
            AppSpacing.vXs,
            _buildExportStatus(context),
          ],
        ],
      );
    });
  }

  Widget _buildPosSelector(
    BuildContext context,
    OperationalReportType type,
  ) {
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

      final requiresOne = type == OperationalReportType.posWallet;
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
