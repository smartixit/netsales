import 'dart:ui' show Color;

import 'package:document_engine/document_engine.dart';
import 'package:netsales/core/services/document_engine_brand_asset_service.dart';
import 'package:netsales/core/services/document_engine_font_service.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/finance/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';

/// Produces detailed ledger statements from server-supplied balances and movements.
/// This renderer never calculates or aggregates financial amounts locally.
class WalletStatementDocumentService {
  WalletStatementDocumentService._();
  static final WalletStatementDocumentService instance = WalletStatementDocumentService._();

  Future<FileExportResult> exportNetworkStatement(NetworkWalletEntity wallet, List<NetworkWalletLogEntity> logs) async {
    final currencyCode = _requireCurrency(wallet.currencyCode);
    final openingBalance = wallet.openingBalance;
    if (openingBalance == null || !openingBalance.isFinite) {
      throw StateError('لم يرسل الخادم رصيداً افتتاحياً صالحاً لمحفظة الشبكة.');
    }
    final rows = logs.map((log) => _movement(
      id: log.logId,
      date: log.logDate,
      operation: log.logOperationLabel ?? log.logOperation ?? 'غير معروف',
      statement: log.logStatement,
      amount: log.logAmount,
      balanceBefore: log.balanceBefore,
      balanceAfter: log.balanceAfter,
      snapshotSource: log.balanceSnapshotSource,
      currencyCode: log.currencyCode,
      expectedCurrencyCode: currencyCode,
      creator: log.createdByName,
    )).toList(growable: false);

    return _export(
      walletId: wallet.walletId,
      title: 'كشف حساب محفظة الشبكة',
      walletName: _display(wallet.networkName, 'الشبكة #${wallet.networkId}'),
      networkName: _display(wallet.networkName, 'الشبكة #${wallet.networkId}'),
      posName: null,
      currencyCode: currencyCode,
      openingBalance: openingBalance,
      openingBalanceSource: wallet.openingBalanceSource,
      currentBalance: wallet.walletBalance,
      creditLimit: null,
      logoUrl: wallet.networkProfileLogo,
      logs: rows,
      fileName: 'كشف_حساب_محفظة_الشبكة_${wallet.walletId}',
      templateId: 'netsales.wallet-statement.network',
      documentTypeId: 'netsales.network-wallet.statement',
    );
  }

  Future<FileExportResult> exportPosStatement(PosWalletEntity wallet, List<PosWalletLogEntity> logs) async {
    final currencyCode = _requireCurrency(wallet.currencyCode);
    final openingBalance = wallet.openingBalance;
    if (openingBalance == null || !openingBalance.isFinite) {
      throw StateError('لم يرسل الخادم رصيداً افتتاحياً صالحاً لمحفظة نقطة البيع.');
    }
    final rows = logs.map((log) => _movement(
      id: log.logId,
      date: log.logDate,
      operation: log.logOperationTypeLabel ?? log.logOperationType ?? 'غير معروف',
      statement: log.logStatement,
      amount: log.logAmount,
      balanceBefore: log.balanceBefore,
      balanceAfter: log.balanceAfter,
      snapshotSource: log.balanceSnapshotSource,
      currencyCode: log.currencyCode,
      expectedCurrencyCode: currencyCode,
      creator: log.createdByName,
    )).toList(growable: false);

    return _export(
      walletId: wallet.walletId,
      title: 'كشف حساب محفظة نقطة البيع',
      walletName: _display(wallet.posName, 'نقطة البيع #${wallet.posId}'),
      networkName: _display(wallet.networkName, 'الشبكة #${wallet.networkId}'),
      posName: _display(wallet.posName, 'نقطة البيع #${wallet.posId}'),
      currencyCode: currencyCode,
      openingBalance: openingBalance,
      openingBalanceSource: wallet.openingBalanceSource,
      currentBalance: wallet.walletBalance,
      creditLimit: wallet.creditLimit,
      logoUrl: wallet.posProfileLogo ?? wallet.networkProfileLogo,
      logs: rows,
      fileName: 'كشف_حساب_محفظة_نقطة_البيع_${wallet.walletId}',
      templateId: 'netsales.wallet-statement.pos',
      documentTypeId: 'netsales.pos-wallet.statement',
    );
  }

