import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/reports/presentation/controllers/operational_reports_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// Saved presets and report exports for the selected operational report.
class OperationalReportActionsBar extends StatelessWidget {
  const OperationalReportActionsBar({
    required this.controller,
    super.key,
  });

  final OperationalReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() {
          if (controller.savedPresets.isEmpty) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.savedPresets.map((preset) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomButton.outline(
                      text: preset.name,
                      onPressed: () => controller.applyPreset(preset),
                    ),
                    CustomButton.icon(
                      icon: Icons.delete_outline,
                      tooltip: 'حذف الإعداد',
                      onPressed: controller.isDeletingPreset.value
                          ? null
                          : () => controller.deletePreset(preset),
                    ),
                  ],
                );
              }).toList(growable: false),
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              CustomButton.outline(
                text: 'مسح عوامل التصفية',
                prefix: Icons.filter_alt_off_outlined,
                onPressed: controller.clearFilters,
              ),
              Obx(
                () => CustomButton.primary(
                  text: 'تصدير CSV',
                  prefix: Icons.table_view_outlined,
                  onPressed: controller.canExport &&
                          !controller.isExportActionRunning.value
                      ? controller.requestExport
                      : null,
                  loading: controller.isExportActionRunning.value,
                ),
              ),
              Obx(
                () => CustomButton.outline(
                  text: 'تصدير PDF تفصيلي',
                  prefix: Icons.picture_as_pdf_outlined,
                  onPressed: controller.canExport &&
                          controller.summary.value != null &&
                          !controller.isPdfActionRunning.value
                      ? controller.exportDetailedPdf
                      : null,
                  loading: controller.isPdfActionRunning.value,
                ),
              ),
              Obx(
                () => CustomButton.outline(
                  text: 'حفظ ملخص PDF',
                  prefix: Icons.picture_as_pdf_outlined,
                  onPressed: controller.canExport &&
                          controller.summary.value != null &&
                          !controller.isPdfActionRunning.value
                      ? controller.exportSummaryPdf
                      : null,
                  loading: controller.isPdfActionRunning.value,
                ),
              ),
              Obx(
                () => CustomButton.outline(
                  text: 'مشاركة PDF',
                  prefix: Icons.share_outlined,
                  onPressed: controller.canExport &&
                          controller.summary.value != null &&
                          !controller.isPdfActionRunning.value
                      ? controller.shareSummaryPdf
                      : null,
                ),
              ),
              Obx(
                () => CustomButton.outline(
                  text: 'طباعة PDF',
                  prefix: Icons.print_outlined,
                  onPressed: controller.canExport &&
                          controller.summary.value != null &&
                          !controller.isPdfActionRunning.value
                      ? controller.printSummaryPdf
                      : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
