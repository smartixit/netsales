import 'dart:ui' show Color;

import 'package:document_engine/document_engine.dart';
import 'package:netsales/core/services/document_engine_brand_asset_service.dart';
import 'package:netsales/core/services/document_engine_font_service.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_catalog.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_filter_display.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_record.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_summary.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_type.dart';

/// Renders a complete server-sourced report using ReportConfigurationStudio choices.
/// This renderer never derives financial totals or balances.
class DetailedOperationalReportDocumentService {
  DetailedOperationalReportDocumentService._();
  static final DetailedOperationalReportDocumentService instance =
      DetailedOperationalReportDocumentService._();

  static const int maxRows = 1500;
  static const int maxVisibleColumns = 12;
  static const int maxGroups = 100;

  Future<FileExportResult> exportAndSave({
    required OperationalReportType type,
    required OperationalReportCatalogEntry entry,
    required List<OperationalReportRecord> records,
    required ReportPresentationOptions presentation,
    required OperationalReportSummary summary,
    required String pageProfileId,
    required String organizationName,
    String? logoUrl,
    required List<OperationalReportFilterDisplay> activeFilters,
    String? scopeLabel,
  }) async {
    final definition = entry.definition;
    if (presentation.validateAgainst(definition).isNotEmpty) {
      throw StateError('إعدادات عرض التقرير لا تطابق تعريف التقرير الحالي.');
    }
    if (records.length > maxRows) {
      throw StateError('يتجاوز التقرير الحد الآمن لتوليد PDF؛ لم يتم إنشاء مستند جزئي.');
    }
    if (!definition.pageProfileIds.contains(pageProfileId)) {
      throw StateError('حجم الصفحة المحدد غير مسموح لهذا التقرير.');
    }

    final visibleIds = presentation.visibleColumnIds.isEmpty
        ? definition.columns.where((column) => column.visibleByDefault).map((column) => column.id).toSet()
        : presentation.visibleColumnIds.toSet();
    final visibleColumns = definition.columns.where((column) => visibleIds.contains(column.id)).toList(growable: false);
    if (visibleColumns.isEmpty || visibleColumns.length > maxVisibleColumns) {
      throw StateError('يجب اختيار عمود واحد على الأقل، وبحد أقصى 12 عموداً لملف PDF.');
    }

    final sortedRecords = _sortRecords(records, presentation.sorts);
    final groups = _groupRecords(sortedRecords, presentation.groupByFieldId);
    if (groups.length > maxGroups) {
      throw StateError('عدد مجموعات التقرير يتجاوز الحد الآمن للقالب؛ ألغِ التجميع أو اختر حقلاً أقل تنوعاً.');
    }

    final currencyCode = _currencyCode(summary);
    final generatedAt = DateTime.now();
    final organization = organizationName.trim().isEmpty ? 'NetSales' : organizationName.trim();
    final logoBytes = await DocumentEngineBrandAssetService.instance.resolveLogoBytes(logoUrl);
    final fontService = DocumentEngineFontService.instance;
    final branding = DocumentBranding(
      organizationName: organization,
      tagline: 'التقارير التشغيلية — NetSales',
      primaryColor: _colorHex(AppColors.lightColors.primary),
      secondaryColor: _colorHex(AppColors.lightColors.secondary),
      accentColor: _colorHex(AppColors.lightColors.tertiary),
      surfaceColor: _colorHex(AppColors.lightColors.surface),
      textColor: _colorHex(AppColors.lightColors.onSurface),
      mutedTextColor: _colorHex(AppColors.lightColors.onSurfaceVariant),
      logoBytes: logoBytes,
      fonts: await fontService.loadArabicBrandingFonts(),
    );

    final info = <DocumentInfoItem>[
      DocumentInfoItem(label: 'الجهة', value: DocumentTextValue(organization), direction: DocumentTextDirection.rightToLeft),
      DocumentInfoItem(label: 'التقرير', value: DocumentTextValue(entry.label), direction: DocumentTextDirection.rightToLeft),
      if (scopeLabel != null && scopeLabel.trim().isNotEmpty)
        DocumentInfoItem(label: 'نطاق البيانات', value: DocumentTextValue(scopeLabel.trim()), direction: DocumentTextDirection.rightToLeft),
      if (currencyCode != null)
        DocumentInfoItem(label: 'العملة', value: DocumentTextValue(currencyCode), direction: DocumentTextDirection.leftToRight),
      DocumentInfoItem(label: 'عدد السجلات', value: DocumentTextValue(records.length.toString()), direction: DocumentTextDirection.leftToRight),
      DocumentInfoItem(label: 'تاريخ الإنشاء', value: DocumentTextValue(_date(generatedAt)), direction: DocumentTextDirection.leftToRight),
      for (final filter in activeFilters)
        DocumentInfoItem(label: filter.label, value: DocumentTextValue(filter.value), direction: DocumentTextDirection.rightToLeft),
    ];

    final nodes = <DocumentNode>[
      DocumentHeading(text: 'تقرير تفصيلي — ${entry.label}', level: 1, direction: DocumentTextDirection.rightToLeft, weight: DocumentTextWeight.bold),
      DocumentStatusBanner(
        label: 'بيانات تفصيلية مسترجعة من الخادم',
        tone: DocumentStatusTone.success,
        detail: 'تم التحقق من أحدث سجل وملخص التقرير قبل إنشاء المستند',
      ),
      DocumentInfoGrid(items: info, columns: 3, compact: true),
    ];

    if (presentation.includeMetrics && summary.metrics.isNotEmpty) {
      nodes.add(DocumentHeading(text: 'المؤشرات والإجماليات', level: 2, direction: DocumentTextDirection.rightToLeft));
      nodes.add(_metricsTable(summary.metrics, currencyCode));
    }
    if (presentation.includeCharts) {
      nodes.addAll(_buildCharts(entry, summary));
    }

    if (records.isEmpty) {
      nodes.add(const DocumentCallout(
        title: 'لا توجد سجلات مطابقة',
        body: 'لم يُرجع الخادم سجلات تفصيلية للمرشحات المحددة.',
        tone: DocumentStatusTone.neutral,
      ));
    } else {
      nodes.add(DocumentHeading(text: 'تفاصيل السجلات', level: 2, direction: DocumentTextDirection.rightToLeft));
      for (var groupIndex = 0; groupIndex < groups.length; groupIndex++) {
        final group = groups.entries.elementAt(groupIndex);
        if (presentation.groupByFieldId != null) {
          nodes.add(DocumentHeading(
            text: '${_columnLabel(definition, entry, presentation.groupByFieldId!)}: ${group.key}',
            level: 3,
            direction: DocumentTextDirection.rightToLeft,
          ));
        }
        nodes.add(_recordsTable(
          definition: definition,
          entry: entry,
          columns: visibleColumns,
          records: group.value,
          groupIndex: groupIndex,
        ));
      }
    }

    nodes.add(const DocumentParagraph(
      text: 'القيم والتفاصيل من استجابة الخادم كما وردت. لم يجرِ التطبيق أي تجميع مالي أو إعادة احتساب للأرصدة أو الإجماليات.',
      direction: DocumentTextDirection.rightToLeft,
    ));

    final templateSelection = presentation.template ??
        (definition.templates.isEmpty ? null : definition.templates.first);
    final template = DocumentTemplateDefinition(
      id: templateSelection?.id ?? const TemplateId('netsales.operational-report.executive'),
      version: templateSelection?.version ?? const TemplateVersion(major: 1, minor: 0, patch: 0),
      documentTypeId: const DocumentTypeId('netsales.operational-report'),
      displayName: 'NetSales ${entry.label} Detailed Report',
      description: 'Detailed Arabic operational report',
      supportedLocaleTags: definition.supportedLocaleTags.toList(growable: false),
      capabilities: TemplateCapabilities([
        TemplateCapability.pageNumbering,
        TemplateCapability.repeatingHeader,
        TemplateCapability.repeatingFooter,
        TemplateCapability.tables,
        TemplateCapability.charts,
        TemplateCapability.watermark,
        TemplateCapability.portraitPage,
        TemplateCapability.landscapePage,
      ]),
      isDefault: true,
      layout: DocumentTemplateLayout.executive,
    );

    final snapshot = DocumentSnapshot(
      metadata: DocumentMetadata(
        id: DocumentId('netsales-operational-report-${type.wireValue}-${generatedAt.millisecondsSinceEpoch}'),
        documentTypeId: const DocumentTypeId('netsales.operational-report'),
        title: entry.label,
        subtitle: 'تقرير تشغيلي تفصيلي',
        reference: type.wireValue,
        locale: DocumentLocale(
          languageTag: presentation.languageTag ?? 'ar-YE',
          direction: DocumentTextDirection.rightToLeft,
        ),
        createdAt: generatedAt,
      ),
      sections: [
        DocumentSection(id: 'operational-report', title: entry.label, nodes: nodes),
      ],
    );

    final result = await PdfDocumentRenderer(
      textShapingProvider: await fontService.arabicTextShapingProvider(),
    ).render(
      snapshot: snapshot,
      template: template,
      options: DocumentRenderOptions(
        pageProfile: _pageProfile(pageProfileId),
        generatedAt: generatedAt,
        showPageNumbers: true,
        headerText: '$organization · ${entry.label}',
        footerText: 'NetSales — تقرير تشغيلي · ${currencyCode ?? 'بيانات غير نقدية'}',
        watermark: DocumentWatermark(
          imageBytes: logoBytes,
          opacity: 0.075,
          angleRadians: -0.6108652381980153,
          widthFactor: 0.58,
          heightFactor: 0.46,
        ),
        branding: branding,
        maxPages: 100,
      ),
    );

    if (result is DocumentRenderFailure) throw StateError(result.message);
    if (result is! DocumentRenderSuccess) {
      throw StateError('تعذر إنشاء التقرير التفصيلي بصيغة PDF.');
    }

    return FileExportService.instance.saveFile(
      bytes: result.artifact.bytes,
      fileName: 'تقرير_تفصيلي_${type.wireValue}',
      extension: 'pdf',
      folderName: 'Reports',
      namingStrategy: const FileNamingStrategy(appPrefix: 'NetSales_RPT'),
      autoOpen: true,
      showFeedback: false,
    );
  }

