import 'dart:typed_data';

import 'package:document_engine/document_engine.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:netsales/core/services/document_engine_pdf_service.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/core/services/share_service.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';

/// Official operational-expense voucher PDF generation and delivery.
class ExpenseDocumentService {
  const ExpenseDocumentService();

  Future<Uint8List> generateExpensePdfBytes(ExpenseEntity expense) async {
    final generatedAt = DateTime.now();
    final branding = await DocumentEnginePdfService.instance.loadBranding(
      organizationName: 'NetSales',
      tagline: 'المستندات المالية الرسمية',
      logoUrl: expense.networkLogo,
    );

    final info = <DocumentInfoItem>[
      DocumentInfoItem(
        label: 'مرجع السند',
        value: DocumentTextValue(expense.displayReference),
        direction: DocumentTextDirection.leftToRight,
      ),
      DocumentInfoItem(
        label: 'تاريخ الصرف',
        value: DocumentTextValue(expense.formattedExpenseDate),
        direction: DocumentTextDirection.leftToRight,
      ),
      if (expense.networkName != null)
        DocumentInfoItem(
          label: 'الشبكة',
          value: DocumentTextValue(expense.networkName!),
        ),
      if (expense.networkPhoneNumber != null)
        DocumentInfoItem(
          label: 'هاتف الشبكة',
          value: DocumentTextValue(expense.networkPhoneNumber!),
          direction: DocumentTextDirection.leftToRight,
        ),
      if (expense.createdByName != null)
        DocumentInfoItem(
          label: 'سُجل بواسطة',
          value: DocumentTextValue(expense.createdByName!),
        ),
      DocumentInfoItem(
        label: 'عدد البنود',
        value: DocumentTextValue(expense.itemsCount.toString()),
        direction: DocumentTextDirection.leftToRight,
      ),
    ];

    final rows = expense.items.asMap().entries.map((entry) {
      final item = entry.value;
      return DocumentTableRow(
        id: 'expense-item-${entry.key + 1}',
        cells: [
          DocumentTableCell(
            value: DocumentTextValue((entry.key + 1).toString()),
            direction: DocumentTextDirection.leftToRight,
          ),
          DocumentTableCell(
            value: DocumentTextValue(item.itemStatement),
            direction: DocumentTextDirection.rightToLeft,
          ),
          DocumentTableCell(
            value: DocumentTextValue(AmountFormatter.formatValue(item.itemAmount)),
            direction: DocumentTextDirection.leftToRight,
          ),
        ],
      );
    });

    final snapshot = DocumentSnapshot(
      metadata: DocumentMetadata(
        id: DocumentId('netsales-expense-${expense.expenseId}-${generatedAt.microsecondsSinceEpoch}'),
        documentTypeId: DocumentTypeId('netsales.expense-voucher'),
        title: 'سند صرف مصروف تشغيلي',
        subtitle: 'سند مصروف مسجل على الشبكة',
        reference: expense.displayReference,
        locale: DocumentLocale(
          languageTag: 'ar-YE',
          direction: DocumentTextDirection.rightToLeft,
        ),
        createdAt: generatedAt,
        timeZoneId: 'Asia/Aden',
      ),
      sections: [
        DocumentSection(
          id: 'expense-voucher-details',
          title: 'بيانات سند الصرف',
          nodes: [
            DocumentStatusBanner(
              label: 'مصروف تشغيلي مسجل',
              tone: DocumentStatusTone.info,
              detail: 'مرجع السند: ${expense.displayReference}',
            ),
            DocumentInfoGrid(items: info, columns: 3, compact: true),
            DocumentHeading(
              text: 'بيان البنود والمبالغ',
              level: 2,
              direction: DocumentTextDirection.rightToLeft,
            ),
            DocumentTable(
              columns: [
                DocumentTableColumn(
                  id: 'sequence',
                  label: '#',
                  alignment: DocumentCellAlignment.center,
                ),
                DocumentTableColumn(id: 'statement', label: 'بيان البند'),
                DocumentTableColumn(
                  id: 'amount',
                  label: 'المبلغ',
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
              title: 'إجمالي السند',
              lines: [
                DocumentFinancialLine(
                  label: 'إجمالي المصروف',
                  value: DocumentTextValue(AmountFormatter.formatValue(expense.expenseTotalAmount)),
                  emphasis: DocumentFinancialEmphasis.total,
                ),
              ],
            ),
            const DocumentParagraph(
              text: 'إجمالي المصروف هو المبلغ المسجل والمعتمد في سند الصرف، ولا يعيد هذا المستند جمع البنود أو تعديل القيمة.',
              direction: DocumentTextDirection.rightToLeft,
            ),
          ],
        ),
      ],
    );

    final template = DocumentTemplateDefinition(
      id: TemplateId('netsales.expense-voucher.official'),
      version: TemplateVersion(major: 1, minor: 0, patch: 0),
      documentTypeId: DocumentTypeId('netsales.expense-voucher'),
      displayName: 'NetSales Official Expense Voucher',
      supportedLocaleTags: const ['ar-YE', 'ar'],
      capabilities: TemplateCapabilities([
        TemplateCapability.pageNumbering,
        TemplateCapability.repeatingHeader,
        TemplateCapability.repeatingFooter,
        TemplateCapability.tables,
        TemplateCapability.watermark,
        TemplateCapability.portraitPage,
      ]),
      isDefault: true,
      layout: DocumentTemplateLayout.standard,
    );

    return DocumentEnginePdfService.instance.render(
      snapshot: snapshot,
      template: template,
      options: DocumentRenderOptions(
        pageProfile: DocumentPageProfile.a4Portrait(
          marginTop: 42,
          marginRight: 36,
          marginBottom: 44,
          marginLeft: 36,
        ),
        generatedAt: generatedAt,
        headerText: 'NetSales · سند صرف ${expense.displayReference}',
        footerText: 'مستند مالي رسمي — بيانات المصروف المعتمدة',
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

  Future<bool> printExpense(ExpenseEntity expense) async {
    final bytes = await generateExpensePdfBytes(expense);
    return Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'سند_صرف_${expense.displayReference}.pdf',
    );
  }

  Future<bool> shareExpense(ExpenseEntity expense) async {
    final bytes = await generateExpensePdfBytes(expense);
    final result = await ShareService.instance.shareBytes(
      bytes: bytes,
      fileName: 'expense_${expense.expenseId}.pdf',
      mimeType: 'application/pdf',
      text: 'سند صرف مصروف تشغيلي رقم ${expense.displayReference}',
    );
    return result.status == ShareResultStatus.success;
  }

  Future<bool> exportAndSaveExpense(ExpenseEntity expense) async {
    final bytes = await generateExpensePdfBytes(expense);
    final result = await FileExportService.instance.saveFile(
      bytes: bytes,
      fileName: 'expense_${expense.expenseId}.pdf',
      folderName: 'Expenses',
      autoOpen: true,
    );
    return result.isSuccess;
  }
}
