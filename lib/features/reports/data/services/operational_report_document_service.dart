import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:document_engine/document_engine.dart';
import 'package:netsales/core/services/document_engine_brand_asset_service.dart';
import 'package:netsales/core/services/document_engine_font_service.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
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
    String? fromDate,
    String? toDate,
    String? scopeLabel,
    String? search,
    String? status,
    String? saleType,
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
      fromDate: fromDate,
      toDate: toDate,
      scopeLabel: scopeLabel,
      search: search,
      status: status,
      saleType: saleType,
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
    String? fromDate,
    String? toDate,
    String? scopeLabel,
    String? search,
    String? status,
    String? saleType,
  }) async {
    final bytes = await generateSummaryPdf(
      type: type,
      pageProfileId: pageProfileId,
      summary: summary,
      organizationName: organizationName,
      logoUrl: logoUrl,
      fromDate: fromDate,
      toDate: toDate,
      scopeLabel: scopeLabel,
      search: search,
      status: status,
      saleType: saleType,
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
    String? fromDate,
    String? toDate,
    String? scopeLabel,
    String? search,
    String? status,
    String? saleType,
  }) async {
    final bytes = await generateSummaryPdf(
      type: type,
      pageProfileId: pageProfileId,
      summary: summary,
      organizationName: organizationName,
      logoUrl: logoUrl,
      fromDate: fromDate,
      toDate: toDate,
      scopeLabel: scopeLabel,
      search: search,
      status: status,
      saleType: saleType,
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
    String? fromDate,
    String? toDate,
    String? scopeLabel,
    String? search,
    String? status,
    String? saleType,
  }) async {
    final bytes = await generateSummaryPdf(
      type: type,
      pageProfileId: pageProfileId,
      summary: summary,
      organizationName: organizationName,
      logoUrl: logoUrl,
      fromDate: fromDate,
      toDate: toDate,
      scopeLabel: scopeLabel,
      search: search,
      status: status,
      saleType: saleType,
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
    String? fromDate,
    String? toDate,
    String? scopeLabel,
    String? search,
    String? status,
    String? saleType,
  }) {
    final metrics = summary.metrics;
    final rawCurrencyCode = summary.values['currency_code'];
    if (rawCurrencyCode is! String ||
        !RegExp(r'^[A-Z]{3}
    final rows = metrics.indexed.map((entry) {
      final metric = entry.$2;
      final value = metric.isCurrency
          ? AmountFormatter.format(metric.value) + ' ' + currencyCode
          : metric.value;
      return DocumentTableRow(
        id: 'report-metric-' + entry.$1.toString(),
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
        label: 'من تاريخ',
        value: DocumentTextValue(_display(fromDate, 'بلا حد أدنى')),
        direction: DocumentTextDirection.leftToRight,
      ),
      DocumentInfoItem(
        label: 'إلى تاريخ',
        value: DocumentTextValue(_display(toDate, 'حتى تاريخ التصدير')),
        direction: DocumentTextDirection.leftToRight,
      ),
      DocumentInfoItem(
        label: 'تاريخ الإنشاء',
        value: DocumentTextValue(_date(generatedAt)),
        direction: DocumentTextDirection.leftToRight,
      ),
      if (_hasText(status))
        DocumentInfoItem(
          label: 'الحالة المحددة',
          value: DocumentTextValue(_statusLabel(status!.trim())),
          direction: DocumentTextDirection.rightToLeft,
        ),
      if (_hasText(saleType))
        DocumentInfoItem(
          label: type == OperationalReportType.requests ? 'نوع الطلب' : 'نوع البيع',
          value: DocumentTextValue(_saleTypeLabel(saleType!.trim())),
          direction: DocumentTextDirection.rightToLeft,
        ),
      if (_hasText(search))
        DocumentInfoItem(
          label: 'عبارة البحث',
          value: DocumentTextValue(search!.trim()),
          direction: DocumentTextDirection.rightToLeft,
        ),
    ];

    return DocumentSnapshot(
      metadata: DocumentMetadata(
        id: DocumentId(
          'netsales-operational-report-' +
              type.wireValue +
              '-' +
              generatedAt.millisecondsSinceEpoch.toString(),
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
              detail: 'تشمل جميع السجلات المطابقة للفلاتر، وليس الصفحة الحالية فقط',
            ),
            DocumentInfoGrid(items: info, columns: 2, compact: true),
            if (summary.values['opening_balance_source'] == 'BACKFILLED')
              const DocumentCallout(
                title: 'رصيد افتتاحي معاد بناؤه',
                body: 'تم اشتقاق الرصيد الافتتاحي عند ترحيل سجل المحفظة من الرصيد الحالي والحركات المتاحة آنذاك. هذه القيمة توثّق إعادة البناء ولا تعني وجود كشف تاريخي مستقل موثق قبل الترحيل.',
                tone: DocumentStatusTone.warning,
              ),
            DocumentHeading(
              text: 'المؤشرات والإجماليات',
              level: 2,
              direction: DocumentTextDirection.rightToLeft,
            ),
            DocumentTable(
              columns: [
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
            DocumentCallout(
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

  static String _statusLabel(String status) => switch (status) {
    'PAID' => 'مسددة',
    'PARTIALLY_PAID' => 'مسددة جزئياً',
    'UNPAID' => 'غير مسددة',
    'DEPOSIT' => 'إيداع',
    'WITHDRAW' => 'سحب',
    'COMPLETED' => 'مكتمل',
    'REVERSED' => 'معكوس',
    'PENDING' => 'قيد الانتظار',
    'APPROVED' => 'معتمد',
    'REJECTED' => 'مرفوض',
    'CANCELLED' => 'ملغى',
    _ => status,
  };

  static String _saleTypeLabel(String value) => switch (value) {
    'CASH' => 'نقدي',
    'CREDIT' => 'آجل',
    _ => value,
  };

  static String _display(String? value, [String fallback = '—']) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? fallback : normalized;
  }

  static String _date(DateTime value) =>
      value.toIso8601String().replaceFirst('T', ' ').substring(0, 19);
}
).hasMatch(rawCurrencyCode.trim())) {
      throw StateError('رمز العملة غير موجود أو غير صالح في استجابة التقرير.');
    }
    final currencyCode = rawCurrencyCode.trim();
    final rows = metrics.indexed.map((entry) {
      final metric = entry.$2;
      final value = metric.isCurrency
          ? AmountFormatter.format(metric.value) + ' ' + currencyCode
          : metric.value;
      return DocumentTableRow(
        id: 'report-metric-' + entry.$1.toString(),
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
        label: 'من تاريخ',
        value: DocumentTextValue(_display(fromDate, 'بلا حد أدنى')),
        direction: DocumentTextDirection.leftToRight,
      ),
      DocumentInfoItem(
        label: 'إلى تاريخ',
        value: DocumentTextValue(_display(toDate, 'حتى تاريخ التصدير')),
        direction: DocumentTextDirection.leftToRight,
      ),
      DocumentInfoItem(
        label: 'تاريخ الإنشاء',
        value: DocumentTextValue(_date(generatedAt)),
        direction: DocumentTextDirection.leftToRight,
      ),
      if (_hasText(status))
        DocumentInfoItem(
          label: 'الحالة المحددة',
          value: DocumentTextValue(_statusLabel(status!.trim())),
          direction: DocumentTextDirection.rightToLeft,
        ),
      if (_hasText(saleType))
        DocumentInfoItem(
          label: type == OperationalReportType.requests ? 'نوع الطلب' : 'نوع البيع',
          value: DocumentTextValue(_saleTypeLabel(saleType!.trim())),
          direction: DocumentTextDirection.rightToLeft,
        ),
      if (_hasText(search))
        DocumentInfoItem(
          label: 'عبارة البحث',
          value: DocumentTextValue(search!.trim()),
          direction: DocumentTextDirection.rightToLeft,
        ),
    ];

    return DocumentSnapshot(
      metadata: DocumentMetadata(
        id: DocumentId(
          'netsales-operational-report-' +
              type.wireValue +
              '-' +
              generatedAt.millisecondsSinceEpoch.toString(),
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
              detail: 'تشمل جميع السجلات المطابقة للفلاتر، وليس الصفحة الحالية فقط',
            ),
            DocumentInfoGrid(items: info, columns: 2, compact: true),
            if (summary.values['opening_balance_source'] == 'BACKFILLED')
              const DocumentCallout(
                title: 'رصيد افتتاحي معاد بناؤه',
                body: 'تم اشتقاق الرصيد الافتتاحي عند ترحيل سجل المحفظة من الرصيد الحالي والحركات المتاحة آنذاك. هذه القيمة توثّق إعادة البناء ولا تعني وجود كشف تاريخي مستقل موثق قبل الترحيل.',
                tone: DocumentStatusTone.warning,
              ),
            DocumentHeading(
              text: 'المؤشرات والإجماليات',
              level: 2,
              direction: DocumentTextDirection.rightToLeft,
            ),
            DocumentTable(
              columns: [
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
            DocumentCallout(
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

  static String _statusLabel(String status) => switch (status) {
    'PAID' => 'مسددة',
    'PARTIALLY_PAID' => 'مسددة جزئياً',
    'UNPAID' => 'غير مسددة',
    'DEPOSIT' => 'إيداع',
    'WITHDRAW' => 'سحب',
    'COMPLETED' => 'مكتمل',
    'REVERSED' => 'معكوس',
    'PENDING' => 'قيد الانتظار',
    'APPROVED' => 'معتمد',
    'REJECTED' => 'مرفوض',
    'CANCELLED' => 'ملغى',
    _ => status,
  };

  static String _saleTypeLabel(String value) => switch (value) {
    'CASH' => 'نقدي',
    'CREDIT' => 'آجل',
    _ => value,
  };

  static String _display(String? value, [String fallback = '—']) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? fallback : normalized;
  }

  static String _date(DateTime value) =>
      value.toIso8601String().replaceFirst('T', ' ').substring(0, 19);
}
