import 'package:document_engine/document_engine.dart';

/// Creates a new immutable presentation contract while retaining unchanged
/// values. The helper contains no UI or business execution logic.
ReportPresentationOptions copyReportPresentationOptions(
  ReportPresentationOptions current, {
  List<String>? visibleColumnIds,
  List<ReportSortOption>? sorts,
  String? groupByFieldId,
  bool clearGroupByFieldId = false,
  ReportTemplateSelection? template,
  bool clearTemplate = false,
  String? languageTag,
  String? pageProfileId,
  bool? includeMetrics,
  bool? includeCharts,
}) {
  return ReportPresentationOptions(
    visibleColumnIds: visibleColumnIds ?? current.visibleColumnIds,
    sorts: sorts ?? current.sorts,
    groupByFieldId: clearGroupByFieldId
        ? null
        : groupByFieldId ?? current.groupByFieldId,
    template: clearTemplate ? null : template ?? current.template,
    languageTag: languageTag ?? current.languageTag,
    pageProfileId: pageProfileId ?? current.pageProfileId,
    includeMetrics: includeMetrics ?? current.includeMetrics,
    includeCharts: includeCharts ?? current.includeCharts,
  );
}