  _WalletStatementMovement _movement({
    required int id,
    required String? date,
    required String operation,
    required String? statement,
    required double amount,
    required double? balanceBefore,
    required double? balanceAfter,
    required String? snapshotSource,
    required String? currencyCode,
    required String expectedCurrencyCode,
    required String? creator,
  }) {
    if (!amount.isFinite || balanceBefore == null || balanceAfter == null ||
        !balanceBefore.isFinite || !balanceAfter.isFinite) {
      throw StateError('يوجد قيد لا يحتوي على مبلغ وأرصدة قبل الحركة وبعدها بصورة صالحة؛ أُوقف إنشاء الكشف.');
    }
    if (_requireCurrency(currencyCode) != expectedCurrencyCode) {
      throw StateError('عملة أحد القيود لا تطابق عملة المحفظة؛ أُوقف إنشاء الكشف دون تحويل عملة.');
    }
    return _WalletStatementMovement(
      id: id,
      date: _display(date, '—'),
      operation: _display(operation, 'غير معروف'),
      statement: _display(statement, '—'),
      amount: amount,
      balanceBefore: balanceBefore,
      balanceAfter: balanceAfter,
      snapshotSource: _display(snapshotSource, 'غير محدد'),
      creator: _display(creator, '—'),
    );
  }

