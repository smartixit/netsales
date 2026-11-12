import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:document_engine/document_engine.dart';
import 'package:netsales/core/services/document_engine_brand_asset_service.dart';
import 'package:netsales/core/services/document_engine_font_service.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:printing/printing.dart';

/// Generates an official network operating-expense voucher from server data.
class ExpenseDocumentService {
  ExpenseDocumentService._();

  static final ExpenseDocumentService instance = ExpenseDocumentService._();

  Future<Uint8List> generatePdf(ExpenseEntity expense) async {
    final reference = _reference(expense);
    final organizationName = _display(
      expense.networkName,
      'شبكة #${expense.networkId}',
    );
    final logoBytes = await DocumentEngineBrandAssetService.instance
        .resolveLogoBytes(expense.networkLogoUrl);
    final fontService = DocumentEngineFontService.instance;
    final branding = DocumentBranding(
      organizationName: organizationName,
      tagline: 'إدارة المصروفات التشغيلية — NetSales',
      primaryColor: _colorHex(AppColors.lightColors.primary),
      secondaryColor: _colorHex(AppColors.lightColors.secondary),
      accentColor: _colorHex(AppColors.lightColors.tertiary),
      surfaceColor: _colorHex(AppColors.lightColors.surface),
      textColor: _colorHex(AppColors.lightColors.onSurface),
      mutedTextColor: _colorHex(AppColors.lightColors.onSurfaceVariant),
      logoBytes: logoBytes,
      fonts: await fontService.loadArabicBrandingFonts(),
    );

    final generatedAt = DateTime.now();
    final result = await PdfDocumentRenderer(
      textShapingProvider: await fontService.arabicTextShapingProvider(),
    ).render(
      snapshot: _buildSnapshot(expense, reference),
      template: _template,
      options: DocumentRenderOptions(
        pageProfile: DocumentPageProfile.a4Portrait(
          marginTop: 38,
          marginRight: 36,
          marginBottom: 42,
          marginLeft: 36,
        ),
        generatedAt: generatedAt,
        showPageNumbers: true,
        headerText: '$organizationName · سند مصروف تشغيلي',
        footerText: 'مستند صادر عن NetSales — إجمالي المصروف كما اعتمده الخادم',
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
    throw StateError('تعذر إنشاء سند المصروف.');
  }

  Future<FileExportResult> exportAndSave(ExpenseEntity expense) async {
    final bytes = await generatePdf(expense);
    return FileExportService.instance.saveFile(
      bytes: bytes,
      fileName: _fileName(expense),
      extension: 'pdf',
      folderName: 'Expenses',
      namingStrategy: const FileNamingStrategy(appPrefix: 'NetSales_EXP'),
      autoOpen: true,
      showFeedback: false,
    );
  }

  Future<bool> share(ExpenseEntity expense) async {
    final bytes = await generatePdf(expense);
    return FileExportService.instance.shareBytes(
      bytes: bytes,
      fileName: _fileName(expense),
      extension: 'pdf',
      namingStrategy: const FileNamingStrategy(appPrefix: 'NetSales_EXP'),
    );
  }

  Future<bool> print(ExpenseEntity expense) async {
    final bytes = await generatePdf(expense);
    return Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: '${_fileName(expense)}.pdf',
    );
  }

  DocumentSnapshot _buildSnapshot(ExpenseEntity expense, String reference) {
    final info = <DocumentInfoItem>[
      DocumentInfoItem(
        label: 'رقم سند المصروف',
        value: DocumentTextValue(reference),
        direction: DocumentTextDirection.leftToRight,
      ),
      DocumentInfoItem(
        label: 'تاريخ المصروف',
        value: DocumentTextValue(_display(expense.expenseDate)),
        direction: DocumentTextDirection.leftToRight,
      ),
      DocumentInfoItem(
        label: 'الشبكة',
        value: DocumentTextValue(
          _display(expense.networkName, 'شبكة #${expense.networkId}'),
        ),
        direction: DocumentTextDirection.rightToLeft,
      ),
      if (_hasText(expense.createdByName))
        DocumentInfoItem(
          label: 'سُجّل بواسطة',
          value: DocumentTextValue(expense.createdByName!.trim()),
          direction: DocumentTextDirection.rightToLeft,
        ),
      DocumentInfoItem(
        label: 'المعرّف الداخلي',
        value: DocumentTextValue('#${expense.expenseId}'),
        direction: DocumentTextDirection.leftToRight,
      ),
    ];

    final rows = expense.items.indexed.map((entry) {
      final item = entry.$2;
      return DocumentTableRow(
        id: 'expense-item-${item.itemId}',
        cells: [
          DocumentTableCell(
            value: DocumentTextValue(item.statement),
            direction: DocumentTextDirection.rightToLeft,
          ),
          DocumentTableCell(
            value: DocumentTextValue(_amount(item.amount)),
            direction: DocumentTextDirection.leftToRight,
          ),
        ],
      );
    }).toList(growable: false);

    final nodes = <DocumentNode>[
      DocumentHeading(
        text: 'سند صرف مصروف تشغيلي',
        level: 1,
        direction: DocumentTextDirection.rightToLeft,
      ),
      DocumentInfoGrid(items: info, columns: 2, compact: true),
      DocumentHeading(
        text: 'تفاصيل بنود المصروف',
        level: 2,
        direction: DocumentTextDirection.rightToLeft,
      ),
      if (rows.isEmpty)
        DocumentCallout(
          title: 'لا توجد بنود مفصلة',
          body: 'لم تتضمن استجابة الخادم بنوداً لعرضها في هذا السند.',
          tone: DocumentStatusTone.warning,
        )
      else
        DocumentTable(
          columns: [
            DocumentTableColumn(id: 'statement', label: 'بيان المصروف'),
            DocumentTableColumn(
              id: 'amount',
              label: 'المبلغ',
              alignment: DocumentCellAlignment.decimal,
            ),
          ],
          rows: rows,
          style: DocumentTableStyle(
            stripedRows: true,
            compact: true,
            showBorders: true,
            headerColor: 'E8F3EF',
            alternateRowColor: 'F7FAF9',
            columnWeights: [3.2, 1.1],
          ),
        ),
      DocumentFinancialSummary(
        title: 'الإجمالي المعتمد',
        lines: [
          DocumentFinancialLine(
            label: 'إجمالي المصروف',
            value: DocumentTextValue(_amount(expense.totalAmount)),
            emphasis: DocumentFinancialEmphasis.total,
          ),
        ],
      ),
      if (expense.attachments.isNotEmpty) ...[
        DocumentHeading(
          text: 'المرفقات الداعمة',
          level: 2,
          direction: DocumentTextDirection.rightToLeft,
        ),
        for (final attachment in expense.attachments)
          DocumentParagraph(
            text: '• ${attachment.name}',
            direction: DocumentTextDirection.rightToLeft,
          ),
      ],
      const DocumentParagraph(
        text: 'قيمة الإجمالي وبنود المصروف من سجل الخادم. لم يُعد التطبيق احتساب إجمالي المستند.',
        direction: DocumentTextDirection.rightToLeft,
      ),
    ];

    return DocumentSnapshot(
      metadata: DocumentMetadata(
        id: DocumentId('netsales-expense-${expense.expenseId}'),
        documentTypeId: DocumentTypeId('netsales.operating-expense'),
        title: 'سند صرف رسمي',
        subtitle: 'سند مصروف رقم $reference',
        reference: reference,
        locale: DocumentLocale(
          languageTag: 'ar-YE',
          direction: DocumentTextDirection.rightToLeft,
        ),
        createdAt: _parseDate(expense.expenseDate) ??
            _parseDate(expense.createdAt) ??
            DateTime.now(),
      ),
      sections: [
        DocumentSection(
          id: 'operating-expense',
          title: 'بيانات المصروف',
          nodes: nodes,
        ),
      ],
    );
  }

  DocumentTemplateDefinition get _template => DocumentTemplateDefinition(
    id: TemplateId('netsales.expense.voucher.executive'),
    version: TemplateVersion(major: 1, minor: 0, patch: 0),
    documentTypeId: DocumentTypeId('netsales.operating-expense'),
    displayName: 'NetSales Operating Expense Voucher',
    description: 'Official Arabic operating expense voucher',
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

  static String _reference(ExpenseEntity expense) =>
      _display(expense.expenseUuid, '#${expense.expenseId}');

  static String _fileName(ExpenseEntity expense) =>
      'سند_صرف_${_reference(expense)}';

  static String _amount(double value) => AmountFormatter.format(value.toString());

  static bool _hasText(String? value) => value?.trim().isNotEmpty ?? false;

  static String _display(String? value, [String fallback = '—']) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? fallback : normalized;
  }

  static DateTime? _parseDate(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    return DateTime.tryParse(normalized);
  }

  static String _colorHex(Color color) =>
      (color.toARGB32() & 0x00FFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();
}
