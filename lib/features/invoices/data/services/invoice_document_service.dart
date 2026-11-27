import 'dart:typed_data';

import 'package:document_engine/document_engine.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/services/document_engine_pdf_service.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/core/services/share_service.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';

/// Official invoice PDF generation, printing, sharing, and saving.
class InvoiceDocumentService {
  const InvoiceDocumentService();

  Future<Uint8List> generateInvoicePdfBytes(InvoiceEntity invoice) async {
    final generatedAt = DateTime.now();
    final branding = await DocumentEnginePdfService.instance.loadBranding(
      organizationName: 'NetSales',
      tagline: 'المستندات المالية الرسمية',
      logoUrl: invoice.networkLogo,
    );
    final status = EnumPresentationRegistry.resolveInvoicePaymentStatus(
      invoice.paymentStatus,
      serverLabel: invoice.paymentStatusLabel,
    );
    final saleType = EnumPresentationRegistry.resolveSaleType(
      invoice.saleType,
      serverLabel: invoice.saleTypeLabel,
    );
    final statusTone = invoice.isPaid
        ? DocumentStatusTone.success
        : (invoice.isPartiallyPaid
            ? DocumentStatusTone.warning
            : DocumentStatusTone.danger);

    final info = <DocumentInfoItem>[
      DocumentInfoItem(
        label: 'مرجع الفاتورة',
        value: DocumentTextValue(invoice.displayReference),
        direction: DocumentTextDirection.leftToRight,
      ),
      DocumentInfoItem(
        label: 'تاريخ الفاتورة',
        value: DocumentTextValue(invoice.formattedInvoiceDate),
        direction: DocumentTextDirection.leftToRight,
      ),
      DocumentInfoItem(
        label: 'نوع البيع',
        value: DocumentTextValue(saleType.label),
      ),
      DocumentInfoItem(
        label: 'الشبكة الموردة',
        value: DocumentTextValue(invoice.displayNetworkName),
      ),
      if (invoice.networkPhoneNumber != null)
        DocumentInfoItem(
          label: 'هاتف الشبكة',
          value: DocumentTextValue(invoice.networkPhoneNumber!),
          direction: DocumentTextDirection.leftToRight,
        ),
      DocumentInfoItem(
        label: 'نقطة البيع',
        value: DocumentTextValue(invoice.displayPosName),
      ),
      if (invoice.posPhoneNumber != null)
        DocumentInfoItem(
          label: 'هاتف نقطة البيع',
          value: DocumentTextValue(invoice.posPhoneNumber!),
          direction: DocumentTextDirection.leftToRight,
        ),
      if (invoice.createdByName != null)
        DocumentInfoItem(
          label: 'أُصدرت بواسطة',
          value: DocumentTextValue(invoice.createdByName!),
        ),
    ];

    final rows = invoice.items.asMap().entries.map((entry) {
      final item = entry.value;
      return DocumentTableRow(
        id: 'invoice-item-${entry.key + 1}',
        cells: [
          DocumentTableCell(
            value: DocumentTextValue(item.packageName),
            direction: DocumentTextDirection.rightToLeft,
          ),
          DocumentTableCell(
            value: DocumentTextValue(item.voucherCount.toString()),
            direction: DocumentTextDirection.leftToRight,
          ),
          DocumentTableCell(
            value: DocumentTextValue(item.formattedSheetsCount),
            direction: DocumentTextDirection.leftToRight,
          ),
          DocumentTableCell(
            value: DocumentTextValue(AmountFormatter.formatValue(item.voucherPrice)),
            direction: DocumentTextDirection.leftToRight,
          ),
          DocumentTableCell(
            value: DocumentTextValue(AmountFormatter.formatValue(item.itemDiscount)),
            direction: DocumentTextDirection.leftToRight,
          ),
          DocumentTableCell(
            value: DocumentTextValue(AmountFormatter.formatValue(item.itemTotalAmount)),
            direction: DocumentTextDirection.leftToRight,
          ),
        ],
      );
    });

    final snapshot = DocumentSnapshot(
      metadata: DocumentMetadata(
        id: DocumentId('netsales-invoice-${invoice.invoiceId}-${generatedAt.microsecondsSinceEpoch}'),
        documentTypeId: DocumentTypeId('netsales.invoice'),
        title: 'فاتورة مبيعات رسمية',
        subtitle: 'فاتورة مبيعات بين الشبكة ونقطة البيع',
        reference: invoice.displayReference,
        locale: DocumentLocale(
          languageTag: 'ar-YE',
          direction: DocumentTextDirection.rightToLeft,
        ),
        createdAt: generatedAt,
        timeZoneId: 'Asia/Aden',
      ),
      sections: [
        DocumentSection(
          id: 'invoice-parties-and-lines',
          title: 'بيانات الفاتورة',
          nodes: [
            DocumentStatusBanner(
              label: 'حالة السداد: ${status.label}',
              tone: statusTone,
              detail: 'نوع البيع: ${saleType.label}',
            ),
            DocumentInfoGrid(items: info, columns: 3),
            DocumentHeading(
              text: 'تفاصيل الباقات والكميات',
              level: 2,
              direction: DocumentTextDirection.rightToLeft,
            ),
            DocumentTable(
              columns: [
                DocumentTableColumn(id: 'package', label: 'الباقة'),
                DocumentTableColumn(
                  id: 'vouchers',
                  label: 'عدد الكروت',
                  alignment: DocumentCellAlignment.center,
                ),
                DocumentTableColumn(
                  id: 'sheets',
                  label: 'الأوراق',
                  alignment: DocumentCellAlignment.center,
                ),
                DocumentTableColumn(
                  id: 'price',
                  label: 'سعر الكرت',
                  alignment: DocumentCellAlignment.trailing,
                ),
                DocumentTableColumn(
                  id: 'discount',
                  label: 'الخصم',
                  alignment: DocumentCellAlignment.trailing,
                ),
                DocumentTableColumn(
                  id: 'total',
                  label: 'الإجمالي',
                  alignment: DocumentCellAlignment.trailing,
                ),
              ],
              rows: rows,
              style: DocumentTableStyle(
                stripedRows: true,
                compact: true,
                headerColor: 'E8F3EF',
                alternateRowColor: 'F7FAF9',
              ),
            ),
            DocumentFinancialSummary(
              title: 'ملخص المستحقات',
              lines: [
                DocumentFinancialLine(
                  label: 'إجمالي الفاتورة',
                  value: DocumentTextValue(AmountFormatter.formatValue(invoice.invoiceTotalAmount)),
                  emphasis: DocumentFinancialEmphasis.total,
                ),
                DocumentFinancialLine(
                  label: 'المدفوع',
                  value: DocumentTextValue(AmountFormatter.formatValue(invoice.paidAmount)),
                ),
                DocumentFinancialLine(
                  label: 'المتبقي',
                  value: DocumentTextValue(AmountFormatter.formatValue(invoice.remainingAmount)),
                  emphasis: DocumentFinancialEmphasis.outstanding,
                ),
              ],
            ),
            const DocumentParagraph(
              text: 'القيم المالية المعروضة هي القيم المعتمدة في سجل الفاتورة. لم يُعد التطبيق احتساب الإجماليات أو الأرصدة.',
              direction: DocumentTextDirection.rightToLeft,
            ),
          ],
        ),
      ],
    );

    final template = DocumentTemplateDefinition(
      id: TemplateId('netsales.invoice.official'),
      version: TemplateVersion(major: 1, minor: 0, patch: 0),
      documentTypeId: DocumentTypeId('netsales.invoice'),
      displayName: 'NetSales Official Invoice',
      supportedLocaleTags: const ['ar-YE', 'ar'],
      capabilities: TemplateCapabilities([
        TemplateCapability.pageNumbering,
        TemplateCapability.repeatingHeader,
        TemplateCapability.repeatingFooter,
        TemplateCapability.tables,
        TemplateCapability.watermark,
        TemplateCapability.landscapePage,
      ]),
      isDefault: true,
      layout: DocumentTemplateLayout.standard,
    );

    return DocumentEnginePdfService.instance.render(
      snapshot: snapshot,
      template: template,
      options: DocumentRenderOptions(
        pageProfile: DocumentPageProfile.a4Landscape(
          marginTop: 42,
          marginRight: 32,
          marginBottom: 44,
          marginLeft: 32,
        ),
        generatedAt: generatedAt,
        headerText: 'NetSales · فاتورة ${invoice.displayReference}',
        footerText: 'مستند مالي رسمي — بيانات الفاتورة المعتمدة',
        watermark: DocumentWatermark(
          imageBytes: branding.logoBytes!,
          opacity: 0.055,
          angleRadians: -0.6108652381980153,
          widthFactor: 0.52,
          heightFactor: 0.42,
        ),
        branding: branding,
        maxPages: 20,
      ),
    );
  }

  Future<bool> printInvoice(InvoiceEntity invoice) async {
    final bytes = await generateInvoicePdfBytes(invoice);
    return Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'فاتورة_${invoice.displayReference}.pdf',
    );
  }

  Future<bool> shareInvoice(InvoiceEntity invoice) async {
    final bytes = await generateInvoicePdfBytes(invoice);
    final result = await ShareService.instance.shareBytes(
      bytes: bytes,
      fileName: 'invoice_${invoice.invoiceId}.pdf',
      mimeType: 'application/pdf',
      text: 'فاتورة مبيعات رقم ${invoice.displayReference}',
    );
    return result.status == ShareResultStatus.success;
  }

  Future<bool> exportAndSaveInvoice(InvoiceEntity invoice) async {
    final bytes = await generateInvoicePdfBytes(invoice);
    final result = await FileExportService.instance.saveFile(
      bytes: bytes,
      fileName: 'invoice_${invoice.invoiceId}.pdf',
      folderName: 'Invoices',
      autoOpen: true,
    );
    return result.isSuccess;
  }
}