  Future<FileExportResult> _export({
    required int walletId,
    required String title,
    required String walletName,
    required String networkName,
    required String? posName,
    required String currencyCode,
    required double openingBalance,
    required String? openingBalanceSource,
    required double currentBalance,
    required double? creditLimit,
    required String? logoUrl,
    required List<_WalletStatementMovement> logs,
    required String fileName,
    required String templateId,
    required String documentTypeId,
  }) async {
    if (!currentBalance.isFinite || (creditLimit != null && !creditLimit.isFinite)) {
      throw StateError('تتضمن بيانات المحفظة رصيداً أو سقفاً ائتمانياً غير صالح.');
    }
    final orderedLogs = List<_WalletStatementMovement>.of(logs)
      ..sort((left, right) => left.id.compareTo(right.id));
    final generatedAt = DateTime.now();
    final logoBytes = await DocumentEngineBrandAssetService.instance.resolveLogoBytes(logoUrl);
    final fontService = DocumentEngineFontService.instance;
    final branding = DocumentBranding(
      organizationName: networkName,
      tagline: 'كشف حساب تشغيلي — NetSales',
      primaryColor: _colorHex(AppColors.lightColors.primary),
      secondaryColor: _colorHex(AppColors.lightColors.secondary),
      accentColor: _colorHex(AppColors.lightColors.tertiary),
      surfaceColor: _colorHex(AppColors.lightColors.surface),
      textColor: _colorHex(AppColors.lightColors.onSurface),
      mutedTextColor: _colorHex(AppColors.lightColors.onSurfaceVariant),
      logoBytes: logoBytes,
      fonts: await fontService.loadArabicBrandingFonts(),
    );

    final info = <DocumentInfoItem>[
      DocumentInfoItem(label: 'المحفظة', value: DocumentTextValue(walletName), direction: DocumentTextDirection.rightToLeft),
      DocumentInfoItem(label: 'الشبكة', value: DocumentTextValue(networkName), direction: DocumentTextDirection.rightToLeft),
      if (posName != null) DocumentInfoItem(label: 'نقطة البيع', value: DocumentTextValue(posName), direction: DocumentTextDirection.rightToLeft),
      DocumentInfoItem(label: 'رقم المحفظة', value: DocumentTextValue(walletId.toString()), direction: DocumentTextDirection.leftToRight),
      DocumentInfoItem(label: 'العملة', value: DocumentTextValue(currencyCode), direction: DocumentTextDirection.leftToRight),
      DocumentInfoItem(label: 'مصدر الرصيد الافتتاحي', value: DocumentTextValue(_openingSourceLabel(openingBalanceSource)), direction: DocumentTextDirection.rightToLeft),
      if (creditLimit != null) DocumentInfoItem(label: 'السقف الائتماني', value: DocumentTextValue(_money(creditLimit, currencyCode)), direction: DocumentTextDirection.leftToRight),
    ];

    final tableRows = orderedLogs.map((log) => DocumentTableRow(
      id: 'wallet-log-${log.id}',
      cells: [
        DocumentTableCell(value: DocumentTextValue(log.id.toString()), direction: DocumentTextDirection.leftToRight),
        DocumentTableCell(value: DocumentTextValue(log.date), direction: DocumentTextDirection.leftToRight),
        DocumentTableCell(value: DocumentTextValue(log.operation), direction: DocumentTextDirection.rightToLeft),
        DocumentTableCell(value: DocumentTextValue(log.statement), direction: DocumentTextDirection.rightToLeft),
        DocumentTableCell(value: DocumentTextValue(_money(log.amount, currencyCode)), direction: DocumentTextDirection.leftToRight),
        DocumentTableCell(value: DocumentTextValue(_money(log.balanceBefore, currencyCode)), direction: DocumentTextDirection.leftToRight),
        DocumentTableCell(value: DocumentTextValue(_money(log.balanceAfter, currencyCode)), direction: DocumentTextDirection.leftToRight),
        DocumentTableCell(value: DocumentTextValue(log.creator), direction: DocumentTextDirection.rightToLeft),
        DocumentTableCell(value: DocumentTextValue(_snapshotSourceLabel(log.snapshotSource)), direction: DocumentTextDirection.rightToLeft),
      ],
    )).toList(growable: false);

    final snapshot = DocumentSnapshot(
      metadata: DocumentMetadata(
        id: DocumentId('netsales-wallet-statement-$walletId-${generatedAt.millisecondsSinceEpoch}'),
        documentTypeId: DocumentTypeId(documentTypeId),
        title: title,
        subtitle: 'كشف دفتر أستاذ تفصيلي',
        reference: 'WALLET-$walletId',
        locale: DocumentLocale(languageTag: 'ar-YE', direction: DocumentTextDirection.rightToLeft),
        createdAt: generatedAt,
      ),
      sections: [
        DocumentSection(
          id: 'wallet-statement',
          title: title,
          nodes: [
            DocumentHeading(text: title, level: 1, direction: DocumentTextDirection.rightToLeft, weight: DocumentTextWeight.bold),
            DocumentStatusBanner(label: 'كشف حساب تشغيلي تفصيلي', tone: DocumentStatusTone.info, detail: 'يعرض القيود بترتيب إدراجها في دفتر الأستاذ'),
            DocumentInfoGrid(items: info, columns: 3, compact: true),
            if (openingBalanceSource == 'BACKFILLED')
              DocumentCallout(
                title: 'تنبيه بشأن الرصيد الافتتاحي',
                body: 'الرصيد الافتتاحي أعيد بناؤه عند ترحيل دفتر الأستاذ من الرصيد الحالي والحركات المتاحة؛ لا يمثل كشفاً تاريخياً مستقلاً قبل الترحيل.',
                tone: DocumentStatusTone.warning,
              ),
            DocumentFinancialSummary(
              title: 'أرصدة المحفظة',
              lines: [
                DocumentFinancialLine(label: 'الرصيد الافتتاحي', value: DocumentTextValue(_money(openingBalance, currencyCode))),
                DocumentFinancialLine(label: 'الرصيد الحالي', value: DocumentTextValue(_money(currentBalance, currencyCode)), emphasis: DocumentFinancialEmphasis.total),
              ],
            ),
            DocumentHeading(text: 'تفاصيل الحركات', level: 2, direction: DocumentTextDirection.rightToLeft),
            if (tableRows.isEmpty)
              DocumentCallout(title: 'لا توجد حركات مسجلة', body: 'لا توجد قيود دفتر أستاذ لهذه المحفظة حتى وقت إنشاء الكشف.', tone: DocumentStatusTone.neutral)
            else
              DocumentTable(
                columns: [
                  DocumentTableColumn(id: 'id', label: 'القيد'),
                  DocumentTableColumn(id: 'date', label: 'التاريخ'),
                  DocumentTableColumn(id: 'operation', label: 'الحركة'),
                  DocumentTableColumn(id: 'statement', label: 'البيان'),
                  DocumentTableColumn(id: 'amount', label: 'المبلغ', alignment: DocumentCellAlignment.decimal),
                  DocumentTableColumn(id: 'before', label: 'قبل الحركة', alignment: DocumentCellAlignment.decimal),
                  DocumentTableColumn(id: 'after', label: 'بعد الحركة', alignment: DocumentCellAlignment.decimal),
                  DocumentTableColumn(id: 'creator', label: 'المستخدم'),
                  DocumentTableColumn(id: 'source', label: 'مصدر الرصيد'),
                ],
                rows: tableRows,
                style: DocumentTableStyle(
                  stripedRows: true,
                  compact: true,
                  showBorders: true,
                  headerColor: 'E8F3EF',
                  alternateRowColor: 'F7FAF9',
                  columnWeights: const [0.55, 1.05, 0.9, 2.5, 1.0, 1.1, 1.1, 1.0, 0.85],
                ),
              ),
            const DocumentParagraph(
              text: 'جميع المبالغ والأرصدة المعروضة من بيانات الخادم كما وردت، دون إعادة احتسابها أو جمعها داخل التطبيق.',
              direction: DocumentTextDirection.rightToLeft,
            ),
          ],
        ),
      ],
    );

    final result = await PdfDocumentRenderer(
      textShapingProvider: await fontService.arabicTextShapingProvider(),
    ).render(
      snapshot: snapshot,
      template: _template(templateId, documentTypeId),
      options: DocumentRenderOptions(
        pageProfile: DocumentPageProfile.a4Landscape(marginTop: 30, marginRight: 28, marginBottom: 34, marginLeft: 28),
        generatedAt: generatedAt,
        showPageNumbers: true,
        headerText: '$networkName · $title',
        footerText: 'NetSales — كشف حساب تشغيلي · العملة $currencyCode',
        watermark: DocumentWatermark(imageBytes: logoBytes, opacity: 0.07, angleRadians: -0.6108652381980153, widthFactor: 0.58, heightFactor: 0.46),
        branding: branding,
        maxPages: 100,
      ),
    );

    if (result is DocumentRenderFailure) throw StateError(result.message);
    if (result is! DocumentRenderSuccess) throw StateError('تعذر إنشاء كشف الحساب بصيغة PDF.');

    return FileExportService.instance.saveFile(
      bytes: result.artifact.bytes,
      fileName: fileName,
      extension: 'pdf',
      folderName: 'WalletStatements',
      namingStrategy: const FileNamingStrategy(appPrefix: 'NetSales_WST'),
      autoOpen: true,
      showFeedback: false,
    );
  }

