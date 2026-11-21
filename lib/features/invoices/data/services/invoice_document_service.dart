import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/core/services/share_service.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';

/// خدمة تصدير وطباعة ومشاركة الفواتير الرسمية المعتمدة
///
/// تستهلك الخدمات الموحدة للنظام [FileExportService] و [ShareService]
/// وتولد مستند PDF متوافقاً مع الهوية البصرية والخطوط المعتمدة.
class InvoiceDocumentService {
  const InvoiceDocumentService();

  /// توليد مصفوفة بايتات مستند PDF للفاتورة
  Future<Uint8List> generateInvoicePdfBytes(InvoiceEntity invoice) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.cairoRegular();
    final boldFont = await PdfGoogleFonts.cairoBold();

    final status = EnumPresentationRegistry.resolveInvoicePaymentStatus(
      invoice.paymentStatus,
      serverLabel: invoice.paymentStatusLabel,
    );
    final saleType = EnumPresentationRegistry.resolveSaleType(
      invoice.saleType,
      serverLabel: invoice.saleTypeLabel,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // 1. ترويسة الفاتورة
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'فاتورة مبيعات كروت رسمية',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 18,
                          color: PdfColors.blueGrey900,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'رقم المرجع: ${invoice.displayReference}',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        'التاريخ: ${invoice.formattedInvoiceDate}',
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey200,
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          'الحالة: ${status.label}',
                          style: pw.TextStyle(font: boldFont, fontSize: 11),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'نوع البيع: ${saleType.label}',
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 12),

              // 2. أطراف المعاملة
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'المورد (الشبكة):',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        invoice.displayNetworkName,
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 12,
                          color: PdfColors.blueGrey900,
                        ),
                      ),
                      if (invoice.networkPhoneNumber != null)
                        pw.Text(
                          invoice.networkPhoneNumber!,
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'العميل (نقطة البيع):',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        invoice.displayPosName,
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 12,
                          color: PdfColors.blueGrey900,
                        ),
                      ),
                      if (invoice.posPhoneNumber != null)
                        pw.Text(
                          invoice.posPhoneNumber!,
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // 3. جدول البنود
              pw.TableHelper.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerStyle: pw.TextStyle(
                  font: boldFont,
                  fontSize: 10,
                  color: PdfColors.blueGrey800,
                ),
                cellStyle: const pw.TextStyle(fontSize: 9),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey100,
                ),
                headers: <String>[
                  'الباقة',
                  'الكمية بالكروت',
                  'التوزيع الورقي',
                  'سعر الكرت',
                  'الخصم',
                  'الإجمالي',
                ],
                data: invoice.items.map((item) {
                  return [
                    item.packageName,
                    '${item.voucherCount}',
                    item.formattedSheetsCount,
                    AmountFormatter.formatValue(item.voucherPrice),
                    AmountFormatter.formatValue(item.itemDiscount),
                    AmountFormatter.formatValue(item.itemTotalAmount),
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 16),

              // 4. ملخص المبالغ المالية
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Container(
                  width: 240,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(6),
                    color: PdfColors.grey50,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      _buildSummaryRow(
                        'إجمالي الفاتورة:',
                        AmountFormatter.formatValue(invoice.invoiceTotalAmount),
                        boldFont,
                      ),
                      pw.SizedBox(height: 4),
                      _buildSummaryRow(
                        'المدفوع:',
                        AmountFormatter.formatValue(invoice.paidAmount),
                        boldFont,
                      ),
                      pw.SizedBox(height: 4),
                      _buildSummaryRow(
                        'المتبقي:',
                        AmountFormatter.formatValue(invoice.remainingAmount),
                        boldFont,
                        isRemaining: true,
                      ),
                    ],
                  ),
                ),
              ),

              pw.Spacer(),

              // 5. تذييل الفاتورة
              pw.Divider(color: PdfColors.grey300),
              pw.Center(
                child: pw.Text(
                  'تم إصدار هذه الفاتورة رسمياً عبر منصة NetSales لإدارة مبيعات الكروت',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey500,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildSummaryRow(
    String label,
    String value,
    pw.Font font, {
    bool isRemaining = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
            color: isRemaining ? PdfColors.red700 : PdfColors.black,
          ),
        ),
      ],
    );
  }

  /// طباعة الفاتورة عبر الطابعة المتصلة
  Future<bool> printInvoice(InvoiceEntity invoice) async {
    final bytes = await generateInvoicePdfBytes(invoice);
    return Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'فاتورة_${invoice.displayReference}.pdf',
    );
  }

  /// مشاركة الفاتورة عبر خدمة المشاركة الموحدة [ShareService]
  Future<bool> shareInvoice(InvoiceEntity invoice) async {
    final bytes = await generateInvoicePdfBytes(invoice);
    final fileName = 'invoice_${invoice.invoiceId}.pdf';

    final result = await ShareService.instance.shareBytes(
      bytes: bytes,
      fileName: fileName,
      mimeType: 'application/pdf',
      text: 'فاتورة مبيعات رقم ${invoice.displayReference}',
    );

    return result.status == ShareResultStatus.success;
  }

  /// تصدير وحفظ الفاتورة عبر خدمة تصدير الملفات الموحدة [FileExportService]
  Future<bool> exportAndSaveInvoice(InvoiceEntity invoice) async {
    final bytes = await generateInvoicePdfBytes(invoice);
    final fileName = 'invoice_${invoice.invoiceId}.pdf';

    final result = await FileExportService.instance.saveFile(
      bytes: bytes,
      fileName: fileName,
      folderName: 'Invoices',
      autoOpen: true,
    );

    return result.isSuccess;
  }
}
