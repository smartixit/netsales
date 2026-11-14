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
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
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

                final entry = controller.selectedReportEntry;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OperationalReportTypeSelector(
                      controller: controller,
                      types: types,
                    ),
                    AppSpacing.vMd,
                    if (entry != null)
                      Expanded(
                        flex: 3,
                        child: OperationalReportStudioWorkspace(
                          controller: controller,
                          entry: entry,
                        ),
                      ),
                    OperationalReportActionsBar(controller: controller),
                    OperationalReportSummaryAndCharts(
                      controller: controller,
                    ),
                    AppSpacing.vSm,
                    Expanded(
                      flex: 2,
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