  DocumentTable _metricsTable(List<OperationalReportMetric> metrics, String? currencyCode) {
    final rows = metrics.map((metric) {
      final value = metric.isCurrency && currencyCode != null ? '${metric.value} $currencyCode' : metric.value;
      return DocumentTableRow(
        id: 'metric-${metric.id}',
        cells: [
          DocumentTableCell(value: DocumentTextValue(metric.label), direction: DocumentTextDirection.rightToLeft),
          DocumentTableCell(value: DocumentTextValue(value), direction: DocumentTextDirection.leftToRight),
        ],
      );
    }).toList(growable: false);
    return DocumentTable(
      columns: const [
        DocumentTableColumn(id: 'metric', label: 'المؤشر'),
        DocumentTableColumn(id: 'value', label: 'القيمة', alignment: DocumentCellAlignment.decimal),
      ],
      rows: rows,
      style: DocumentTableStyle(
        stripedRows: true,
        compact: true,
        showBorders: true,
        headerColor: 'E8F3EF',
        alternateRowColor: 'F7FAF9',
        columnWeights: const [2.4, 1.1],
      ),
    );
  }

  List<DocumentNode> _buildCharts(OperationalReportCatalogEntry entry, OperationalReportSummary summary) {
    final nodes = <DocumentNode>[];
    final chartValues = summary.charts;
    var omitted = 0;
    for (final slot in entry.chartSlots) {
      final rawPoints = chartValues[slot.id] ?? const <Map<String, dynamic>>[];
      final points = <DocumentChartPoint>[];
      for (final raw in rawPoints) {
        final rawValue = raw[slot.valueKey];
        final value = rawValue is num ? rawValue.toDouble() : double.tryParse(rawValue?.toString() ?? '');
        final label = raw[slot.labelKey]?.toString().trim() ?? '';
        if (value == null || !value.isFinite || label.isEmpty) continue;
        points.add(DocumentChartPoint(label: label, value: value, displayValue: rawValue.toString()));
      }
      final chartType = switch (slot.chartType) {
        'line' => DocumentChartType.line,
        'pie' => DocumentChartType.pie,
        'donut' => DocumentChartType.donut,
        _ => DocumentChartType.bar,
      };
      final maxPoints = chartType == DocumentChartType.pie || chartType == DocumentChartType.donut ? 12 : 24;
      if (points.isEmpty || points.length > maxPoints ||
          ((chartType == DocumentChartType.pie || chartType == DocumentChartType.donut) &&
              (points.any((point) => point.value < 0) || points.every((point) => point.value == 0)))) {
        omitted++;
        continue;
      }
      nodes.add(DocumentChart(
        title: slot.label,
        type: chartType,
        series: [DocumentChartSeries(id: slot.id, label: slot.label, points: points)],
      ));
    }
    if (omitted > 0) {
      nodes.add(const DocumentCallout(
        title: 'بعض الرسوم لم تُدرج',
        body: 'تجاوزت بعض السلاسل حدود النقاط أو احتوت قيماً لا يدعمها نوع الرسم. بقيت بيانات السجلات التفصيلية دون حذف.',
        tone: DocumentStatusTone.warning,
      ));
    }
    return nodes;
  }

