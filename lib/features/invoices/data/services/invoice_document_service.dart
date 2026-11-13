import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:document_engine/document_engine.dart';
import 'package:netsales/core/services/document_engine_font_service.dart';
import 'package:netsales/core/services/document_engine_brand_asset_service.dart';
import 'package:netsales/core/services/official_document_artifact_service.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/invoices/data/models/invoice_model.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:printing/printing.dart';

/// Application adapter for official invoice documents.
class InvoiceDocumentService {
  InvoiceDocumentService._();

  static final InvoiceDocumentService instance = InvoiceDocumentService._();

  Future<Uint8List> generateInvoicePdf(InvoiceEntity invoice) async {
    final snapshots = OfficialDocumentArtifactService.instance;
    final issued = await snapshots.createSnapshot(
      documentType: 'sale_invoice',
      documentId: invoice.invoiceId,
      networkId: invoice.networkId,
      posId: invoice.posId,
      templateId: 'netsales.invoice.executive',
      templateVersion: '1.0.0',
    );

    final existingArtifact = await snapshots.downloadIfReady(issued);
    if (existingArtifact != null) return existingArtifact;

    final source = Map<String, dynamic>.from(issued['source_snapshot'] as Map);
    final officialInvoice = InvoiceModel.fromJson(source);
    final renderedBytes = await _renderInvoicePdf(
      officialInvoice,
      currencyCode: snapshots.requireCurrencyCode(issued),
    );
    return snapshots.uploadArtifact(
      snapshotUuid: issued['snapshot_uuid'].toString(),
      pdfBytes: renderedBytes,
      fileName: _fileName(officialInvoice),
    );
  }

