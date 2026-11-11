import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/reports/domain/entities/report_catalog_item.dart';
import 'package:netsales/features/reports/presentation/controllers/network_reports_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

class NetworkReportsScreen extends GetView<NetworkReportsController> {
  const NetworkReportsScreen({super.key});

  @override
  Widget build(BuildContext context) => CustomAppScaffold(
    appBarTitle: 'التقارير وكشوف الحساب',
    appBarSubtitle: 'تقارير الشبكة وفواتير اشتراك المنصة',
    body: Padding(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      child: Obx(() {
        if (controller.isLoading.value) return const CustomSkeletonFeed(itemCount: 4);
        if (controller.error.value != null) {
          return CustomErrorState.compact(
            title: 'تعذر تحميل التقارير',
            subtitle: controller.error.value,
            onRetry: controller.loadCatalog,
          );
        }
        if (controller.catalog.isEmpty) {
          return const CustomEmptyState.compact(
            title: 'لا توجد تقارير متاحة',
            subtitle: 'لا توجد تقارير تسمح بها صلاحيات الشبكة الحالية.',
            icon: Icons.assessment_outlined,
          );
        }
        return ListView(
          children: [
            Text(
              'تُحدد التقارير المتاحة وفق صلاحيات عضويتك. بيانات الاشتراك تخص الشبكة الحالية فقط.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            AppSpacing.vMd,
            if (controller.catalog.any((r) => r.key == 'billing-account-statement')) ...[
              CustomTextField(
                controller: controller.billingAccountIdController,
                label: 'رقم حساب فوترة الاشتراك',
                hint: 'أدخل معرّف حساب الفوترة',
                keyboardType: TextInputType.number,
                isRequired: false,
              ),
              AppSpacing.vMd,
            ],
            ...controller.catalog.map((report) => _ReportCatalogCard(
              report: report,
              busy: controller.isCreating.value,
              onRun: () => controller.runReport(report),
            )),
            if (controller.activeRun.value != null) ...[
              AppSpacing.vLg,
              _ReportRunPanel(
                run: controller.activeRun.value!,
                refreshing: controller.isRefreshing.value,
                downloading: controller.isDownloading.value,
                onRefresh: controller.refreshRun,
                onDownload: controller.downloadRun,
              ),
            ],
          ],
        );
      }),
    ),
  );
}

class _ReportCatalogCard extends StatelessWidget {
  const _ReportCatalogCard({required this.report, required this.busy, required this.onRun});
  final ReportCatalogItem report;
  final bool busy;
  final VoidCallback onRun;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(report.title, style: Theme.of(context).textTheme.titleMedium),
          AppSpacing.vXs,
          Text(report.description, style: Theme.of(context).textTheme.bodyMedium),
          AppSpacing.vSm,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('الإصدار ${report.definitionVersion}')),
              Chip(label: Text('الحد ${report.maxRecords} سجل')),
              Chip(label: Text(report.artifactFormat)),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: CustomButton.primary(
              text: 'إنشاء التقرير',
              prefix: Icons.play_arrow_rounded,
              onPressed: busy ? null : onRun,
              loading: busy,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ReportRunPanel extends StatelessWidget {
  const _ReportRunPanel({
    required this.run,
    required this.refreshing,
    required this.downloading,
    required this.onRefresh,
    required this.onDownload,
  });

  final ReportRun run;
  final bool refreshing;
  final bool downloading;
  final VoidCallback onRefresh;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('حالة التقرير: ${run.title}', style: Theme.of(context).textTheme.titleMedium),
          AppSpacing.vXs,
          Text(run.statusLabel),
          if (run.isFailed && run.errorMessage != null) Text(run.errorMessage!),
          if (run.isCompleted) ...[
            Text('عدد السجلات: ${run.recordsCount}'),
            if (run.isTruncated) const Text('النتيجة محدودة بالحد الأقصى المسموح.'),
          ],
          AppSpacing.vSm,
          Wrap(
            spacing: 8,
            children: [
              CustomButton.secondary(
                text: 'تحديث الحالة',
                prefix: Icons.refresh_rounded,
                onPressed: refreshing ? null : onRefresh,
                loading: refreshing,
              ),
              if (run.isCompleted)
                CustomButton.primary(
                  text: 'تنزيل JSON',
                  prefix: Icons.download_rounded,
                  onPressed: downloading ? null : onDownload,
                  loading: downloading,
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