  DocumentTable _recordsTable({
    required ReportDefinition definition,
    required OperationalReportCatalogEntry entry,
    required List<ReportColumnDefinition> columns,
    required List<OperationalReportRecord> records,
    required int groupIndex,
  }) {
    final tableColumns = columns.map((column) => DocumentTableColumn(
      id: column.id,
      label: _columnLabel(definition, entry, column.id),
      alignment: _alignment(column.dataType),
    )).toList(growable: false);
    final rows = records.asMap().entries.map((entryRow) {
      return DocumentTableRow(
        id: 'group-$groupIndex-row-${entryRow.key}',
        cells: columns.map((column) => DocumentTableCell(
          value: DocumentTextValue(_cellValue(entryRow.value, column)),
          direction: _direction(column.dataType),
        )).toList(growable: false),
      );
    }).toList(growable: false);
    final weights = columns.map((column) => column.dataType == ReportDataType.text ? 2.0 : 1.0).toList(growable: false);
    return DocumentTable(
      columns: tableColumns,
      rows: rows,
      style: DocumentTableStyle(
        stripedRows: true,
        compact: true,
        showBorders: true,
        headerColor: 'E8F3EF',
        alternateRowColor: 'F7FAF9',
        columnWeights: weights,
      ),
    );
  }

  List<OperationalReportRecord> _sortRecords(List<OperationalReportRecord> records, List<ReportSortOption> sorts) {
    if (sorts.isEmpty) return List<OperationalReportRecord>.of(records);
    final indexed = records.asMap().entries.toList(growable: false);
    indexed.sort((left, right) {
      for (final sort in sorts) {
        final comparison = _compareValues(left.value.valueAt(sort.fieldId), right.value.valueAt(sort.fieldId));
        if (comparison != 0) {
          return sort.direction == ReportSortDirection.ascending ? comparison : -comparison;
        }
      }
      return left.key.compareTo(right.key);
    });
    return indexed.map((entry) => entry.value).toList(growable: false);
  }

