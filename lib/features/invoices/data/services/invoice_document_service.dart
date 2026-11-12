import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:dio/dio.dart';
import 'package:document_engine/document_engine.dart';
import 'package:flutter/services.dart';
import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/core/services/document_engine_font_service.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:printing/printing.dart';

/// Application adapter for official invoice documents.
class InvoiceDocumentService {
  InvoiceDocumentService._();

  static final InvoiceDocumentService instance = InvoiceDocumentService._();

  Future<Uint8List>? _applicationIconFuture;

  Future<Uint8List> generateInvoicePdf(InvoiceEntity invoice) async {
    final brand = _resolveBrandContext(invoice);
    final logoBytes = await _resolveLogoBytes(brand.logoUrl);
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
      snapshot: _buildSnapshot(invoice),
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

  DocumentSnapshot _buildSnapshot(InvoiceEntity invoice) {
    final reference = _fileReference(invoice);
    final paymentLabel = _paymentLabel(invoice);
    final info = <DocumentInfoItem>[
      DocumentInfoItem(
        label: 'الشبكة المورّدة',
        value: DocumentTextValue(_display(invoice.networkName, 'شبكة #' + invoice.networkId.toString())),
        direction: DocumentTextDirection.rightToLeft,
      ),
      DocumentInfoItem(
        label: 'نقطة البيع',
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
        label: 'معرّف الشبكة',
        value: DocumentTextValue('#' + invoice.networkId.toString()),
        direction: DocumentTextDirection.leftToRight,
      ),
      DocumentInfoItem(
        label: 'معرّف نقطة البيع',
        value: DocumentTextValue('#' + invoice.posId.toString()),
        direction: DocumentTextDirection.leftToRight,
      ),
      if (invoice.posPhoneNumber?.trim().isNotEmpty ?? false)
        DocumentInfoItem(
          label: 'هاتف نقطة البيع',
          value: DocumentTextValue(invoice.posPhoneNumber!.trim()),
          direction: DocumentTextDirection.leftToRight,
        ),
      if (invoice.requestId != null)
        DocumentInfoItem(
          label: 'طلب التوريد المرتبط',
          value: DocumentTextValue('#' + invoice.requestId.toString()),
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
            value: DocumentTextValue(_amount(item.voucherPrice)),
            direction: DocumentTextDirection.leftToRight,
          ),
          DocumentTableCell(
            value: DocumentTextValue(item.voucherCount.toString()),
            direction: DocumentTextDirection.leftToRight,
          ),
          DocumentTableCell(
            value: DocumentTextValue(_amount(item.itemDiscount)),
            direction: DocumentTextDirection.leftToRight,
          ),
          DocumentTableCell(
            value: DocumentTextValue(_amount(item.itemTotalAmount)),
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
            DocumentHeading(text: 'فاتورة مبيعات تجارية', level: 1, direction: DocumentTextDirection.rightToLeft),
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
                  value: DocumentTextValue(_amount(invoice.invoiceTotalAmount)),
                  emphasis: DocumentFinancialEmphasis.total,
                ),
                DocumentFinancialLine(
                  label: 'المبلغ المسدد',
                  value: DocumentTextValue(_amount(invoice.paidAmount)),
                  emphasis: DocumentFinancialEmphasis.secondary,
                ),
                DocumentFinancialLine(
                  label: 'المبلغ المتبقي',
                  value: DocumentTextValue(_amount(invoice.remainingAmount)),
                  emphasis: DocumentFinancialEmphasis.outstanding,
                ),
              ],
            ),
            DocumentParagraph(
              text: 'تم نقل المبالغ كما وردت من الخادم دون إعادة احتساب أو تعديل داخل التطبيق.',
              direction: DocumentTextDirection.rightToLeft,
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
    final workspace = WorkspaceService.to;
    final memberships = SessionService.to.currentUser?.workspaceMemberships ?? const [];

    if (workspace.activeWorkspace == AppWorkspace.network) {
      final ids = memberships
          .where((membership) => membership.isNetwork && membership.tenantId > 0)
          .map((membership) => membership.tenantId)
          .toList(growable: false);
      if (workspace.resolveActiveNetworkId(ids) == invoice.networkId) {
        return _InvoiceBrandContext(
          organizationName: _display(invoice.networkName, 'شبكة #' + invoice.networkId.toString()),
          logoUrl: invoice.networkLogoUrl,
        );
      }
    }

    if (workspace.activeWorkspace == AppWorkspace.pos) {
      final ids = memberships
          .where((membership) => membership.isPos && membership.tenantId > 0)
          .map((membership) => membership.tenantId)
          .toList(growable: false);
      if (workspace.resolveActivePosId(ids) == invoice.posId) {
        return _InvoiceBrandContext(
          organizationName: _display(invoice.posName, 'نقطة بيع #' + invoice.posId.toString()),
          logoUrl: invoice.posLogoUrl,
        );
      }
    }

    // Never borrow another tenant's logo when workspace identity is ambiguous.
    return const _InvoiceBrandContext(organizationName: 'NetSales', logoUrl: null);
  }

  Future<Uint8List> _resolveLogoBytes(String? rawUrl) async {
    final tenantLogo = await _downloadTenantLogo(rawUrl);
    if (tenantLogo != null) return tenantLogo;
    return _loadApplicationIcon();
  }

  Future<Uint8List?> _downloadTenantLogo(String? rawUrl) async {
    final source = rawUrl?.trim();
    if (source == null || source.isEmpty) return null;
    final resolved = ApiService.resolveStorageUrl(source);
    final uri = Uri.tryParse(resolved);
    final apiUri = Uri.tryParse(ApiConstants.baseUrl);

    // Session headers must never be sent to an unrelated image host.
    if (uri == null ||
        apiUri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.origin != apiUri.origin) {
      return null;
    }

    try {
      final response = await ApiService.instance.dio.get<List<int>>(
        uri.toString(),
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          receiveTimeout: const Duration(seconds: 12),
          headers: const {'Accept': 'image/png,image/jpeg'},
        ),
      );
      final bytes = response.data;
      if (response.statusCode != 200 ||
          bytes == null ||
          bytes.isEmpty ||
          bytes.length > 2 * 1024 * 1024 ||
          !_isPngOrJpeg(bytes)) {
        return null;
      }
      return Uint8List.fromList(bytes);
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List> _loadApplicationIcon() async {
    final future = _applicationIconFuture ??= _readApplicationIcon();
    return Uint8List.fromList(await future);
  }

  Future<Uint8List> _readApplicationIcon() async {
    final data = await rootBundle.load('assets/images/brand_icon.png');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  static bool _isPngOrJpeg(List<int> bytes) {
    final png = bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A;
    final jpeg = bytes.length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF;
    return png || jpeg;
  }

  static String _colorHex(Color color) =>
      (color.toARGB32() & 0x00FFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();

  static String _amount(double value) => AmountFormatter.format(value.toString());

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
