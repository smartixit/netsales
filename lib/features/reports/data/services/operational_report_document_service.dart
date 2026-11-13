import 'package:netsales/features/reports/domain/entities/operational_report_filter_display.dart';
import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:document_engine/document_engine.dart';
import 'package:netsales/core/services/document_engine_brand_asset_service.dart';
import 'package:netsales/core/services/document_engine_font_service.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_summary.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_type.dart';
import 'package:printing/printing.dart';

/// Builds a branded executive PDF from server-calculated report aggregates.
/// Detailed row exports remain available through the server CSV export job.
class OperationalReportDocumentService {
  OperationalReportDocumentService._();

  static final OperationalReportDocumentService instance =
      OperationalReportDocumentService._();

  Future<Uint8List> generateSummaryPdf({
    required OperationalReportType type,
    required String pageProfileId,
    required OperationalReportSummary summary,
    required String organizationName,
    String? logoUrl,
    required List<OperationalReportFilterDisplay> activeFilters,
    String? scopeLabel,
  }) async {
    final normalizedOrganization = _display(organizationName, 'NetSales');
    final logoBytes = await DocumentEngineBrandAssetService.instance
        .resolveLogoBytes(logoUrl);
    final fontService = DocumentEngineFontService.instance;
    final brandingFonts = await fontService.loadArabicBrandingFonts();
    final shapingProvider = await fontService.arabicTextShapingProvider();

    final branding = DocumentBranding(
      organizationName: normalizedOrganization,
      tagline: 'التقارير التشغيلية — NetSales',
      primaryColor: _colorHex(AppColors.lightColors.primary),
      secondaryColor: _colorHex(AppColors.lightColors.secondary),
      accentColor: _colorHex(AppColors.lightColors.tertiary),
      surfaceColor: _colorHex(AppColors.lightColors.surface),
      textColor: _colorHex(AppColors.lightColors.onSurface),
      mutedTextColor: _colorHex(AppColors.lightColors.onSurfaceVariant),
      logoBytes: logoBytes,
      fonts: brandingFonts,
    );

    final pageProfile = _resolvePageProfile(pageProfileId);

    final generatedAt = DateTime.now();
    final snapshot = _buildSnapshot(
      type: type,
      summary: summary,
      organizationName: normalizedOrganization,
      activeFilters: activeFilters,
      scopeLabel: scopeLabel,
      generatedAt: generatedAt,
    );

    final result = await PdfDocumentRenderer(
      textShapingProvider: shapingProvider,
    ).render(
      snapshot: snapshot,
      template: _template,
      options: DocumentRenderOptions(
        pageProfile: pageProfile,
        generatedAt: generatedAt,
        showPageNumbers: true,
        headerText: normalizedOrganization + ' · ' + _reportTitle(summary, type),
        footerText:
            'ملخص تنفيذي محسوب على كامل النتائج المطابقة للفلاتر المحددة',
        watermark: DocumentWatermark(
          imageBytes: logoBytes,
          opacity: 0.075,
          angleRadians: -0.6108652381980153,
          widthFactor: 0.58,
          heightFactor: 0.46,
        ),
        branding: branding,
        maxPages: 20,
      ),
    );

    if (result is DocumentRenderSuccess) return result.artifact.bytes;
    if (result is DocumentRenderFailure) {
      throw StateError(result.message);
    }
    throw StateError('تعذر إنشاء ملخص التقرير بصيغة PDF.');
  }

  Future<FileExportResult> exportAndSaveSummary({
    required OperationalReportType type,
    required String pageProfileId,
    required OperationalReportSummary summary,
    required String organizationName,
    String? logoUrl,
    required List<OperationalReportFilterDisplay> activeFilters,
    String? scopeLabel,
  }) async {
    final bytes = await generateSummaryPdf(
      type: type,
      pageProfileId: pageProfileId,
      summary: summary,
      organizationName: organizationName,
      logoUrl: logoUrl,
      activeFilters: activeFilters,
      scopeLabel: scopeLabel,
    );
    return FileExportService.instance.saveFile(
      bytes: bytes,
      fileName: 'ملخص_' + type.wireValue,
      extension: 'pdf',
      folderName: 'Reports',
      namingStrategy: const FileNamingStrategy(appPrefix: 'NetSales_REP'),
      autoOpen: true,
      showFeedback: false,
    );
  }

