import 'dart:typed_data';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// خدمة توليد وتصدير وطباعة سند صرف المصروفات التشغيلية
class ExpenseDocumentService {
  ExpenseDocumentService._();
  static final ExpenseDocumentService instance = ExpenseDocumentService._();

  /// توليد بايتات مستند الـ PDF لسند الصرف
  Future<Uint8List> generateExpensePdf(ExpenseEntity expense) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.cairoRegular();
    final boldFont = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          final totalAmountFormatted =
              '${AmountFormatter.format(expense.expenseTotalAmount.toString())} YER';
          final dateStr = expense.expenseDate != null
              ? DateFormatter.date(expense.expenseDate!)
              : (expense.createdAt != null
                  ? DateFormatter.date(expense.createdAt!)
                  : '-');

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // ترويسة سند الصرف
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'سند صرف مصروفات تشغيلية',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 18,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'رقم القيد: ${expense.displayReference}',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                      pw.Text(
                        'التاريخ: $dateStr',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        expense.displayNetworkName,
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 14,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'خصم مباشر من محفظة الشبكة',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 12),

              // ملخص القيد المالي
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'المسؤول عن الصرف: ${expense.displayCreatorName}',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'عدد البنود المصروفة: ${expense.items.length}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'إجمالي المبلغ المصروف',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          totalAmountFormatted,
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 14,
                            color: PdfColors.red800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // جدول بنود المصروف
              pw.Text(
                'تفاصيل بنود الصرف',
                style: pw.TextStyle(font: boldFont, fontSize: 13),
              ),
              pw.SizedBox(height: 8),

              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerStyle: pw.TextStyle(
                  font: boldFont,
                  fontSize: 10,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey800,
                ),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellPadding: const pw.EdgeInsets.all(6),
                headers: <String>['#', 'بيان المصروف', 'المبلغ'],
                data: expense.items.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final item = entry.value;
                  return [
                    '$idx',
                    item.itemStatement,
                    '${item.formattedAmount} YER',
                  ];
                }).toList(),
              ),

              pw.Spacer(),

              // مساحة التوقيعات والاعتماد
              pw.Divider(thickness: 0.5, color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Text('المحاسب المسؤول', style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 30),
                      pw.Text('................................', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('المستلم', style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 30),
                      pw.Text('................................', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('إدارة الشبكة / الختم', style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 30),
                      pw.Text('................................', style: const pw.TextStyle(fontSize: 8)),
                    ],
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

  /// تصدير وحفظ المستند كملف
  Future<bool> exportAndSaveExpense(ExpenseEntity expense) async {
    try {
      final bytes = await generateExpensePdf(expense);
      final filename = 'Expense_${expense.displayReference.replaceAll('#', '')}.pdf';
      final result = await FileExportService.instance.saveFile(
        bytes: bytes,
        fileName: filename,
        folderName: 'Expenses',
      );
      return result.isSuccess;
    } catch (_) {
      return false;
    }
  }

  /// إرسال المستند للطباعة
  Future<bool> printExpense(ExpenseEntity expense) async {
    try {
      final bytes = await generateExpensePdf(expense);
      return await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: 'Expense_${expense.displayReference}',
      );
    } catch (_) {
      return false;
    }
  }

  /// مشاركة ملف المستند
  Future<bool> shareExpense(ExpenseEntity expense) async {
    try {
      final bytes = await generateExpensePdf(expense);
      final filename = 'Expense_${expense.displayReference.replaceAll('#', '')}.pdf';
      return await FileExportService.instance.shareBytes(
        bytes: bytes,
        fileName: filename,
      );
    } catch (_) {
      return false;
    }
  }
}
