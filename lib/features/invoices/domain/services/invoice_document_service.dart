import 'package:flutter/services.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// خدمة توليد وتصدير مستند فاتورة المبيعات الرسمية كـ PDF (Invoice Document Service)
class InvoiceDocumentService {
  InvoiceDocumentService._();

  static final InvoiceDocumentService instance = InvoiceDocumentService._();

  pw.Font? _arabicRegularFont;
  pw.Font? _arabicBoldFont;

  /// تحميل خطوط IBM Plex Sans Arabic المعتمدة في المشروع
  Future<void> _ensureFontsLoaded() async {
    if (_arabicRegularFont != null && _arabicBoldFont != null) return;

    try {
      final regularData = await rootBundle.load('assets/fonts/IBM-Regular.ttf');
      final boldData = await rootBundle.load('assets/fonts/IBM-Bold.ttf');

      _arabicRegularFont = pw.Font.ttf(regularData);
      _arabicBoldFont = pw.Font.ttf(boldData);
    } catch (_) {
      // Fallback: استخدام خطوط النظام أو خط PDF الافتراضي
    }
  }

  /// بناء مستند الـ PDF بالكامل بناءً على البيانات السيادية للفاتورة
  Future<Uint8List> generateInvoicePdf(InvoiceEntity invoice) async {
    await _ensureFontsLoaded();

    final pdf = pw.Document();

    final theme = pw.ThemeData.withFont(
      base: _arabicRegularFont,
      bold: _arabicBoldFont,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: theme,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // 1. ترويسة الفاتورة والهوية البصرية
              _buildHeader(invoice),
              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.teal800, thickness: 1.5),
              pw.SizedBox(height: 16),

              // 2. بيانات أطراف المعاملة وتفاصيل الفاتورة
              _buildPartiesAndMeta(invoice),
              pw.SizedBox(height: 20),

              // 3. جدول بنود الفاتورة السيادية
              _buildItemsTable(invoice),
              pw.SizedBox(height: 20),

              // 4. ملخص المبالغ المالية السيادية
              _buildFinancialSummary(invoice),

              pw.Spacer(),

              // 5. تذييل المستند الرسمي
              _buildFooter(invoice),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// ترويسة الفاتورة
  pw.Widget _buildHeader(InvoiceEntity invoice) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'منصة نت سيلز — NetSales B2B',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.teal900,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'فاتورة تجارية رسمية معتمدة',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'فاتورة رقم: #${invoice.invoiceId}',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.teal900,
              ),
            ),
            if (invoice.invoiceUuid != null) ...[
              pw.SizedBox(height: 2),
              pw.Text(
                'UUID: ${invoice.invoiceUuid}',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// بيانات الأطراف والتواريخ
  pw.Widget _buildPartiesAndMeta(InvoiceEntity invoice) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // المزود / الشبكة
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'المزود (الشبكة):',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal900,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  invoice.networkName ?? 'شبكة #${invoice.networkId}',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'معرّف الشبكة: #${invoice.networkId}',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 12),
        // العميل / نقطة البيع
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'العميل (نقطة البيع):',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal900,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  invoice.posName ?? 'نقطة بيع #${invoice.posId}',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (invoice.posPhoneNumber != null) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'الهاتف: ${invoice.posPhoneNumber}',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 12),
        // بيانات المعاملة
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'تاريخ الإصدار: ${invoice.invoiceDate ?? invoice.createdAt ?? '-'}',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'نوع البيع: ${invoice.saleTypeLabel ?? invoice.saleTypeRaw ?? '-'}',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'حالة السداد: ${invoice.paymentStatusLabel ?? invoice.paymentStatusRaw ?? '-'}',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: invoice.isPaid
                        ? PdfColors.green800
                        : PdfColors.amber900,
                  ),
                ),
                if (invoice.requestId != null) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'طلب التوريد المرتبط: #${invoice.requestId}',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// جدول البنود
  pw.Widget _buildItemsTable(InvoiceEntity invoice) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3), // اسم الباقة
        1: const pw.FlexColumnWidth(1.2), // السعر الإفرادي
        2: const pw.FlexColumnWidth(1), // الكمية
        3: const pw.FlexColumnWidth(1.2), // الخصم
        4: const pw.FlexColumnWidth(1.5), // الإجمالي
      },
      children: [
        // صف العناوين
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.teal50),
          children: [
            _buildTableCell('الباقة / الخدمة', isHeader: true),
            _buildTableCell('السعر الإفرادي', isHeader: true),
            _buildTableCell('الكمية', isHeader: true),
            _buildTableCell('الخصم', isHeader: true),
            _buildTableCell('إجمالي البند', isHeader: true),
          ],
        ),
        // البنود
        ...invoice.items.map((item) {
          return pw.TableRow(
            children: [
              _buildTableCell(item.packageName ?? 'باقة #${item.packageId}'),
              _buildTableCell(
                AmountFormatter.format(item.voucherPrice.toString()),
              ),
              _buildTableCell(item.voucherCount.toString()),
              _buildTableCell(
                AmountFormatter.format(item.itemDiscount.toString()),
              ),
              _buildTableCell(
                AmountFormatter.format(item.itemTotalAmount.toString()),
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8.5,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.teal900 : PdfColors.black,
        ),
      ),
    );
  }

  /// ملخص المبالغ المالية السيادية
  pw.Widget _buildFinancialSummary(InvoiceEntity invoice) {
    return pw.Align(
      alignment: pw.Alignment.centerLeft,
      child: pw.Container(
        width: 240,
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey50,
          border: pw.Border.all(color: PdfColors.teal800, width: 1),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Column(
          children: [
            _buildSummaryRow(
              'المبلغ الإجمالي:',
              AmountFormatter.format(invoice.invoiceTotalAmount.toString()),
              isBold: true,
            ),
            pw.SizedBox(height: 4),
            _buildSummaryRow(
              'المبلغ المسدد:',
              AmountFormatter.format(invoice.paidAmount.toString()),
            ),
            pw.SizedBox(height: 4),
            _buildSummaryRow(
              'المبلغ المتبقي:',
              AmountFormatter.format(invoice.remainingAmount.toString()),
              isBold: true,
              isHighlight: true,
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    bool isHighlight = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: PdfColors.grey800,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: isHighlight ? 10.5 : 9,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isHighlight ? PdfColors.teal900 : PdfColors.black,
          ),
        ),
      ],
    );
  }

  /// تذييل المستند
  pw.Widget _buildFooter(InvoiceEntity invoice) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300, thickness: 0.5),
        pw.SizedBox(height: 6),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'مستند رسمي صادر آلياً عن منصة NetSales B2B — المبالغ المالية سيادية وحصرية للخادم.',
              style: const pw.TextStyle(
                fontSize: 7.5,
                color: PdfColors.grey600,
              ),
            ),
            pw.Text(
              'تاريخ الطباعة: ${DateTime.now().toIso8601String().substring(0, 10)}',
              style: const pw.TextStyle(
                fontSize: 7.5,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// حفظ المستند في جهاز المستخدم عبر FileExportService
  Future<FileExportResult> exportAndSaveInvoice(InvoiceEntity invoice) async {
    final pdfBytes = await generateInvoicePdf(invoice);
    final fileName = 'فاتورة_${invoice.invoiceId}';

    return FileExportService.instance.saveFile(
      bytes: pdfBytes,
      fileName: fileName,
      extension: 'pdf',
      folderName: 'Invoices',
      namingStrategy: FileNamingStrategy.invoice,
      autoOpen: true,
      showFeedback: true,
    );
  }

  /// مشاركة المستند عبر نافذة النظام الرسمية
  Future<bool> shareInvoice(InvoiceEntity invoice) async {
    final pdfBytes = await generateInvoicePdf(invoice);
    final fileName = 'فاتورة_${invoice.invoiceId}';

    return FileExportService.instance.shareBytes(
      bytes: pdfBytes,
      fileName: fileName,
      extension: 'pdf',
      namingStrategy: FileNamingStrategy.invoice,
    );
  }

  /// إرسال المستند للطباعة المباشرة عبر Printing
  Future<bool> printInvoice(InvoiceEntity invoice) async {
    final pdfBytes = await generateInvoicePdf(invoice);
    return Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'فاتورة_${invoice.invoiceId}.pdf',
    );
  }
}