  Future<bool> shareSummary({
    required OperationalReportType type,
    required String pageProfileId,
    required OperationalReportSummary summary,
    required String organizationName,
    String? logoUrl,
    required List<OperationalReportFilterDisplay> activeFilters,
    String? scopeLabel,
  }) async {
    final bytes = await generateSummaryPdf(
      type: type,
      pageProfileId: pageProfileId,
      summary: summary,
      organizationName: organizationName,
      logoUrl: logoUrl,
      activeFilters: activeFilters,
      scopeLabel: scopeLabel,
    );
    return FileExportService.instance.shareBytes(
      bytes: bytes,
      fileName: 'ملخص_' + type.wireValue,
      extension: 'pdf',
      namingStrategy: const FileNamingStrategy(appPrefix: 'NetSales_REP'),
    );
  }

  Future<bool> printSummary({
    required OperationalReportType type,
    required String pageProfileId,
    required OperationalReportSummary summary,
    required String organizationName,
    String? logoUrl,
    required List<OperationalReportFilterDisplay> activeFilters,
    String? scopeLabel,
  }) async {
    final bytes = await generateSummaryPdf(
      type: type,
      pageProfileId: pageProfileId,
      summary: summary,
      organizationName: organizationName,
      logoUrl: logoUrl,
      activeFilters: activeFilters,
      scopeLabel: scopeLabel,
    );
    return Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'ملخص_' + type.wireValue + '.pdf',
    );
  }

  DocumentPageProfile _resolvePageProfile(String pageProfileId) {
    return switch (pageProfileId) {
      'a4-portrait' => DocumentPageProfile.a4Portrait(
          marginTop: 38,
          marginRight: 36,
          marginBottom: 42,
          marginLeft: 36,
        ),
      'a4-landscape' => DocumentPageProfile.a4Landscape(
          marginTop: 34,
          marginRight: 34,
          marginBottom: 38,
          marginLeft: 34,
        ),
      _ => throw UnsupportedError(
          'ملف الصفحة غير مدعوم في محرك المستندات: $pageProfileId',
        ),
    };
  }

  DocumentSnapshot _buildSnapshot({
    required OperationalReportType type,
    required OperationalReportSummary summary,
    required String organizationName,
    required DateTime generatedAt,
    required List<OperationalReportFilterDisplay> activeFilters,
    String? scopeLabel,
  }) {
    final metrics = summary.metrics;
    final hasCurrencyMetrics = metrics.any((metric) => metric.isCurrency);
    final rawCurrencyCode = summary.values['currency_code'];
    String? currencyCode;

    if (hasCurrencyMetrics) {
      if (rawCurrencyCode is! String ||
          !RegExp(r'^[A-Z]{3}$').hasMatch(rawCurrencyCode.trim())) {
        throw StateError(
          'رمز العملة غير موجود أو غير صالح في استجابة التقرير.',
        );
      }
      currencyCode = rawCurrencyCode.trim();
    }

    final rows = metrics.map((metric) {
      final value = metric.isCurrency
          ? '${metric.value} $currencyCode'
          : metric.value;
      return DocumentTableRow(
        id: 'report-metric-${metric.id}',
        cells: [
          DocumentTableCell(
            value: DocumentTextValue(metric.label),
            direction: DocumentTextDirection.rightToLeft,
          ),
          DocumentTableCell(
            value: DocumentTextValue(value),
            direction: DocumentTextDirection.leftToRight,
          ),
        ],
      );
    }).toList(growable: false);

    final info = <DocumentInfoItem>[
      DocumentInfoItem(
        label: 'الجهة',
        value: DocumentTextValue(organizationName),
        direction: DocumentTextDirection.rightToLeft,
      ),
      DocumentInfoItem(
        label: 'نوع التقرير',
        value: DocumentTextValue(_reportTitle(summary, type)),
        direction: DocumentTextDirection.rightToLeft,
      ),
      if (_hasText(scopeLabel))
        DocumentInfoItem(
          label: 'نطاق البيانات',
          value: DocumentTextValue(scopeLabel!.trim()),
          direction: DocumentTextDirection.rightToLeft,
        ),
      DocumentInfoItem(
        label: 'تاريخ الإنشاء',
        value: DocumentTextValue(_date(generatedAt)),
        direction: DocumentTextDirection.leftToRight,
      ),
      for (final filter in activeFilters)
        DocumentInfoItem(
          label: filter.label,
          value: DocumentTextValue(filter.value),
          direction: DocumentTextDirection.rightToLeft,
        ),
    ];

    return DocumentSnapshot(
      metadata: DocumentMetadata(
        id: DocumentId(
          'netsales-operational-report-${type.wireValue}-${generatedAt.millisecondsSinceEpoch}',
        ),
        documentTypeId: DocumentTypeId('netsales.operational-report'),
        title: 'ملخص ' + _reportTitle(summary, type),
        subtitle: 'تقرير تنفيذي صادر عن NetSales',
        reference: type.wireValue,
        locale: DocumentLocale(
          languageTag: 'ar-YE',
          direction: DocumentTextDirection.rightToLeft,
        ),
        createdAt: generatedAt,
      ),
      sections: [
        DocumentSection(
          id: 'operational-report-summary',
          title: 'ملخص التقرير',
          nodes: [
            DocumentHeading(
              text: 'ملخص تنفيذي — ' + _reportTitle(summary, type),
              level: 1,
              direction: DocumentTextDirection.rightToLeft,
            ),
            DocumentStatusBanner(
              label: 'إجماليات معتمدة من الخادم',
              tone: DocumentStatusTone.success,
              detail:
                  'تشمل جميع السجلات المطابقة للفلاتر، وليس الصفحة الحالية فقط',
            ),
            DocumentInfoGrid(items: info, columns: 2, compact: true),
            if (summary.values['opening_balance_source'] == 'BACKFILLED')
              const DocumentCallout(
                title: 'رصيد افتتاحي معاد بناؤه',
                body:
                    'تم اشتقاق الرصيد الافتتاحي عند ترحيل سجل المحفظة من الرصيد الحالي والحركات المتاحة آنذاك. هذه القيمة توثّق إعادة البناء ولا تعني وجود كشف تاريخي مستقل موثق قبل الترحيل.',
                tone: DocumentStatusTone.warning,
              ),
            DocumentHeading(
              text: 'المؤشرات والإجماليات',
              level: 2,
              direction: DocumentTextDirection.rightToLeft,
            ),
            if (rows.isEmpty)
              const DocumentCallout(
                title: 'لا توجد مؤشرات',
                body: 'لم يرسل الخادم مؤشرات قابلة للعرض لهذا التقرير.',
                tone: DocumentStatusTone.neutral,
              )
            else
              DocumentTable(
                columns: const [
                  DocumentTableColumn(id: 'metric', label: 'المؤشر'),
                  DocumentTableColumn(
                    id: 'value',
                    label: 'القيمة',
                    alignment: DocumentCellAlignment.decimal,
                  ),
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
              ),
            const DocumentCallout(
              title: 'نطاق هذا المستند',
              body:
                  'يعرض هذا المستند ملخصاً مجمعاً محسوباً على كامل النتائج المطابقة. لتصدير التفاصيل الكاملة لكل سجل استخدم ملف CSV من شاشة التقارير.',
              tone: DocumentStatusTone.info,
            ),
            const DocumentParagraph(
              text:
                  'تم نقل القيم المالية من استجابة الخادم كما هي، دون إعادة احتسابها أو تعديلها داخل التطبيق.',
              direction: DocumentTextDirection.rightToLeft,
            ),
          ],
        ),
      ],
    );
  }

  DocumentTemplateDefinition get _template => DocumentTemplateDefinition(
    id: TemplateId('netsales.operational-report.executive'),
    version: TemplateVersion(major: 1, minor: 0, patch: 0),
    documentTypeId: DocumentTypeId('netsales.operational-report'),
    displayName: 'NetSales Executive Operational Report',
    description: 'Official Arabic executive report summary',
    supportedLocaleTags: const ['ar'],
    capabilities: TemplateCapabilities([
      TemplateCapability.pageNumbering,
      TemplateCapability.repeatingHeader,
      TemplateCapability.repeatingFooter,
      TemplateCapability.tables,
      TemplateCapability.watermark,
      TemplateCapability.portraitPage,
      TemplateCapability.landscapePage,
    ]),
    isDefault: true,
    layout: DocumentTemplateLayout.executive,
  );

  static String _reportTitle(
    OperationalReportSummary summary,
    OperationalReportType type,
  ) {
    final value = summary.reportTitle.trim();
    return value.isEmpty ? type.wireValue : value;
  }

  static String _colorHex(Color color) =>
      (color.toARGB32() & 0x00FFFFFF)
          .toRadixString(16)
          .padLeft(6, '0')
          .toUpperCase();

  static bool _hasText(String? value) =>
      value != null && value.trim().isNotEmpty;

  static String _display(String? value, [String fallback = '—']) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? fallback : normalized;
  }

  static String _date(DateTime value) =>
      value.toIso8601String().replaceFirst('T', ' ').substring(0, 19);
}
