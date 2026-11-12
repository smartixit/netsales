import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:document_engine/document_engine.dart';
import 'package:netsales/core/enums/repayment_status.dart';
import 'package:netsales/core/services/document_engine_brand_asset_service.dart';
import 'package:netsales/core/services/document_engine_font_service.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';
import 'package:printing/printing.dart';

/// Generates the official printable receipt for a server-issued POS repayment.
class RepaymentDocumentService {
  RepaymentDocumentService._();

  static final RepaymentDocumentService instance =
      RepaymentDocumentService._();

  Future<Uint8List> generatePdf(
    PosRepaymentEntity repayment, {
    required bool isNetworkView,
  }) async {
    final reference = _reference(repayment);
    final organizationName = isNetworkView
        ? _display(repayment.networkName, 'شبكة #${repayment.networkId}')
        : _display(repayment.posName, 'نقطة بيع #${repayment.posId}');
    final logoUrl = isNetworkView
        ? repayment.networkLogoUrl
        : repayment.posLogoUrl;
    final logoBytes = await DocumentEngineBrandAssetService.instance
        .resolveLogoBytes(logoUrl);
    final fontService = DocumentEngineFontService.instance;
    final branding = DocumentBranding(
      organizationName: organizationName,
      tagline: 'نظام NetSales لإدارة المبيعات والتحصيل',
      primaryColor: _colorHex(AppColors.lightColors.primary),
      secondaryColor: _colorHex(AppColors.lightColors.secondary),
      accentColor: _colorHex(AppColors.lightColors.tertiary),
      surfaceColor: _colorHex(AppColors.lightColors.surface),
      textColor: _colorHex(AppColors.lightColors.onSurface),
      mutedTextColor: _colorHex(AppColors.lightColors.onSurfaceVariant),
      logoBytes: logoBytes,
      fonts: await fontService.loadArabicBrandingFonts(),
    );

    final snapshot = _buildSnapshot(repayment, reference);
    final generatedAt = DateTime.now();
    final result = await PdfDocumentRenderer(
      textShapingProvider: await fontService.arabicTextShapingProvider(),
    ).render(
      snapshot: snapshot,
      template: _template,
      options: DocumentRenderOptions(
        pageProfile: DocumentPageProfile.a4Portrait(
          marginTop: 38,
          marginRight: 36,
          marginBottom: 42,
          marginLeft: 36,
        ),
        generatedAt: generatedAt,
        showPageNumbers: true,
        headerText: '$organizationName · سند سداد',
        footerText: 'مستند صادر عن NetSales — بيانات السداد والتسويات من الخادم',
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

    if (result is DocumentRenderSuccess) return result.artifact.bytes;
    if (result is DocumentRenderFailure) throw StateError(result.message);
    throw StateError('تعذر إنشاء سند السداد.');
  }

  Future<FileExportResult> exportAndSave(
    PosRepaymentEntity repayment, {
    required bool isNetworkView,
  }) async {
    final bytes = await generatePdf(repayment, isNetworkView: isNetworkView);
    return FileExportService.instance.saveFile(
      bytes: bytes,
      fileName: _fileName(repayment),
      extension: 'pdf',
      folderName: 'Receipts',
      namingStrategy: const FileNamingStrategy(appPrefix: 'NetSales_REC'),
      autoOpen: true,
      showFeedback: false,
    );
  }

  Future<bool> share(
    PosRepaymentEntity repayment, {
    required bool isNetworkView,
  }) async {
    final bytes = await generatePdf(repayment, isNetworkView: isNetworkView);
    return FileExportService.instance.shareBytes(
      bytes: bytes,
      fileName: _fileName(repayment),
      extension: 'pdf',
      namingStrategy: const FileNamingStrategy(appPrefix: 'NetSales_REC'),
    );
  }

  Future<bool> print(
    PosRepaymentEntity repayment, {
    required bool isNetworkView,
  }) async {
    final bytes = await generatePdf(repayment, isNetworkView: isNetworkView);
    return Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: '${_fileName(repayment)}.pdf',
    );
  }

  DocumentSnapshot _buildSnapshot(
    PosRepaymentEntity repayment,
    String reference,
  ) {
    final status = repayment.typedStatus;
    final statusTone = switch (status) {
      RepaymentStatus.completed => DocumentStatusTone.success,
      RepaymentStatus.reversed => DocumentStatusTone.danger,
      RepaymentStatus.unknown => DocumentStatusTone.neutral,
    };
    final info = <DocumentInfoItem>[
      DocumentInfoItem(
        label: 'رقم السند',
        value: DocumentTextValue(reference),
        direction: DocumentTextDirection.leftToRight,
      ),
      DocumentInfoItem(
        label: 'تاريخ السداد',
        value: DocumentTextValue(
          _display(repayment.repaymentDate ?? repayment.createdAt),
        ),
        direction: DocumentTextDirection.leftToRight,
      ),
      DocumentInfoItem(
        label: 'وسيلة الدفع',
        value: DocumentTextValue(repayment.typedPaymentMethod.label),
        direction: DocumentTextDirection.rightToLeft,
      ),
      DocumentInfoItem(
        label: 'الشبكة',
        value: DocumentTextValue(
          _display(repayment.networkName, 'شبكة #${repayment.networkId}'),
        ),
        direction: DocumentTextDirection.rightToLeft,
      ),
      DocumentInfoItem(
        label: 'نقطة البيع',
        value: DocumentTextValue(
          _display(repayment.posName, 'نقطة بيع #${repayment.posId}'),
        ),
        direction: DocumentTextDirection.rightToLeft,
      ),
      if (_hasText(repayment.referenceNumber))
        DocumentInfoItem(
          label: 'رقم المرجع',
          value: DocumentTextValue(repayment.referenceNumber!.trim()),
          direction: DocumentTextDirection.leftToRight,
        ),
      if (repayment.remainingDebtAfter != null)
        DocumentInfoItem(
          label: 'المديونية بعد السداد',
          value: DocumentTextValue(
            _amount(repayment.remainingDebtAfter!),
          ),
          direction: DocumentTextDirection.leftToRight,
        ),
      if (repayment.posBalanceAfter != null)
        DocumentInfoItem(
          label: 'رصيد نقطة البيع بعد السداد',
          value: DocumentTextValue(_amount(repayment.posBalanceAfter!)),
          direction: DocumentTextDirection.leftToRight,
        ),
    ];

    final allocationRows = repayment.allocations.indexed.map((entry) {
      final allocation = entry.$2;
      return DocumentTableRow(
        id: 'allocation-${allocation.allocationId}',
        cells: [
          DocumentTableCell(
            value: DocumentTextValue(allocation.invoice.invoiceUuid),
            direction: DocumentTextDirection.leftToRight,
          ),
          DocumentTableCell(
            value: DocumentTextValue(_amount(allocation.allocatedAmount)),
            direction: DocumentTextDirection.leftToRight,
          ),
          DocumentTableCell(
            value: DocumentTextValue(allocation.invoice.invoiceDate),
            direction: DocumentTextDirection.leftToRight,
          ),
          DocumentTableCell(
            value: DocumentTextValue(allocation.invoice.paymentStatusLabel),
            direction: DocumentTextDirection.rightToLeft,
          ),
        ],
      );
    }).toList(growable: false);

    final nodes = <DocumentNode>[
      DocumentHeading(
        text: 'سند تحصيل وسداد مديونية',
        level: 1,
        direction: DocumentTextDirection.rightToLeft,
      ),
      DocumentStatusBanner(
        label: status.label,
        tone: statusTone,
        detail: 'رقم السند: $reference',
      ),
      DocumentInfoGrid(items: info, columns: 2, compact: true),
      DocumentFinancialSummary(
        title: 'قيمة السداد المسجلة',
        lines: [
          DocumentFinancialLine(
            label: 'مبلغ السداد',
            value: DocumentTextValue(_amount(repayment.amount)),
            emphasis: DocumentFinancialEmphasis.total,
          ),
        ],
      ),
      DocumentHeading(
        text: 'توزيعات السداد على الفواتير',
        level: 2,
        direction: DocumentTextDirection.rightToLeft,
      ),
      if (allocationRows.isEmpty)
        const DocumentCallout(
          title: 'لا توجد توزيعات متاحة',
          body: 'لم تتضمن استجابة الخادم توزيعات فواتير لهذا السند.',
          tone: DocumentStatusTone.neutral,
        )
      else
        DocumentTable(
          columns: const [
            DocumentTableColumn(id: 'invoice', label: 'رقم الفاتورة'),
            DocumentTableColumn(
              id: 'allocated',
              label: 'المبلغ المخصص',
              alignment: DocumentCellAlignment.decimal,
            ),
            DocumentTableColumn(id: 'date', label: 'تاريخ الفاتورة'),
            DocumentTableColumn(id: 'status', label: 'حالة الفاتورة'),
          ],
          rows: allocationRows,
          style: const DocumentTableStyle(
            stripedRows: true,
            compact: true,
            showBorders: true,
            headerColor: 'E8F3EF',
            alternateRowColor: 'F7FAF9',
            columnWeights: [2.1, 1.25, 1.2, 1.3],
          ),
        ),
      if (_hasText(repayment.notes))
        DocumentCallout(
          title: 'ملاحظات السند',
          body: repayment.notes!.trim(),
          tone: DocumentStatusTone.info,
        ),
      if (status == RepaymentStatus.reversed) ...[
        if (_hasText(repayment.reversalReason))
          DocumentCallout(
            title: 'سبب عكس السند',
            body: repayment.reversalReason!.trim(),
            tone: DocumentStatusTone.danger,
          ),
        if (_hasText(repayment.reversedAt))
          DocumentParagraph(
            text: 'تاريخ العكس: ${repayment.reversedAt}',
            direction: DocumentTextDirection.rightToLeft,
          ),
      ],
      const DocumentParagraph(
        text: 'يعرض هذا المستند المبلغ والتوزيعات كما وردت من الخادم. لا يعيد التطبيق احتساب التسويات أو الأرصدة.',
        direction: DocumentTextDirection.rightToLeft,
      ),
    ];

    return DocumentSnapshot(
      metadata: DocumentMetadata(
        id: DocumentId('netsales-repayment-${repayment.repaymentId}'),
        documentTypeId: DocumentTypeId('netsales.pos-repayment'),
        title: 'سند سداد رسمي',
        subtitle: 'سند رقم $reference',
        reference: reference,
        locale: DocumentLocale(
          languageTag: 'ar-YE',
          direction: DocumentTextDirection.rightToLeft,
        ),
        createdAt: _parseDate(repayment.repaymentDate) ??
            _parseDate(repayment.createdAt) ??
            DateTime.now(),
      ),
      sections: [
        DocumentSection(
          id: 'repayment-receipt',
          title: 'بيانات السداد',
          nodes: nodes,
        ),
      ],
    );
  }

  DocumentTemplateDefinition get _template => DocumentTemplateDefinition(
    id: TemplateId('netsales.repayment.receipt.executive'),
    version: TemplateVersion(major: 1, minor: 0, patch: 0),
    documentTypeId: DocumentTypeId('netsales.pos-repayment'),
    displayName: 'NetSales Repayment Receipt',
    description: 'Official Arabic POS debt repayment receipt',
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

  static String _reference(PosRepaymentEntity repayment) =>
      _display(repayment.repaymentUuid, '#${repayment.repaymentId}');

  static String _fileName(PosRepaymentEntity repayment) =>
      'سند_سداد_${_reference(repayment)}';

  static String _amount(double value) => AmountFormatter.format(value.toString());

  static bool _hasText(String? value) => value?.trim().isNotEmpty ?? false;

  static String _display(String? value, [String fallback = '—']) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? fallback : normalized;
  }

  static DateTime? _parseDate(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    return DateTime.tryParse(normalized);
  }

  static String _colorHex(Color color) =>
      (color.toARGB32() & 0x00FFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();
}
