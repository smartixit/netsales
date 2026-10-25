import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// أنماط الطباعة المعتمدة للفواتير والسندات المالية
enum InvoicePrintFormat {
  /// طابعة إيصالات حرارية قياسية (80mm Thermal Receipt)
  thermal80,

  /// سند رسمي قياسي بحجم A4 للطباعة المكتبية والأرشفة
  standardA4,
}

/// ============================================================================
/// محرك توليد وطباعة ومشاركة السندات والفواتير الرقمية (InvoiceReceiptPdfService)
/// ============================================================================
/// خدمة مركزية مستقلة تتولى بناء مستندات الـ PDF عالية الدقة باللغة العربية:
/// - تدعم الخط العربي الأصيل (IBM Plex Sans Arabic) بدون تشويه الحروف.
/// - تدعم اتجاه الكتابة من اليمين لليسار (RTL) بالكامل.
/// - تدعم نسق الطابعات الحرارية (80mm) وسندات A4 الرسمية.
/// - توليد رموز الاستجابة السريعة (QR Code) للتحقق المالي اللحظي.
class InvoiceReceiptPdfService {
  InvoiceReceiptPdfService._();

  static final InvoiceReceiptPdfService instance = InvoiceReceiptPdfService._();

  pw.Font? _regularFont;
  pw.Font? _boldFont;

  /// تحميل وضبط الخطوط العربية المعتمدة في النظام
  Future<pw.ThemeData> _loadArabicTheme() async {
    if (_regularFont == null || _boldFont == null) {
      final regularData = await rootBundle.load('assets/fonts/IBM-Regular.ttf');
      final boldData = await rootBundle.load('assets/fonts/IBM-Bold.ttf');
      _regularFont = pw.Font.ttf(regularData);
      _boldFont = pw.Font.ttf(boldData);
    }

    return pw.ThemeData.withFont(
      base: _regularFont,
      bold: _boldFont,
    );
  }

  // ===========================================================================
  // 1. توليد وطباعة ومشاركة فواتير المبيعات (Sale Invoices)
  // ===========================================================================

