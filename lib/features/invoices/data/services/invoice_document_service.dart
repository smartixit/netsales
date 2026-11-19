import 'dart:typed_data';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// خدمة توليد وتصدير مستندات الفواتير الرسمية بصيغة PDF والطباعة
class InvoiceDocumentService {
  InvoiceDocumentService._();
  static final InvoiceDocumentService instance = InvoiceDocumentService._();

  /// توليد بايتات مستند الـ PDF للفاتورة
  Future<Uint8List> generateInvoicePdf(InvoiceEntity invoice) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.cairoRegular();
    final boldFont = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // ترويسة الفاتورة
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'فاتورة مبيعات معتمدة',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 18,
                        ),
                      ),
                      pw.Text(
                        'رقم الفاتورة: ${invoice.displayReference}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.Text(
                        'التاريخ: ${invoice.formattedInvoiceDate}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        invoice.displayNetworkName,
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 14,
                        ),
                      ),
                      if (invoice.networkPhoneNumber != null)
                        pw.Text(
                          invoice.networkPhoneNumber!,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.SizedBox(height: 12),

              // بيانات العميل ونوع البيع
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('العميل: ${invoice.displayPosName}'),
                  pw.Text('نوع البيع: ${invoice.saleTypeLabel ?? invoice.saleTypeRaw ?? '-'}'),
                  pw.Text('حالة السداد: ${invoice.paymentStatusLabel ?? invoice.paymentStatusRaw ?? '-'}'),
                ],
              ),
              pw.SizedBox(height: 16),

              // جدول البنود
              pw.TableHelper.fromTextArray(
                context: context,
                headers: ['#', 'الباقة', 'الكمية', 'سعر الكرت', 'الخصم', 'الإجمالي'],
                data: List<List<String>>.generate(
                  invoice.items.length,
                  (index) {
                    final item = invoice.items[index];
                    return [
                      '${index + 1}',
                      item.packageName ?? 'باقة #${item.packageId}',
                      item.fullQuantityLabel,
                      item.formattedVoucherPrice,
                      item.formattedDiscount,
                      item.formattedItemTotalAmount,
                    ];
                  },
                ),
                headerStyle: pw.TextStyle(font: boldFont, fontSize: 10),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellAlignment: pw.Alignment.center,
              ),
              pw.SizedBox(height: 20),

              // الملخص المالي السيادي
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Container(
                  width: 220,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('إجمالي الفاتورة:'),
                          pw.Text(
                            invoice.formattedTotalAmount,
                            style: pw.TextStyle(font: boldFont),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('المبلغ المسدد:'),
                          pw.Text(invoice.formattedPaidAmount),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('المتبقي للسداد:'),
                          pw.Text(
                            invoice.formattedRemainingAmount,
                            style: pw.TextStyle(font: boldFont),
                          ),
                        ],
                      ),
                    ],
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

  /// تصدير وحفظ المستند كملف
  Future<bool> exportAndSaveInvoice(InvoiceEntity invoice) async {
    try {
      final bytes = await generateInvoicePdf(invoice);
      final filename = 'Invoice_${invoice.displayReference.replaceAll('#', '')}.pdf';
      final result = await FileExportService.instance.saveFile(
        bytes: bytes,
        fileName: filename,
        folderName: 'Invoices',
      );
      return result.isSuccess;
    } catch (_) {
      return false;
    }
  }

  /// إرسال المستند للطباعة
  Future<bool> printInvoice(InvoiceEntity invoice) async {
    try {
      final bytes = await generateInvoicePdf(invoice);
      return await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: 'Invoice_${invoice.displayReference}',
      );
    } catch (_) {
      return false;
    }
  }

  /// مشاركة ملف المستند
  Future<bool> shareInvoice(InvoiceEntity invoice) async {
    try {
      final bytes = await generateInvoicePdf(invoice);
      final filename = 'Invoice_${invoice.displayReference.replaceAll('#', '')}.pdf';
      return await FileExportService.instance.shareBytes(
        bytes: bytes,
        fileName: filename,
      );
    } catch (_) {
      return false;
    }
  }
}
