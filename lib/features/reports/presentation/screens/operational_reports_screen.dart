import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/reports/presentation/controllers/operational_reports_controller.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_actions_bar.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_records_list.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_summary_and_charts.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_studio_workspace.dart';
import 'package:netsales/features/reports/presentation/widgets/operational_report_type_selector.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';

class OperationalReportsScreen extends GetView<OperationalReportsController> {
  const OperationalReportsScreen({
    required this.networkId,
    required this.isNetworkWorkspace,
    this.posId,
    this.organizationName,
    this.logoUrl,
    this.embedded = false,
    super.key,
  });

  final int? networkId;
  final int? posId;
  final String? organizationName;
  final String? logoUrl;
  final bool isNetworkWorkspace;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(controller.configureScope(
        networkId: networkId,
        posId: posId,
        isNetworkWorkspace: isNetworkWorkspace,
        organizationName: organizationName,
        logoUrl: logoUrl,
      ));
    });

    final content = Padding(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التقارير التشغيلية',
            style: AppTypography.titleLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: AppTypography.bold,
            ),
          ),
          AppSpacing.vXs,
          Text(
            'بيانات موثقة من الخادم، مع تصفية وتصدير حسب صلاحيات مساحة العمل.',
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              final entry = controller.selectedReportEntry;
              if (entry == null) {
                return const CustomEmptyState.boxed(
                  title: 'جارٍ تجهيز التقارير',
                  subtitle: 'يتم تحميل تعريفات التقارير المصرح بها.',
                  icon: Icons.pending_outlined,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OperationalReportTypeSelector(controller: controller, types: types),
                  AppSpacing.vMd,
                  CustomSegmentedBar(
                    selectedIndex: controller.activeReportPane.value,
                    onSegmentChanged: controller.selectReportPane,
                    items: const [
                      CustomSegmentItem(label: 'الإعدادات', icon: Icons.tune_rounded),
                      CustomSegmentItem(label: 'الملخص', icon: Icons.insights_rounded),
                      CustomSegmentItem(label: 'السجلات', icon: Icons.receipt_long_rounded),
                    ],
                  ),
                  AppSpacing.vMd,
                  Expanded(
                    child: switch (controller.activeReportPane.value) {
                      0 => OperationalReportStudioWorkspace(controller: controller, entry: entry),
                      1 => _ReportSummaryPane(controller: controller),
                      _ => _ReportRecordsPane(controller: controller),
                    },
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
    return embedded ? content : CustomAppScaffold(body: content);
  }
}

class _ReportSummaryPane extends StatelessWidget {
  const _ReportSummaryPane({required this.controller});
  final OperationalReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OperationalReportActionsBar(controller: controller),
        AppSpacing.vSm,
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: OperationalReportSummaryAndCharts(controller: controller),
          ),
        ),
      ],
    );
  }
}

class _ReportRecordsPane extends StatelessWidget {
  const _ReportRecordsPane({required this.controller});
  final OperationalReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OperationalReportActionsBar(controller: controller),
        AppSpacing.vSm,
        Expanded(child: OperationalReportRecordsList(controller: controller)),
      ],
    );
  }
}
