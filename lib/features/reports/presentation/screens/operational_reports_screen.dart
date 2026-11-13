import 'dart:async';

import 'package:flutter/material.dart';
import 'package:document_engine/document_engine.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/reports/presentation/controllers/operational_reports_controller.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_filter_panel.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_records_list.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_summary_strip.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_type_selector.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

class OperationalReportsScreen extends GetView<OperationalReportsController> {
  const OperationalReportsScreen({
    required this.networkId,
    required this.isNetworkWorkspace,
    this.posId,
    this.organizationName,
    this.logoUrl,
    super.key,
  });

  final int? networkId;
  final int? posId;
  final String? organizationName;
  final String? logoUrl;
  final bool isNetworkWorkspace;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        controller.configureScope(
          networkId: networkId,
          posId: posId,
          isNetworkWorkspace: isNetworkWorkspace,
          organizationName: organizationName,
          logoUrl: logoUrl,
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
                fontWeight: AppTypography.bold,
              ),
            ),
            AppSpacing.vXs,
            Text(
              'بيانات موثقة من الخادم، مع تصفية وتصدير حسب صلاحيات مساحة العمل.',
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
                    subtitle:
                        'لا توجد لديك صلاحية لعرض أي من التقارير التشغيلية في مساحة العمل الحالية.',
                    icon: Icons.lock_outline_rounded,
                  );
                }

                if (!controller.hasNetworkScope) {
                  return const CustomEmptyState.boxed(
                    title: 'حدد مساحة العمل أولاً',
                    subtitle:
                        'اختر شبكة أو نقطة بيع مصرحاً بها حتى يمكن تحميل تقاريرها.',
                    icon: Icons.business_outlined,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OperationalReportTypeSelector(
                      controller: controller,
                      types: types,
                    ),
                    AppSpacing.vMd,
                    if (controller.selectedReportEntry case final entry?) 
                      Obx(() => ReportConfigurationStudio(
                        definition: entry.definition,
                        criteria: controller.criteria.value,
                        presentation: controller.presentation.value,
                        resolveLabel: (context, key) {
                          if (key == entry.definition.titleKey) return entry.label;
                          if (key == entry.definition.descriptionKey) return entry.description;
                          return entry.filterLabels[key] ??
                              entry.columnLabels[key] ??
                              entry.metricLabels[key] ??
                              entry.choiceLabels.entries
                                  .where((item) => item.value.containsKey(key.split('.').last))
                                  .map((item) => item.value[key.split('.').last]!)
                                  .firstOrNull ??
                              key;
                        },
                        onCriteriaChanged: controller.updateCriteria,
                        onPresentationChanged: controller.updatePresentation,
                        onPreview: controller.summary.value == null
                            ? null
                            : controller.exportSummaryPdf,
                        actionBuilder: (context, {required label, required icon, required onPressed, required secondary}) =>
                            secondary
                                ? CustomButton.outline(text: label, prefix: icon, onPressed: onPressed)
                                : CustomButton.primary(text: label, prefix: icon, onPressed: onPressed),
                        isBusy: controller.isLoading.value || controller.isPdfActionRunning.value,
                      )),
                    Obx(() {
                      final summary = controller.summary.value;
                      final type = controller.selectedType.value;
                      if (summary == null || type == null) {
                        final failure = controller.summaryError.value;
                        if (failure == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: CustomErrorState.compact(
                            title: 'تعذر تحميل الملخص المالي',
                            subtitle: failure,
                            onRetry: () => controller.loadReport(refresh: true),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: OperationalReportSummaryStrip(
                          summary: summary,
                        ),
                      );
                    }),
                    AppSpacing.vSm,
                    Expanded(
                      child: OperationalReportRecordsList(
                        controller: controller,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