  int _compareValues(dynamic left, dynamic right) {
    if (left == null && right == null) return 0;
    if (left == null) return 1;
    if (right == null) return -1;
    final leftNumber = left is num ? left : num.tryParse(left.toString());
    final rightNumber = right is num ? right : num.tryParse(right.toString());
    if (leftNumber != null && rightNumber != null) return leftNumber.compareTo(rightNumber);
    final leftDate = DateTime.tryParse(left.toString());
    final rightDate = DateTime.tryParse(right.toString());
    if (leftDate != null && rightDate != null) return leftDate.compareTo(rightDate);
    if (left is bool && right is bool) return (left ? 1 : 0).compareTo(right ? 1 : 0);
    return left.toString().toLowerCase().compareTo(right.toString().toLowerCase());
  }

  Map<String, List<OperationalReportRecord>> _groupRecords(List<OperationalReportRecord> records, String? groupByFieldId) {
    if (groupByFieldId == null) return {'': records};
    final groups = <String, List<OperationalReportRecord>>{};
    for (final record in records) {
      final value = record.textAt(groupByFieldId, fallback: 'غير محدد');
      groups.putIfAbsent(value, () => <OperationalReportRecord>[]).add(record);
    }
    return groups;
  }

  String _cellValue(OperationalReportRecord record, ReportColumnDefinition column) {
    final value = record.valueAt(column.id);
    if (value == null) return '—';
    if (value is bool) return value ? 'نعم' : 'لا';
    if (value is DateTime) return value.toIso8601String();
    if (value is Map || value is List) return '—';
    final text = value.toString().trim();
    return text.isEmpty ? '—' : text;
  }

  String _columnLabel(ReportDefinition definition, OperationalReportCatalogEntry entry, String id) =>
      entry.columnLabels[id] ?? definition.column(id)?.labelKey ?? id;

  DocumentCellAlignment _alignment(ReportDataType type) => switch (type) {
    ReportDataType.integer || ReportDataType.decimal => DocumentCellAlignment.decimal,
    _ => DocumentCellAlignment.leading,
  };

  DocumentTextDirection _direction(ReportDataType type) => switch (type) {
    ReportDataType.integer || ReportDataType.decimal || ReportDataType.date || ReportDataType.dateTime =>
      DocumentTextDirection.leftToRight,
    _ => DocumentTextDirection.rightToLeft,
  };

  String? _currencyCode(OperationalReportSummary summary) {
    final hasCurrencyMetrics = summary.metrics.any((metric) => metric.isCurrency);
    final raw = summary.values['currency_code'];
    if (raw == null && !hasCurrencyMetrics) return null;
    if (raw is! String || !RegExp(r'^[A-Z]{3}$').hasMatch(raw.trim())) {
      throw StateError('رمز العملة غير موجود أو غير صالح في ملخص التقرير.');
    }
    return raw.trim();
  }

  DocumentPageProfile _pageProfile(String id) => switch (id) {
    'a4-portrait' => DocumentPageProfile.a4Portrait(marginTop: 38, marginRight: 36, marginBottom: 42, marginLeft: 36),
    'a4-landscape' => DocumentPageProfile.a4Landscape(marginTop: 34, marginRight: 34, marginBottom: 38, marginLeft: 34),
    _ => throw UnsupportedError('ملف الصفحة غير مدعوم: $id'),
  };

  String _date(DateTime value) => value.toIso8601String().replaceFirst('T', ' ').substring(0, 19);

  static String _colorHex(Color color) =>
      (color.toARGB32() & 0x00FFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();
}
