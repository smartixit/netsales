import 'package:flutter/material.dart';
import 'package:document_engine/document_engine.dart';
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
        if (controller.engineDefinition.value != null && controller.selectedDefinition.value != null) {
          return _ReportConfigurationPanel(controller: controller);
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
            ...controller.catalog.map((report) => _ReportCatalogCard(
              report: report,
              busy: controller.isCreating.value,
              onRun: () => controller.configureReport(report),
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

class _ReportConfigurationPanel extends StatelessWidget {
  const _ReportConfigurationPanel({required this.controller});
  final NetworkReportsController controller;

  @override
  Widget build(BuildContext context) {
    final definition = controller.engineDefinition.value!;
    final report = controller.selectedDefinition.value!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: CustomButton.secondary(
            text: 'العودة إلى كتالوج التقارير',
            prefix: Icons.arrow_back_rounded,
            onPressed: () {
              controller.clearConfiguration();
            },
          ),
        ),
        AppSpacing.vMd,
        Expanded(
          child: ReportConfigurationStudio(
          definition: definition,
          criteria: controller.criteria.value,
          presentation: controller.presentation.value,
          resolveLabel: (context, key) => _reportLabel(report, key),
          onCriteriaChanged: controller.updateCriteria,
          onPresentationChanged: controller.updatePresentation,
          onPreview: controller.runConfiguredReport,
          isBusy: controller.isCreating.value,
          actionBuilder: (
            context, {
            required label,
            required icon,
            required onPressed,
            required secondary,
          }) => secondary
              ? CustomButton.secondary(
                  text: _reportLabel(report, label),
                  prefix: icon,
                  onPressed: onPressed,
                )
              : CustomButton.primary(
                  text: _reportLabel(report, label),
                  prefix: icon,
                  loading: controller.isCreating.value,
                  onPressed: onPressed,
                ),
          filterSectionBuilder: (
            context, {
            required definition,
            required criteria,
            required resolveLabel,
            required onChanged,
          }) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('مرشحات التقرير', style: Theme.of(context).textTheme.titleMedium),
                  AppSpacing.vSm,
                  for (final filter in definition.filters) ...[
                    CustomTextField(
                      controller: controller.textControllerFor(filter.id),
                      label: _reportLabel(report, filter.labelKey),
                      hint: filter.kind == ReportFilterKind.date ? 'YYYY-MM-DD' : null,
                      keyboardType: filter.kind == ReportFilterKind.integer
                          ? TextInputType.number
                          : TextInputType.text,
                      isRequired: filter.required,
                      onChanged: (value) {
                        ReportFilterValue? parsed;
                        if (value.trim().isNotEmpty) {
                          switch (filter.kind) {
                            case ReportFilterKind.integer:
                              final number = int.tryParse(value.trim());
                              if (number != null) parsed = ReportIntegerFilterValue(number);
                              break;
                            case ReportFilterKind.date:
                              final date = DateTime.tryParse(value.trim());
                              if (date != null) parsed = ReportDateFilterValue(date);
                              break;
                            case ReportFilterKind.text:
                              parsed = ReportTextFilterValue(value.trim());
                              break;
                            default:
                              parsed = ReportTextFilterValue(value.trim());
                              break;
                          }
                        }
                        controller.updateFilter(filter.id, parsed);
                      },
                    ),
                    AppSpacing.vSm,
                  ],
                  if (criteria.validateAgainst(definition).isNotEmpty)
                    Text(
                      'توجد مرشحات غير مكتملة أو غير صالحة.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
          ),
          presentationSectionBuilder: (
            context, {
            required definition,
            required presentation,
            required resolveLabel,
            required onChanged,
          }) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('إعدادات الإخراج', style: Theme.of(context).textTheme.titleMedium),
                  AppSpacing.vSm,
                  const Text('يتم حالياً إنشاء لقطة بيانات JSON من الخادم. ستظهر خيارات القوالب وPDF بعد اعتماد قوالب المستندات ودعم RTL الإنتاجي.'),
                  AppSpacing.vSm,
                  Text('صيغة الإخراج: ${report.artifactFormat}'),
                ],
              ),
            ),
          ),
          ),
        ),
      ],
    );
  }
}

String _reportLabel(ReportCatalogItem report, String key) {
  if (key == 'report_title.${report.key}') return report.title;
  if (key == 'report_description.${report.key}') return report.description;
  if (key.startsWith('report_filter.')) {
    final field = key.substring('report_filter.'.length);
    return switch (field) {
      'billing_account_id' => 'معرّف حساب الفوترة',
      'from' || 'from_date' => 'من تاريخ',
      'to' || 'to_date' => 'إلى تاريخ',
      'currency_id' => 'معرّف العملة',
      'network_id' => 'معرّف الشبكة',
      'status' => 'الحالة',
      'search' => 'بحث',
      'payment_status' => 'حالة السداد',
      'sale_type' => 'نوع البيع',
      'invoice_id' => 'معرّف الفاتورة',
      'source_type' => 'نوع المصدر',
      _ => field,
    };
  }
  return switch (key) {
    'report_configuration.authorization_notice' => 'تظل صلاحيات الوصول ونطاق البيانات من اختصاص الخادم ولا تغيّرها خيارات العرض.',
    'report_configuration.schema_version' => 'مخطط',
    'report_configuration.server_execution' => 'تنفيذ على الخادم',
    'report_configuration.client_limit' => 'حد العميل',
    'report_configuration.data_criteria' => 'مرشحات التقرير',
    'report_configuration.data_criteria_hint' => 'حدد المعايير التي سيطبقها الخادم عند إنشاء التقرير.',
    'report_configuration.no_filters' => 'لا توجد مرشحات لهذا التقرير.',
    'report_configuration.output_design' => 'إعدادات الإخراج',
    'report_configuration.output_design_hint' => 'خيارات عرض التقرير وقوالبه.',
    'report_configuration.output_columns' => 'الأعمدة',
    'report_configuration.include_metrics' => 'تضمين المؤشرات',
    'report_configuration.include_charts' => 'تضمين الرسوم',
    'report_configuration.sort_by' => 'ترتيب حسب',
    'report_configuration.sort_direction' => 'اتجاه الترتيب',
    'report_configuration.ascending' => 'تصاعدي',
    'report_configuration.descending' => 'تنازلي',
    'report_configuration.group_by' => 'تجميع حسب',
    'report_configuration.no_grouping' => 'بدون تجميع',
    'report_configuration.template' => 'قالب المستند',
    'report_configuration.language' => 'لغة التقرير',
    'report_configuration.page_profile' => 'حجم الصفحة',
    'report_configuration.save_preset' => 'حفظ الإعداد',
    'report_configuration.preview' => 'إنشاء التقرير',
    'report_configuration.from_date' => 'من تاريخ',
    'report_configuration.to_date' => 'إلى تاريخ',
    'common.required' => 'مطلوب',
    'report_configuration.records_count' => 'عدد السجلات',
    _ => key,
  };
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
              text: 'إعداد التقرير',
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
