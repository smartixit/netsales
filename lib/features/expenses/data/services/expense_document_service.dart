import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/core/services/share_service.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';

/// خدمة تصدير وطباعة ومشاركة سندات المصروفات الرسمية (ExpenseDocumentService)
///
/// تستهلك الخدمات الموحدة للنظام [FileExportService] و [ShareService]
/// وتولد مستند PDF متوافقاً مع الهوية البصرية والخطوط المعتمدة (Cairo Font).
class ExpenseDocumentService {
  const ExpenseDocumentService();

  /// توليد مصفوفة بايتات مستند PDF لسند المصروف
  Future<Uint8List> generateExpensePdfBytes(ExpenseEntity expense) async {
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
              // 1. ترويسة سند الصرف
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'سند صرف مصروف تشغيلي',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 18,
                          color: PdfColors.blueGrey900,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'رقم السند: ${expense.displayReference}',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        'تاريخ الصرف: ${expense.formattedExpenseDate}',
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
                          color: PdfColors.blueGrey50,
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          'مصروف تشغيلي مخصوم',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 11,
                            color: PdfColors.blueGrey800,
                          ),
                        ),
                      ),
                      if (expense.createdByName != null) ...[
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'سُجل بواسطة: ${expense.createdByName}',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 12),

              // 2. معلومات الشبكة التابع لها المصروف
              if (expense.networkName != null) ...[
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'الشبكة: ${expense.networkName}',
                        style: pw.TextStyle(font: boldFont, fontSize: 12),
                      ),
                      if (expense.networkPhoneNumber != null)
                        pw.Text(
                          'الهاتف: ${expense.networkPhoneNumber}',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
              ],

              // 3. جدول بنود المصروف التفصيلية
              pw.Text(
                'بيان البنود والمبالغ:',
                style: pw.TextStyle(font: boldFont, fontSize: 13),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerStyle: pw.TextStyle(
                  font: boldFont,
                  fontSize: 11,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey800,
                ),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellAlignment: pw.Alignment.centerRight,
                headers: <String>['#', 'بيان البند', 'المبلغ (ر.ي)'],
                data: List<List<String>>.generate(expense.items.length, (
                  index,
                ) {
                  final item = expense.items[index];
                  return [
                    '${index + 1}',
                    item.itemStatement,
                    AmountFormatter.formatValue(item.itemAmount),
                  ];
                }),
              ),
              pw.SizedBox(height: 16),

              // 4. إجمالي المصروف
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 220,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'إجمالي المصروف:',
                          style: pw.TextStyle(font: boldFont, fontSize: 13),
                        ),
                        pw.Text(
                          AmountFormatter.formatValue(
                            expense.expenseTotalAmount,
                          ),
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 13,
                            color: PdfColors.blueGrey900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Spacer(),

              // 5. التذييل والختم الرسمي
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'تم إصدار هذا السند رسمياً عبر منصة NetSales لإدارة مبيعات الكروت',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey500,
                    ),
                  ),
                  pw.Text(
                    'التاريخ: ${expense.formattedExpenseDate}',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// طباعة سند المصروف عبر الطابعة المتصلة
  Future<bool> printExpense(ExpenseEntity expense) async {
    final bytes = await generateExpensePdfBytes(expense);
    return Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'سند_صرف_${expense.displayReference}.pdf',
    );
  }

  /// مشاركة سند المصروف عبر خدمة المشاركة الموحدة [ShareService]
  Future<bool> shareExpense(ExpenseEntity expense) async {
    final bytes = await generateExpensePdfBytes(expense);
    final fileName = 'expense_${expense.expenseId}.pdf';

    final result = await ShareService.instance.shareBytes(
      bytes: bytes,
      fileName: fileName,
      mimeType: 'application/pdf',
      text: 'سند صرف مصروف تشغيلي رقم ${expense.displayReference}',
    );

    return result.status == ShareResultStatus.success;
  }

  /// تصدير وحفظ سند المصروف عبر خدمة تصدير الملفات الموحدة [FileExportService]
  Future<bool> exportAndSaveExpense(ExpenseEntity expense) async {
    final bytes = await generateExpensePdfBytes(expense);
    final fileName = 'expense_${expense.expenseId}.pdf';

    final result = await FileExportService.instance.saveFile(
      bytes: bytes,
      fileName: fileName,
      folderName: 'Expenses',
      autoOpen: true,
    );

    return result.isSuccess;
  }
}