  DocumentTemplateDefinition _template(String id, String documentTypeId) => DocumentTemplateDefinition(
    id: TemplateId(id),
    version: TemplateVersion(major: 1, minor: 0, patch: 0),
    documentTypeId: DocumentTypeId(documentTypeId),
    displayName: 'NetSales Wallet Statement',
    description: 'Arabic operational wallet ledger statement',
    supportedLocaleTags: const ['ar'],
    capabilities: TemplateCapabilities([
      TemplateCapability.pageNumbering,
      TemplateCapability.repeatingHeader,
      TemplateCapability.repeatingFooter,
      TemplateCapability.tables,
      TemplateCapability.watermark,
      TemplateCapability.landscapePage,
    ]),
    isDefault: true,
    layout: DocumentTemplateLayout.executive,
  );

  String _requireCurrency(String? raw) {
    final code = raw?.trim().toUpperCase();
    if (code == null || !RegExp(r'^[A-Z]{3}$').hasMatch(code)) {
      throw StateError('رمز عملة المحفظة غير صالح؛ أُوقف إنشاء الكشف.');
    }
    return code;
  }

  String _openingSourceLabel(String? value) => switch (value) {
    'INITIAL' => 'مسجل عند إنشاء المحفظة',
    'BACKFILLED' => 'معاد البناء عند ترحيل الدفتر',
    _ => 'غير محدد',
  };

  String _snapshotSourceLabel(String value) => switch (value) {
    'LIVE' => 'مباشر',
    'BACKFILLED' => 'معاد البناء',
    _ => 'غير محدد',
  };

  String _money(double value, String currencyCode) =>
      '${AmountFormatter.format(value.toString())} $currencyCode';

  static String _display(String? value, [String fallback = '—']) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? fallback : normalized;
  }

  static String _colorHex(Color color) =>
      (color.toARGB32() & 0x00FFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();
}

class _WalletStatementMovement {
  const _WalletStatementMovement({
    required this.id,
    required this.date,
    required this.operation,
    required this.statement,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.snapshotSource,
    required this.creator,
  });

  final int id;
  final String date;
  final String operation;
  final String statement;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String snapshotSource;
  final String creator;
}
