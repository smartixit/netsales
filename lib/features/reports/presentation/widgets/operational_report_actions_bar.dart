import 'package:document_engine/document_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/reports/presentation/controllers/operational_reports_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// Compact mobile-first report actions; secondary operations are progressively
/// disclosed in the shared action sheet rather than stacked on the report view.
class OperationalReportActionsBar extends StatelessWidget {
  const OperationalReportActionsBar({required this.controller, super.key});

  final OperationalReportsController controller;

  Future<void> _confirmDeletePreset(SavedReportPreset preset) async {
    await CustomBottomSheet.showConfirmation<void>(
      title: 'حذف إعداد التقرير',
      message: 'سيتم حذف إعداد «${preset.name}» نهائياً. لا يمكن التراجع عن هذه العملية.',
      leadingIcon: Icons.delete_outline_rounded,
      confirmLabel: 'حذف الإعداد',
      isDestructive: true,
      onConfirm: () => controller.deletePreset(preset),
    );
  }

  Future<void> _showMoreActions() async {
    final items = <CustomBottomSheetActionItem>[
      CustomBottomSheetActionItem(
        title: 'تصدير PDF تفصيلي',
        subtitle: 'إنشاء مستند يتضمن السجلات والأعمدة المختارة.',
        icon: Icons.picture_as_pdf_outlined,
        onTap: controller.exportDetailedPdf,
      ),
      CustomBottomSheetActionItem(
        title: 'حفظ ملخص PDF',
        subtitle: 'حفظ الملخص التنفيذي في مجلد التقارير.',
        icon: Icons.save_alt_rounded,
        onTap: controller.exportSummaryPdf,
      ),
      CustomBottomSheetActionItem(
        title: 'مشاركة ملخص PDF',
        subtitle: 'فتح خيارات مشاركة المستند.',
        icon: Icons.share_outlined,
        onTap: controller.shareSummaryPdf,
      ),
      CustomBottomSheetActionItem(
        title: 'طباعة ملخص PDF',
        subtitle: 'إرسال المستند إلى خدمة الطباعة.',
        icon: Icons.print_outlined,
        onTap: controller.printSummaryPdf,
      ),
      CustomBottomSheetActionItem(
        title: 'مسح عوامل التصفية',
        subtitle: 'إعادة معايير التقرير إلى حالتها الافتراضية.',
        icon: Icons.filter_alt_off_outlined,
        onTap: controller.clearFilters,
      ),
    ];

    for (final preset in controller.savedPresets) {
      items
        ..add(
          CustomBottomSheetActionItem(
            title: 'تطبيق: ${preset.name}',
            subtitle: 'استعادة عوامل التصفية وتنسيق التقرير المحفوظ.',
            icon: Icons.bookmark_outline_rounded,
            onTap: () => controller.applyPreset(preset),
          ),
        )
        ..add(
          CustomBottomSheetActionItem(
            title: 'حذف: ${preset.name}',
            subtitle: 'حذف هذا الإعداد المحفوظ نهائياً.',
            icon: Icons.delete_outline_rounded,
            isDestructive: true,
            onTap: () => _confirmDeletePreset(preset),
          ),
        );
    }

    await CustomBottomSheet.showActions<void>(
      title: 'إجراءات التقرير',
      subtitle: 'اختر الإجراء المطلوب. ستظهر حالة التحميل أثناء العمليات الطويلة.',
      leadingIcon: Icons.more_horiz_rounded,
      items: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Obx(
                () => CustomButton.primary(
                  text: 'تصدير CSV',
                  prefix: Icons.table_view_outlined,
                  size: AppButtonSize.medium,
                  onPressed: controller.canExport &&
                          !controller.isExportActionRunning.value
                      ? controller.requestExport
                      : null,
                  loading: controller.isExportActionRunning.value,
                ),
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              child: CustomButton.outline(
                text: 'إجراءات أخرى',
                prefix: Icons.tune_rounded,
                size: AppButtonSize.medium,
                onPressed: _showMoreActions,
              ),
            ),
          ],
        ),

      ],
    );
  }
}