  /// توليد مصفوفة بايتات فاتورة المبيعات بصيغة PDF
  Future<Uint8List> generateSaleInvoicePdf(
    SaleInvoiceEntity invoice, {
    InvoicePrintFormat format = InvoicePrintFormat.thermal80,
  }) async {
    final theme = await _loadArabicTheme();
    final pdf = pw.Document(theme: theme);

    if (format == InvoicePrintFormat.thermal80) {
      pdf.addPage(
        pw.Page(
          pageFormat: const PdfPageFormat(
            80 * PdfPageFormat.mm,
            double.infinity,
            marginAll: 4 * PdfPageFormat.mm,
          ),
          build: (pw.Context context) => _buildThermalSaleInvoice(invoice),
        ),
      );
    } else {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20 * PdfPageFormat.mm),
          build: (pw.Context context) => _buildA4SaleInvoice(invoice),
        ),
      );
    }

    return pdf.save();
  }

  /// إرسال فاتورة المبيعات مباشرة إلى الطابعة المتصلة أو اللاسلكية
  Future<void> printSaleInvoice(
    BuildContext context,
    SaleInvoiceEntity invoice, {
    InvoicePrintFormat format = InvoicePrintFormat.thermal80,
  }) async {
    try {
      final bytes = await generateSaleInvoicePdf(invoice, format: format);
      final filename = 'NetSales_INV_${invoice.invoiceUuid}.pdf';

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat _) async => bytes,
        name: filename,
        format: format == InvoicePrintFormat.thermal80
            ? const PdfPageFormat(
                80 * PdfPageFormat.mm,
                double.infinity,
                marginAll: 4 * PdfPageFormat.mm,
              )
            : PdfPageFormat.a4,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر بدء الطباعة',
        message: 'حدث خطأ أثناء إرسال أمر الطباعة: $e',
        type: SnackType.error,
      );
    }
  }

  /// مشاركة ملف PDF لفاتورة المبيعات عبر تطبيقات النظام
  Future<void> shareSaleInvoice(
    BuildContext context,
    SaleInvoiceEntity invoice, {
    InvoicePrintFormat format = InvoicePrintFormat.standardA4,
  }) async {
    try {
      final bytes = await generateSaleInvoicePdf(invoice, format: format);
      final filename = 'NetSales_INV_${invoice.invoiceUuid}.pdf';

      await Printing.sharePdf(
        bytes: bytes,
        filename: filename,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر المشاركة',
        message: 'حدث خطأ أثناء تصدير ومشاركة السند: $e',
        type: SnackType.error,
      );
    }
  }

  // ===========================================================================
  // 2. توليد وطباعة ومشاركة طلبات التوريد (Voucher Requests)
  // ===========================================================================

  /// توليد مصفوفة بايتات طلب التوريد بصيغة PDF
  Future<Uint8List> generateVoucherRequestPdf(
    VoucherRequestEntity request, {
    InvoicePrintFormat format = InvoicePrintFormat.thermal80,
  }) async {
    final theme = await _loadArabicTheme();
    final pdf = pw.Document(theme: theme);

    if (format == InvoicePrintFormat.thermal80) {
      pdf.addPage(
        pw.Page(
          pageFormat: const PdfPageFormat(
            80 * PdfPageFormat.mm,
            double.infinity,
            marginAll: 4 * PdfPageFormat.mm,
          ),
          build: (pw.Context context) => _buildThermalVoucherRequest(request),
        ),
      );
    } else {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20 * PdfPageFormat.mm),
          build: (pw.Context context) => _buildA4VoucherRequest(request),
        ),
      );
    }

    return pdf.save();
  }

  /// إرسال طلب التوريد مباشرة إلى الطابعة
  Future<void> printVoucherRequest(
    BuildContext context,
    VoucherRequestEntity request, {
    InvoicePrintFormat format = InvoicePrintFormat.thermal80,
  }) async {
    try {
      final bytes = await generateVoucherRequestPdf(request, format: format);
      final filename = 'NetSales_REQ_${request.requestUuid}.pdf';

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat _) async => bytes,
        name: filename,
        format: format == InvoicePrintFormat.thermal80
            ? const PdfPageFormat(
                80 * PdfPageFormat.mm,
                double.infinity,
                marginAll: 4 * PdfPageFormat.mm,
              )
            : PdfPageFormat.a4,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر بدء الطباعة',
        message: 'حدث خطأ أثناء إرسال أمر الطباعة: $e',
        type: SnackType.error,
      );
    }
  }

  /// مشاركة ملف PDF لطلب التوريد
  Future<void> shareVoucherRequest(
    BuildContext context,
    VoucherRequestEntity request, {
    InvoicePrintFormat format = InvoicePrintFormat.standardA4,
  }) async {
    try {
      final bytes = await generateVoucherRequestPdf(request, format: format);
      final filename = 'NetSales_REQ_${request.requestUuid}.pdf';

      await Printing.sharePdf(
        bytes: bytes,
        filename: filename,
      );
    } catch (e) {
      CustomSnackbar.show(
        title: 'تعذر المشاركة',
        message: 'حدث خطأ أثناء تصدير ومشاركة الطلب: $e',
        type: SnackType.error,
      );
    }
  }

  // ===========================================================================
  // 3. بنية الإيصال الحراري لفاتورة المبيعات (Thermal 80mm Layout)
  // ===========================================================================

  pw.Widget _buildThermalSaleInvoice(SaleInvoiceEntity invoice) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // رأس الإيصال
          pw.Center(
            child: pw.Text(
              invoice.networkName ?? 'منظومة NetSales الذكية',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Center(
            child: pw.Text(
              'سند فاتورة مبيعات كروت إنترنت',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.SizedBox(height: 4),
          _buildDashedLine(),
          pw.SizedBox(height: 4),

          // بيانات السند الأساسية
          _buildThermalKeyValue('كود الفاتورة:', '#${invoice.invoiceUuid}'),
          if (invoice.invoiceDate != null)
            _buildThermalKeyValue('تاريخ الإصدار:', invoice.invoiceDate!),
          _buildThermalKeyValue('نقطة البيع:', invoice.posName ?? 'غير محدد'),
          if (invoice.posCode != null)
            _buildThermalKeyValue('رمز النقطة:', invoice.posCode!),
          _buildThermalKeyValue('نوع البيع:', invoice.saleTypeLabel),
          _buildThermalKeyValue('حالة السداد:', invoice.paymentStatusLabel),

          pw.SizedBox(height: 4),
          _buildDashedLine(),
          pw.SizedBox(height: 4),

          // جدول البنود
          pw.Table(
            border: null,
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1.2),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Text('الباقة', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.Text('الكمية', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                  pw.Text('السعر', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                  pw.Text('الإجمالي', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.left),
                ],
              ),
              ...invoice.items.map((item) {
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Text(item.packageName ?? 'باقة كروت', style: const pw.TextStyle(fontSize: 8)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Text('${item.voucherCount}', style: const pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Text(
                        AmountFormatter.formatValue(item.voucherPrice, decimalPlaces: 0),
                        style: const pw.TextStyle(fontSize: 8),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Text(
                        AmountFormatter.formatValue(item.itemTotalAmount, decimalPlaces: 0),
                        style: const pw.TextStyle(fontSize: 8),
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 4),
          _buildDashedLine(),
          pw.SizedBox(height: 4),

          // الإجماليات المالية
          _buildThermalKeyValue(
            'إجمالي الفاتورة:',
            '${AmountFormatter.formatValue(invoice.invoiceTotalAmount)} ر.ي',
            isBold: true,
            fontSize: 10,
          ),
          _buildThermalKeyValue(
            'المبلغ المدفوع:',
            '${AmountFormatter.formatValue(invoice.paidAmount)} ر.ي',
          ),
          if (invoice.hasRemaining)
            _buildThermalKeyValue(
              'المبلغ المتبقي:',
              '${AmountFormatter.formatValue(invoice.remainingAmount)} ر.ي',
              isBold: true,
            ),
          _buildThermalKeyValue('إجمالي الكروت:', '${invoice.totalCardsCount} كرت'),

          pw.SizedBox(height: 6),
          _buildDashedLine(),
          pw.SizedBox(height: 6),

          // رمز التحقق والـ QR Code
          pw.Center(
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: invoice.invoiceUuid,
              width: 55,
              height: 55,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(
              invoice.invoiceUuid,
              style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey700),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(
              'سند رقمي معتمد — شكراً لتعاملكم معنا',
              style: const pw.TextStyle(fontSize: 7),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 10),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. بنية السند الرسمي القياسي لفاتورة المبيعات (Standard A4 Layout)
  // ===========================================================================

  List<pw.Widget> _buildA4SaleInvoice(SaleInvoiceEntity invoice) {
    const primaryColor = PdfColor.fromInt(0xFF1E3A8A); // كحلي مؤسسي أنيق
    const secondaryColor = PdfColor.fromInt(0xFF0F766E); // تركواز داكن

    return [
      pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // ترويسة السند الرسمية
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      invoice.networkName ?? 'منظومة NetSales',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'فاتورة مبيعات وسند تسليم كروت إنترنت',
                      style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'رقم المعاملة: #${invoice.invoiceUuid}',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: invoice.invoiceUuid,
                      width: 50,
                      height: 50,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      invoice.invoiceDate ?? '',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 12),
            pw.Divider(color: primaryColor, thickness: 1.5),
            pw.SizedBox(height: 10),

            // بطاقتا أطراف المعاملة
            pw.Row(
              children: [
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
                          'المزود المصدر (الشبكة):',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          invoice.networkName ?? 'غير محدد',
                          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text('معرف الشبكة: #${invoice.networkId}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 12),
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
                          'الجهة المستلمة (نقطة البيع):',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          invoice.posName ?? 'غير محدد',
                          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text('رمز النقطة: ${invoice.posCode ?? '#${invoice.posId}'}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 16),

            // جدول البنود التفصيلي
            pw.Text(
              'بنود كروت الإنترنت المباعة:',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: primaryColor),
            ),
            pw.SizedBox(height: 6),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.6),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(1.2),
                3: const pw.FlexColumnWidth(1.5),
                4: const pw.FlexColumnWidth(1.2),
                5: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    _buildTableCell('#', isHeader: true),
                    _buildTableCell('اسم الباقة', isHeader: true),
                    _buildTableCell('الكمية', isHeader: true),
                    _buildTableCell('سعر الكرت', isHeader: true),
                    _buildTableCell('الخصم', isHeader: true),
                    _buildTableCell('الإجمالي الصافي', isHeader: true),
                  ],
                ),
                ...List.generate(invoice.items.length, (index) {
                  final item = invoice.items[index];
                  return pw.TableRow(
                    children: [
                      _buildTableCell('${index + 1}'),
                      _buildTableCell(item.packageName ?? 'باقة كروت'),
                      _buildTableCell('${item.voucherCount}'),
                      _buildTableCell('${AmountFormatter.formatValue(item.voucherPrice)} ر.ي'),
                      _buildTableCell('${AmountFormatter.formatValue(item.itemDiscount)} ر.ي'),
                      _buildTableCell('${AmountFormatter.formatValue(item.itemTotalAmount)} ر.ي', isBold: true),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 16),

            // ملخص الحساب المالي
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey50,
                      border: pw.Border.all(color: PdfColors.grey200),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('تفاصيل المعاملة:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text('• طريقة البيع: ${invoice.saleTypeLabel}', style: const pw.TextStyle(fontSize: 9)),
                        pw.Text('• حالة السداد: ${invoice.paymentStatusLabel}', style: const pw.TextStyle(fontSize: 9)),
                        pw.Text('• إجمالي الكروت المستلمة: ${invoice.totalCardsCount} كرت', style: const pw.TextStyle(fontSize: 9)),
                        pw.Text('• الرقم المرجعي للعملية (UUID): ${invoice.invoiceUuid}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 14),
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: primaryColor, width: 1.2),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    ),
                    child: pw.Column(
                      children: [
                        _buildA4SummaryRow('الإجمالي:', '${AmountFormatter.formatValue(invoice.invoiceTotalAmount)} ر.ي', isTotal: true),
                        pw.Divider(color: PdfColors.grey300),
                        _buildA4SummaryRow('المدفوع:', '${AmountFormatter.formatValue(invoice.paidAmount)} ر.ي'),
                        if (invoice.hasRemaining) ...[
                          pw.Divider(color: PdfColors.grey300),
                          _buildA4SummaryRow('المتبقي:', '${AmountFormatter.formatValue(invoice.remainingAmount)} ر.ي', isBold: true),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 30),

            // التوقيعات والأختام
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  children: [
                    pw.Text('توقيع وختم المزود', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 35),
                    pw.Text('................................', style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text('توقيع وكيل نقطة البيع المستلم', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 35),
                    pw.Text('................................', style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  // ===========================================================================
  // 5. بنية الإيصال الحراري لطلب التوريد (Voucher Request Thermal Layout)
  // ===========================================================================

  pw.Widget _buildThermalVoucherRequest(VoucherRequestEntity request) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Center(
            child: pw.Text(
              request.networkName ?? 'منظومة NetSales الذكية',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Center(
            child: pw.Text(
              'سند طلب توريد باقات كروت',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.SizedBox(height: 4),
          _buildDashedLine(),
          pw.SizedBox(height: 4),

          _buildThermalKeyValue('رقم الطلب:', '#${request.requestUuid}'),
          if (request.requestDate != null)
            _buildThermalKeyValue('تاريخ الطلب:', request.requestDate!),
          _buildThermalKeyValue('نقطة البيع:', request.posName ?? 'غير محدد'),
          _buildThermalKeyValue('حالة الطلب:', request.statusLabel),
          _buildThermalKeyValue('طريقة الشراء:', request.saleTypeLabel),

          pw.SizedBox(height: 4),
          _buildDashedLine(),
          pw.SizedBox(height: 4),

          pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1.2),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Text('الباقة', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.Text('الكمية', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                  pw.Text('السعر', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                  pw.Text('الإجمالي', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.left),
                ],
              ),
              ...request.items.map((item) {
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Text(item.packageName ?? 'باقة كروت', style: const pw.TextStyle(fontSize: 8)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Text('${item.voucherCount}', style: const pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Text(
                        AmountFormatter.formatValue(item.voucherPrice, decimalPlaces: 0),
                        style: const pw.TextStyle(fontSize: 8),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Text(
                        AmountFormatter.formatValue(item.itemTotalAmount, decimalPlaces: 0),
                        style: const pw.TextStyle(fontSize: 8),
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 4),
          _buildDashedLine(),
          pw.SizedBox(height: 4),

          _buildThermalKeyValue(
            'إجمالي الطلب:',
            '${AmountFormatter.formatValue(request.requestTotalAmount)} ر.ي',
            isBold: true,
            fontSize: 10,
          ),
          _buildThermalKeyValue('إجمالي الكروت المطلوبة:', '${request.totalCardsCount} كرت'),

          if (request.requestNote != null && request.requestNote!.trim().isNotEmpty) ...[
            pw.SizedBox(height: 2),
            _buildThermalKeyValue('ملاحظات:', request.requestNote!.trim()),
          ],

          pw.SizedBox(height: 6),
          _buildDashedLine(),
          pw.SizedBox(height: 6),

          pw.Center(
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: request.requestUuid,
              width: 55,
              height: 55,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(
              request.requestUuid,
              style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey700),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 10),
        ],
      ),
    );
  }

  // ===========================================================================
  // 6. بنية السند الرسمي القياسي لطلب التوريد (Voucher Request A4 Layout)
  // ===========================================================================

  List<pw.Widget> _buildA4VoucherRequest(VoucherRequestEntity request) {
    const primaryColor = PdfColor.fromInt(0xFF0F766E); // تركواز رسمي أنيق

    return [
      pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      request.networkName ?? 'منظومة NetSales',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: primaryColor),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'سند طلب توريد باقات كروت إنترنت',
                      style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text('كود الطلب: #${request.requestUuid}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: request.requestUuid,
                  width: 50,
                  height: 50,
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Divider(color: primaryColor, thickness: 1.5),
            pw.SizedBox(height: 10),

            pw.Row(
              children: [
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
                        pw.Text('المزود المطلوب منه:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                        pw.SizedBox(height: 4),
                        pw.Text(request.networkName ?? 'غير محدد', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 12),
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
                        pw.Text('الوكيل مقدم الطلب:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                        pw.SizedBox(height: 4),
                        pw.Text(request.posName ?? 'غير محدد', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 16),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.6),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(1.2),
                3: const pw.FlexColumnWidth(1.5),
                4: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    _buildTableCell('#', isHeader: true),
                    _buildTableCell('اسم الباقة', isHeader: true),
                    _buildTableCell('الكمية المطلوبة', isHeader: true),
                    _buildTableCell('سعر الكرت', isHeader: true),
                    _buildTableCell('الإجمالي', isHeader: true),
                  ],
                ),
                ...List.generate(request.items.length, (index) {
                  final item = request.items[index];
                  return pw.TableRow(
                    children: [
                      _buildTableCell('${index + 1}'),
                      _buildTableCell(item.packageName ?? 'باقة كروت'),
                      _buildTableCell('${item.voucherCount}'),
                      _buildTableCell('${AmountFormatter.formatValue(item.voucherPrice)} ر.ي'),
                      _buildTableCell('${AmountFormatter.formatValue(item.itemTotalAmount)} ر.ي', isBold: true),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 16),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('حالة الطلب: ${request.statusLabel}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: primaryColor),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Text(
                    'الإجمالي المطلوب: ${AmountFormatter.formatValue(request.requestTotalAmount)} ر.ي',
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: primaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  // ===========================================================================
  // أدوات البناء المساعدة للـ PDF (Helpers)
  // ===========================================================================

  static pw.Widget _buildDashedLine() {
    return pw.Text(
      '------------------------------------------------',
      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
      maxLines: 1,
    );
  }

  static pw.Widget _buildThermalKeyValue(
    String key,
    String value, {
    bool isBold = false,
    double fontSize = 8,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            key,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8.5,
          fontWeight: (isHeader || isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.right,
      ),
    );
  }

  static pw.Widget _buildA4SummaryRow(
    String label,
    String value, {
    bool isBold = false,
    bool isTotal = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isTotal ? 11 : 9.5,
              fontWeight: (isBold || isTotal) ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: isTotal ? 11 : 9.5,
              fontWeight: (isBold || isTotal) ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isTotal ? const PdfColor.fromInt(0xFF1E3A8A) : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