  Future<Uint8List> _renderInvoicePdf(
    InvoiceEntity invoice, {
    required String currencyCode,
  }) async {
    final brand = _resolveBrandContext(invoice);
    final logoBytes = await DocumentEngineBrandAssetService.instance
        .resolveLogoBytes(brand.logoUrl);
    final fontService = DocumentEngineFontService.instance;
    final brandingFonts = await fontService.loadArabicBrandingFonts();
    final shapingProvider = await fontService.arabicTextShapingProvider();
    final branding = DocumentBranding(
      organizationName: brand.organizationName,
      tagline: 'إدارة مبيعات الشبكات ونقاط البيع',
      primaryColor: _colorHex(AppColors.lightColors.primary),
      secondaryColor: _colorHex(AppColors.lightColors.secondary),
      accentColor: _colorHex(AppColors.lightColors.tertiary),
      surfaceColor: _colorHex(AppColors.lightColors.surface),
      textColor: _colorHex(AppColors.lightColors.onSurface),
      mutedTextColor: _colorHex(AppColors.lightColors.onSurfaceVariant),
      logoBytes: logoBytes,
      fonts: brandingFonts,
    );

    final result = await PdfDocumentRenderer(
      textShapingProvider: shapingProvider,
    ).render(
      snapshot: _buildSnapshot(invoice, currencyCode),
      template: _invoiceTemplate,
      options: DocumentRenderOptions(
        pageProfile: DocumentPageProfile.a4Portrait(
          marginTop: 38,
          marginRight: 36,
          marginBottom: 42,
          marginLeft: 36,
        ),
        generatedAt: DateTime.now(),
        showPageNumbers: true,
        headerText: brand.organizationName + ' · فاتورة مبيعات',
        footerText: 'مستند إلكتروني صادر عن NetSales — القيم المالية من الخادم',
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
    throw StateError('تعذر إنشاء مستند الفاتورة.');
  }

  Future<FileExportResult> exportAndSaveInvoice(InvoiceEntity invoice) async {
    final bytes = await generateInvoicePdf(invoice);
    return FileExportService.instance.saveFile(
      bytes: bytes,
      fileName: _fileName(invoice),
      extension: 'pdf',
      folderName: 'Invoices',
      namingStrategy: FileNamingStrategy.invoice,
      autoOpen: true,
      showFeedback: false,
    );
  }

  Future<bool> shareInvoice(InvoiceEntity invoice) async {
    final bytes = await generateInvoicePdf(invoice);
    return FileExportService.instance.shareBytes(
      bytes: bytes,
      fileName: _fileName(invoice),
      extension: 'pdf',
      namingStrategy: FileNamingStrategy.invoice,
    );
  }

  Future<bool> printInvoice(InvoiceEntity invoice) async {
    final bytes = await generateInvoicePdf(invoice);
    return Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: _fileName(invoice) + '.pdf',
    );
  }

  DocumentSnapshot _buildSnapshot(InvoiceEntity invoice, String currencyCode) {
    final reference = _fileReference(invoice);
    final paymentLabel = _paymentLabel(invoice);
    final info = <DocumentInfoItem>[
      DocumentInfoItem(
        label: 'الشبكة المورّدة',
        value: DocumentTextValue(_display(invoice.networkName, 'شبكة #' + invoice.networkId.toString())),
        direction: DocumentTextDirection.rightToLeft,
      ),
      DocumentInfoItem(
        label: 'العميل / نقطة البيع',
        value: DocumentTextValue(_display(invoice.posName, 'نقطة بيع #' + invoice.posId.toString())),
        direction: DocumentTextDirection.rightToLeft,
      ),
      DocumentInfoItem(
        label: 'رقم الفاتورة',
        value: DocumentTextValue(reference),
        direction: DocumentTextDirection.leftToRight,
      ),
      DocumentInfoItem(
        label: 'تاريخ الإصدار',
        value: DocumentTextValue(_display(invoice.invoiceDate ?? invoice.createdAt)),
        direction: DocumentTextDirection.leftToRight,
      ),
      DocumentInfoItem(
        label: 'نوع البيع',
        value: DocumentTextValue(_display(invoice.saleTypeLabel ?? invoice.saleTypeRaw)),
        direction: DocumentTextDirection.rightToLeft,
      ),
      DocumentInfoItem(
        label: 'حالة السداد',
        value: DocumentTextValue(paymentLabel),
        direction: DocumentTextDirection.rightToLeft,
      ),
      DocumentInfoItem(
        label: 'العملة',
        value: DocumentTextValue(currencyCode),
        direction: DocumentTextDirection.leftToRight,
      ),
      if (invoice.createdByName?.trim().isNotEmpty ?? false)
        DocumentInfoItem(
          label: 'أُصدرت بواسطة',
          value: DocumentTextValue(invoice.createdByName!.trim()),
          direction: DocumentTextDirection.rightToLeft,
        ),
      DocumentInfoItem(
        label: 'معرّف الشبكة',
        value: DocumentTextValue('#' + invoice.networkId.toString()),
        direction: DocumentTextDirection.leftToRight,
      ),
      DocumentInfoItem(
        label: 'معرّف نقطة البيع',
        value: DocumentTextValue('#' + invoice.posId.toString()),
        direction: DocumentTextDirection.leftToRight,
      ),
      if (_hasText(invoice.networkPhoneNumber))
        DocumentInfoItem(
          label: 'هاتف الشبكة المورّدة',
          value: DocumentTextValue(invoice.networkPhoneNumber!.trim()),
          direction: DocumentTextDirection.leftToRight,
        ),
      if (_hasText(invoice.networkEmail))
        DocumentInfoItem(
          label: 'البريد الإلكتروني للشبكة',
          value: DocumentTextValue(invoice.networkEmail!.trim()),
          direction: DocumentTextDirection.leftToRight,
        ),
      if (_hasText(invoice.networkAddress))
        DocumentInfoItem(
          label: 'عنوان الشبكة المورّدة',
          value: DocumentTextValue(invoice.networkAddress!.trim()),
          direction: DocumentTextDirection.rightToLeft,
        ),
      if (_hasText(invoice.posPhoneNumber))
        DocumentInfoItem(
          label: 'هاتف نقطة البيع',
          value: DocumentTextValue(invoice.posPhoneNumber!.trim()),
          direction: DocumentTextDirection.leftToRight,
        ),
      if (_hasText(invoice.posEmail))
        DocumentInfoItem(
          label: 'البريد الإلكتروني لنقطة البيع',
          value: DocumentTextValue(invoice.posEmail!.trim()),
          direction: DocumentTextDirection.leftToRight,
        ),
      if (_hasText(invoice.posAddress))
        DocumentInfoItem(
          label: 'عنوان نقطة البيع',
          value: DocumentTextValue(invoice.posAddress!.trim()),
          direction: DocumentTextDirection.rightToLeft,
        ),
      if (invoice.requestId != null)
        DocumentInfoItem(
          label: 'طلب التوريد المرتبط',
          value: DocumentTextValue(_display(invoice.requestUuid, '#' + invoice.requestId.toString())),
          direction: DocumentTextDirection.leftToRight,
        ),
    ];

    final rows = invoice.items.asMap().entries.map((entry) {
      final item = entry.value;
      return DocumentTableRow(
        id: 'line-' + (entry.key + 1).toString(),
        cells: [
          DocumentTableCell(
            value: DocumentTextValue(_display(item.packageName, 'باقة #' + item.packageId.toString())),
            direction: DocumentTextDirection.rightToLeft,
          ),
          DocumentTableCell(
            value: DocumentTextValue(_money(item.voucherPrice, currencyCode)),
            direction: DocumentTextDirection.leftToRight,
          ),
          DocumentTableCell(
            value: DocumentTextValue(item.voucherCount.toString()),
            direction: DocumentTextDirection.leftToRight,
          ),
          DocumentTableCell(
            value: DocumentTextValue(_money(item.itemDiscount, currencyCode)),
            direction: DocumentTextDirection.leftToRight,
          ),
          DocumentTableCell(
            value: DocumentTextValue(_money(item.itemTotalAmount, currencyCode)),
            direction: DocumentTextDirection.leftToRight,
          ),
        ],
      );
    }).toList(growable: false);

    final itemNodes = <DocumentNode>[
      DocumentHeading(text: 'تفاصيل البنود', level: 2, direction: DocumentTextDirection.rightToLeft),
      if (rows.isEmpty)
        DocumentCallout(
          title: 'لا توجد بنود متاحة',
          body: 'لم تتضمن استجابة تفاصيل الفاتورة أي بنود لعرضها.',
          tone: DocumentStatusTone.warning,
        )
      else
        DocumentTable(
          columns: [
            DocumentTableColumn(id: 'package', label: 'الباقة / الخدمة'),
            DocumentTableColumn(id: 'unit-price', label: 'السعر الإفرادي', alignment: DocumentCellAlignment.decimal),
            DocumentTableColumn(id: 'quantity', label: 'الكمية', alignment: DocumentCellAlignment.center),
            DocumentTableColumn(id: 'discount', label: 'الخصم', alignment: DocumentCellAlignment.decimal),
            DocumentTableColumn(id: 'line-total', label: 'إجمالي البند', alignment: DocumentCellAlignment.decimal),
          ],
          rows: rows,
          style: DocumentTableStyle(
            stripedRows: true,
            compact: true,
            showBorders: true,
            headerColor: 'E8F3EF',
            alternateRowColor: 'F7FAF9',
            columnWeights: const [3.1, 1.35, 0.8, 1.2, 1.45],
          ),
        ),
    ];

    return DocumentSnapshot(
      metadata: DocumentMetadata(
        id: DocumentId('netsales-invoice-' + invoice.invoiceId.toString()),
        documentTypeId: DocumentTypeId('netsales.sales-invoice'),
        title: 'فاتورة مبيعات رسمية',
        subtitle: 'فاتورة رقم ' + reference,
        reference: reference,
        locale: DocumentLocale(languageTag: 'ar-YE', direction: DocumentTextDirection.rightToLeft),
        createdAt: _parseDate(invoice.invoiceDate) ?? _parseDate(invoice.createdAt),
      ),
      sections: [
        DocumentSection(
          id: 'invoice-overview',
          title: 'البيانات الأساسية',
          nodes: [
            DocumentHeading(text: 'فاتورة مبيعات تجارية', level: 1, direction: DocumentTextDirection.rightToLeft, weight: DocumentTextWeight.bold),
            DocumentStatusBanner(
              label: paymentLabel,
              tone: invoice.isPaid
                  ? DocumentStatusTone.success
                  : invoice.isUnpaid
                      ? DocumentStatusTone.warning
                      : DocumentStatusTone.info,
              detail: 'المرجع: ' + reference,
            ),
            DocumentInfoGrid(items: info, columns: 3, compact: true),
          ],
        ),
        DocumentSection(id: 'invoice-items', title: 'البنود', nodes: itemNodes),
        DocumentSection(
          id: 'invoice-financial-summary',
          title: 'الملخص المالي',
          nodes: [
            DocumentFinancialSummary(
              title: 'ملخص المبالغ المعتمدة',
              lines: [
                DocumentFinancialLine(
                  label: 'إجمالي الفاتورة',
                  value: DocumentTextValue(_money(invoice.invoiceTotalAmount, currencyCode)),
                  emphasis: DocumentFinancialEmphasis.total,
                ),
                DocumentFinancialLine(
                  label: 'المبلغ المسدد',
                  value: DocumentTextValue(_money(invoice.paidAmount, currencyCode)),
                  emphasis: DocumentFinancialEmphasis.secondary,
                ),
                DocumentFinancialLine(
                  label: 'المبلغ المتبقي',
                  value: DocumentTextValue(_money(invoice.remainingAmount, currencyCode)),
                  emphasis: DocumentFinancialEmphasis.outstanding,
                ),
              ],
            ),
            DocumentParagraph(
              text: 'تم نقل المبالغ كما وردت من الخادم دون إعادة احتساب أو تعديل داخل التطبيق.',
              direction: DocumentTextDirection.rightToLeft,
              weight: DocumentTextWeight.light,
            ),
          ],
        ),
      ],
    );
  }

  DocumentTemplateDefinition get _invoiceTemplate => DocumentTemplateDefinition(
    id: TemplateId('netsales.invoice.executive'),
    version: TemplateVersion(major: 1, minor: 0, patch: 0),
    documentTypeId: DocumentTypeId('netsales.sales-invoice'),
    displayName: 'NetSales Executive Invoice',
    description: 'Official Arabic B2B sales invoice',
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

  _InvoiceBrandContext _resolveBrandContext(InvoiceEntity invoice) {
    // The network is the commercial supplier on every invoice, including POS workspace.
    // POS identity remains a customer/recipient field inside the document body.
    return _InvoiceBrandContext(
      organizationName: _display(
        invoice.networkName,
        'شبكة #' + invoice.networkId.toString(),
      ),
      logoUrl: invoice.networkLogoUrl,
    );
  }

  static String _colorHex(Color color) =>
      (color.toARGB32() & 0x00FFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();

  static bool _hasText(String? value) => value?.trim().isNotEmpty ?? false;

  static String _amount(double value) => AmountFormatter.format(value.toString());

  static String _money(double value, String currencyCode) =>
      _amount(value) + ' ' + currencyCode;

  static String _display(String? value, [String fallback = '—']) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? fallback : normalized;
  }

  static String _fileReference(InvoiceEntity invoice) =>
      _display(invoice.invoiceUuid, '#' + invoice.invoiceId.toString());

  static String _fileName(InvoiceEntity invoice) => 'فاتورة_' + _fileReference(invoice);

  static DateTime? _parseDate(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    return DateTime.tryParse(normalized);
  }

  static String _paymentLabel(InvoiceEntity invoice) {
    final serverLabel = invoice.paymentStatusLabel?.trim();
    if (serverLabel != null && serverLabel.isNotEmpty) return serverLabel;
    if (invoice.isPaid) return 'مدفوعة';
    if (invoice.isUnpaid) return 'غير مدفوعة';
    if (invoice.isPartiallyPaid) return 'مدفوعة جزئياً';
    return 'حالة السداد غير محددة';
  }
}

final class _InvoiceBrandContext {
  const _InvoiceBrandContext({required this.organizationName, required this.logoUrl});
  final String organizationName;
  final String? logoUrl;
}
