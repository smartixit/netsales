import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../document/document_branding.dart';
import '../../document/document_locale.dart';
import '../../document/document_node.dart';
import '../../document/document_snapshot.dart';
import '../../document/document_value.dart';
import '../../templates/document_template_definition.dart';
import '../../templates/template_capabilities.dart';
import '../document_page_profile.dart';
import '../document_render_options.dart';
import '../document_render_result.dart';
import '../document_renderer.dart';

/// PDF backend for bounded, non-official client-side documents.
///
/// Complex RTL scripts are rejected until a shaping provider is selected and
/// validated in the dedicated typography milestone.
final class PdfDocumentRenderer implements DocumentRenderer {
  const PdfDocumentRenderer();

  @override
  String get rendererId => 'document-engine.pdf';

  @override
  String get rendererVersion => '1.2.0';

  @override
  Future<DocumentRenderResult> render({
    required DocumentSnapshot snapshot,
    required DocumentTemplateDefinition template,
    required DocumentRenderOptions options,
  }) async {
    final validationFailure = _validate(snapshot, template, options);
    if (validationFailure != null) return validationFailure;

    try {
      final document = pw.Document(
        compress: true,
        title: snapshot.metadata.title,
        subject: snapshot.metadata.subtitle ?? '',
        creator: rendererId,
        producer: 'document_engine $rendererVersion',
      );
      final profile = options.pageProfile;
      final pageFormat = PdfPageFormat(
        profile.widthPoints,
        profile.heightPoints,
      );
      int? pageCount;

      if (options.coverPage) {
        document.addPage(
          pw.Page(
            theme: _pdfTheme(options.branding),
            pageFormat: pageFormat,
            margin: pw.EdgeInsets.fromLTRB(
              profile.marginLeft,
              profile.marginTop,
              profile.marginRight,
              profile.marginBottom,
            ),
            build: (_) => _coverWidget(options),
          ),
        );
      }

      document.addPage(
        pw.MultiPage(
          theme: _pdfTheme(options.branding),
          pageFormat: pageFormat,
          margin: pw.EdgeInsets.fromLTRB(
            profile.marginLeft,
            profile.marginTop,
            profile.marginRight,
            profile.marginBottom,
          ),
          maxPages: options.maxPages - (options.coverPage ? 1 : 0),
          header: (context) {
            final text = context.pageNumber == 1
                ? options.firstPageHeaderText ?? options.headerText
                : options.headerText;
            if (text == null) return pw.SizedBox();
            return _runningHeader(text);
          },
          footer: (context) {
            final text = context.pageNumber == 1
                ? options.firstPageFooterText ?? options.footerText
                : options.footerText;
            pageCount = context.pagesCount + (options.coverPage ? 1 : 0);
            if (text == null && !options.showPageNumbers) {
              return pw.SizedBox();
            }
            return _runningFooter(
              text,
              options.showPageNumbers
                  ? '${context.pageNumber + (options.coverPage ? 1 : 0)} / ${context.pagesCount + (options.coverPage ? 1 : 0)}'
                  : null,
            );
          },
          build: (_) => [
            if (options.watermark != null)
              pw.Watermark.text(
                options.watermark!.text,
                angle: options.watermark!.angleRadians,
                style: pw.TextStyle(
                  fontSize: 38,
                  color: PdfColor(
                    _pdfColor(options.watermark!.color).red,
                    _pdfColor(options.watermark!.color).green,
                    _pdfColor(options.watermark!.color).blue,
                    options.watermark!.opacity,
                  ),
                ),
              ),
            ..._buildContent(snapshot, template, options.branding),
          ],
        ),
      );

      final bytes = await document.save();
      return DocumentRenderSuccess(
        DocumentArtifact(
          documentId: snapshot.metadata.id,
          templateId: template.id,
          templateVersion: template.version,
          schemaVersion: snapshot.schemaVersion,
          rendererId: rendererId,
          rendererVersion: rendererVersion,
          generatedAt: options.generatedAt,
          bytes: bytes,
          pageCount: pageCount,
        ),
      );
    } catch (error) {
      final message = error.toString().toLowerCase();
      final isPageLimit =
          message.contains('toomanypagesexception') ||
          message.contains('maximum number of pages');
      return DocumentRenderFailure(
        code: isPageLimit
            ? DocumentRenderFailureCode.pageLimitExceeded
            : DocumentRenderFailureCode.renderingFailure,
        message: isPageLimit
            ? 'The document exceeded the configured page limit.'
            : 'The PDF renderer could not generate this document.',
      );
    }
  }

  DocumentRenderFailure? _validate(
    DocumentSnapshot snapshot,
    DocumentTemplateDefinition template,
    DocumentRenderOptions options,
  ) {
    if (snapshot.metadata.documentTypeId != template.documentTypeId) {
      return const DocumentRenderFailure(
        code: DocumentRenderFailureCode.templateMismatch,
        message: 'The selected template does not support this document type.',
      );
    }

    if (!template.supportsLocale(snapshot.metadata.locale.languageTag)) {
      return const DocumentRenderFailure(
        code: DocumentRenderFailureCode.unsupportedLocale,
        message: 'The selected template does not support this document locale.',
      );
    }

    final locale = snapshot.metadata.locale.languageTag.toLowerCase();
    if (snapshot.metadata.locale.direction ==
            DocumentTextDirection.rightToLeft ||
        RegExp(r'^(ar|fa|ur|he|ps|sd)(-|$)').hasMatch(locale) ||
        _containsUnshapedRtl(snapshot, options)) {
      return const DocumentRenderFailure(
        code: DocumentRenderFailureCode.unsupportedTextShaping,
        message:
            'This PDF backend does not yet support complex RTL text shaping.',
      );
    }

    final nodes = snapshot.sections.expand((section) => section.nodes);
    final requiredCapabilities = <TemplateCapability>[];
    if (options.showPageNumbers) {
      requiredCapabilities.add(TemplateCapability.pageNumbering);
    }
    if (options.headerText != null || options.firstPageHeaderText != null) {
      requiredCapabilities.add(TemplateCapability.repeatingHeader);
    }
    if (options.footerText != null || options.firstPageFooterText != null) {
      requiredCapabilities.add(TemplateCapability.repeatingFooter);
    }
    if (options.coverPage) {
      requiredCapabilities.add(TemplateCapability.coverPage);
    }
    if (nodes.any((node) => node is DocumentTable)) {
      requiredCapabilities.add(TemplateCapability.tables);
    }
    if (nodes.any(
      (node) => node is DocumentMetric || node is DocumentMetricGrid,
    )) {
      requiredCapabilities.add(TemplateCapability.metrics);
    }
    if (nodes.any((node) => node is DocumentChart)) {
      requiredCapabilities.add(TemplateCapability.charts);
    }
    if (nodes.any((node) => node is DocumentImage)) {
      requiredCapabilities.add(TemplateCapability.images);
    }
    if (nodes.any((node) => node is DocumentQrCode)) {
      requiredCapabilities.add(TemplateCapability.qrCodes);
    }
    if (nodes.any((node) => node is DocumentSignatureArea)) {
      requiredCapabilities.add(TemplateCapability.signatureArea);
    }
    if (options.watermark != null) {
      requiredCapabilities.add(TemplateCapability.watermark);
    }
    if (!template.capabilities.supportsAll(requiredCapabilities)) {
      return const DocumentRenderFailure(
        code: DocumentRenderFailureCode.unsupportedCapability,
        message: 'The selected template does not declare all requested capabilities.',
      );
    }

    final orientationCapability =
        options.pageProfile.orientation == DocumentPageOrientation.portrait
        ? TemplateCapability.portraitPage
        : TemplateCapability.landscapePage;
    if (!template.capabilities.supports(orientationCapability)) {
      return const DocumentRenderFailure(
        code: DocumentRenderFailureCode.unsupportedCapability,
        message:
            'The selected template does not support this page orientation.',
      );
    }
    return null;
  }

  bool _containsUnshapedRtl(
    DocumentSnapshot snapshot,
    DocumentRenderOptions options,
  ) {
    final rtlPattern = RegExp(r'[\\u0590-\\u08FF\\uFB1D-\\uFDFF\\uFE70-\\uFEFF]');
    final branding = options.branding;
    final optionTexts = <String?>[
      options.watermark?.text,
      options.headerText,
      options.footerText,
      options.firstPageHeaderText,
      options.firstPageFooterText,
      options.coverTitle,
      options.coverSubtitle,
      ...options.coverMetadata.keys,
      ...options.coverMetadata.values,
      branding?.organizationName,
      branding?.tagline,
    ];
    if (optionTexts.any(
      (value) => value != null && rtlPattern.hasMatch(value),
    )) {
      return true;
    }
    if (rtlPattern.hasMatch(snapshot.metadata.title) ||
        (snapshot.metadata.subtitle != null &&
            rtlPattern.hasMatch(snapshot.metadata.subtitle!))) {
      return true;
    }
    for (final section in snapshot.sections) {
      if (section.title != null && rtlPattern.hasMatch(section.title!)) {
        return true;
      }
      for (final node in section.nodes) {
        if (node case DocumentParagraph(:final text, :final direction)) {
          if (direction == DocumentTextDirection.rightToLeft ||
              rtlPattern.hasMatch(text)) {
            return true;
          }
        } else if (node case DocumentHeading(:final text, :final direction)) {
          if (direction == DocumentTextDirection.rightToLeft ||
              rtlPattern.hasMatch(text)) {
            return true;
          }
        } else if (node case DocumentMetric(
          :final label,
          :final value,
          :final caption,
        )) {
          if (rtlPattern.hasMatch(label) ||
              rtlPattern.hasMatch(_valueText(value)) ||
              (caption != null && rtlPattern.hasMatch(caption))) {
            return true;
          }
        } else if (node case DocumentMetricGrid(:final metrics)) {
          if (metrics.any(
            (metric) =>
                rtlPattern.hasMatch(metric.label) ||
                rtlPattern.hasMatch(_valueText(metric.value)) ||
                (metric.caption != null &&
                    rtlPattern.hasMatch(metric.caption!)),
          )) {
            return true;
          }
        } else if (node case DocumentChart(
          :final title,
          :final subtitle,
          :final series,
        )) {
          if (rtlPattern.hasMatch(title) ||
              (subtitle != null && rtlPattern.hasMatch(subtitle)) ||
              series.any(
                (item) =>
                    rtlPattern.hasMatch(item.label) ||
                    item.points.any(
                      (point) =>
                          rtlPattern.hasMatch(point.label) ||
                          (point.displayValue != null &&
                              rtlPattern.hasMatch(point.displayValue!)),
                    ),
              )) {
            return true;
          }
        } else if (node case DocumentImage(:final caption)) {
          if (caption != null && rtlPattern.hasMatch(caption)) return true;
        } else if (node case DocumentQrCode(:final caption)) {
          if (caption != null && rtlPattern.hasMatch(caption)) return true;
        } else if (node case DocumentSignatureArea(
          :final label,
          :final signerName,
          :final roleLabel,
          :final approvalReference,
        )) {
          if (rtlPattern.hasMatch(label) ||
              (signerName != null && rtlPattern.hasMatch(signerName)) ||
              (roleLabel != null && rtlPattern.hasMatch(roleLabel)) ||
              (approvalReference != null &&
                  rtlPattern.hasMatch(approvalReference))) {
            return true;
          }
        } else if (node case DocumentTable(:final columns, :final rows)) {
          if (columns.any((column) => rtlPattern.hasMatch(column.label))) {
            return true;
          }
          for (final row in rows) {
            if (row.cells.any(
              (cell) =>
                  cell.direction == DocumentTextDirection.rightToLeft ||
                  rtlPattern.hasMatch(_valueText(cell.value)),
            )) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  List<pw.Widget> _buildContent(
    DocumentSnapshot snapshot,
    DocumentTemplateDefinition template,
    DocumentBranding? branding,
  ) {
    final layout = template.layout;
    final primary = _pdfColor(branding?.primaryColor ?? '0D7A5F');
    final secondary = _pdfColor(branding?.secondaryColor ?? '1ABC9C');
    final accent = _pdfColor(branding?.accentColor ?? '2563EB');
    final surface = _pdfColor(branding?.surfaceColor ?? 'F8FAFC');
    final textColor = _pdfColor(branding?.textColor ?? '172033');
    final muted = _pdfColor(branding?.mutedTextColor ?? '64748B');
    final titleSize = switch (layout) {
      DocumentTemplateLayout.standard => 20.0,
      DocumentTemplateLayout.executive => 28.0,
      DocumentTemplateLayout.compact => 14.0,
      DocumentTemplateLayout.receipt => 17.0,
    };
    final widgets = <pw.Widget>[
      if (branding?.logoBytes case final logo?)
        pw.Align(
          alignment: layout == DocumentTemplateLayout.receipt
              ? pw.Alignment.center
              : pw.Alignment.centerLeft,
          child: pw.Container(
            height: layout == DocumentTemplateLayout.compact ? 30 : 48,
            margin: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Image(pw.MemoryImage(logo), fit: pw.BoxFit.contain),
          ),
        ),
      if (branding != null && layout != DocumentTemplateLayout.compact)
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: pw.BoxDecoration(
            color: surface,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Column(
            crossAxisAlignment: layout == DocumentTemplateLayout.receipt
                ? pw.CrossAxisAlignment.center
                : pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                branding.organizationName,
                style: pw.TextStyle(fontSize: 9, color: textColor),
                textAlign: layout == DocumentTemplateLayout.receipt
                    ? pw.TextAlign.center
                    : pw.TextAlign.left,
              ),
              if (branding.tagline case final tagline?)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2),
                  child: pw.Text(
                    tagline,
                    style: pw.TextStyle(fontSize: 8, color: muted),
                    textAlign: layout == DocumentTemplateLayout.receipt
                        ? pw.TextAlign.center
                        : pw.TextAlign.left,
                  ),
                ),
            ],
          ),
        ),
      if (layout == DocumentTemplateLayout.executive)
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 8, bottom: 16),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Container(height: 5, color: primary),
              ),
              pw.Expanded(child: pw.Container(height: 5, color: accent)),
            ],
          ),
        ),
      pw.Header(
        level: 0,
        child: pw.Text(
          snapshot.metadata.title,
          textAlign: layout == DocumentTemplateLayout.receipt
              ? pw.TextAlign.center
              : pw.TextAlign.left,
          style: pw.TextStyle(
            fontSize: titleSize,
            fontWeight: pw.FontWeight.bold,
            color: layout == DocumentTemplateLayout.executive
                ? primary
                : textColor,
          ),
        ),
      ),
    ];
    if (snapshot.metadata.subtitle case final subtitle?) {
      widgets.add(
        pw.Paragraph(
          text: subtitle,
          style: pw.TextStyle(
            fontSize: layout == DocumentTemplateLayout.compact ? 8 : 11,
            color: muted,
          ),
          textAlign: layout == DocumentTemplateLayout.receipt
              ? pw.TextAlign.center
              : pw.TextAlign.left,
        ),
      );
    }
    if (layout == DocumentTemplateLayout.receipt) {
      widgets.add(pw.Divider(color: secondary, thickness: 1.2));
    }

    for (final section in snapshot.sections) {
      if (section.title case final title?) {
        widgets.add(
          pw.Header(
            level: 1,
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: layout == DocumentTemplateLayout.compact ? 10 : 14,
                fontWeight: pw.FontWeight.bold,
                color: layout == DocumentTemplateLayout.executive
                    ? primary
                    : null,
              ),
            ),
          ),
        );
      }
      for (final node in section.nodes) {
        switch (node) {
          case DocumentParagraph(:final text):
            widgets.add(pw.Paragraph(text: text));
          case DocumentHeading(:final text, :final level):
            widgets.add(
              pw.Header(level: level > 5 ? 5 : level, child: pw.Text(text)),
            );
          case DocumentMetric(:final label, :final value, :final caption):
            widgets.add(_metricWidget(label, value, caption, branding));
          case DocumentMetricGrid(:final metrics, :final columns):
            widgets.add(_metricGridWidget(metrics, columns, branding));
          case DocumentTable(:final columns, :final rows, :final style):
            widgets.add(_tableWidget(columns, rows, style));
          case DocumentChart():
            widgets.addAll(_chartWidgets(node));
          case DocumentImage():
            widgets.add(_imageWidget(node));
          case DocumentQrCode():
            widgets.add(_qrCodeWidget(node));
          case DocumentSignatureArea():
            widgets.add(_signatureAreaWidget(node));
          case DocumentPageBreak():
            widgets.add(pw.NewPage());
        }
      }
    }
    return widgets;
  }

  pw.Widget _imageWidget(DocumentImage node) {
    final image = pw.Image(
      pw.MemoryImage(node.bytes),
      width: node.widthPoints,
      height: node.heightPoints,
      fit: switch (node.fit) {
        DocumentImageFit.contain => pw.BoxFit.contain,
        DocumentImageFit.cover => pw.BoxFit.cover,
        DocumentImageFit.fill => pw.BoxFit.fill,
      },
    );
    final aligned = pw.Align(
      alignment: switch (node.alignment) {
        DocumentImageAlignment.leading => pw.Alignment.centerLeft,
        DocumentImageAlignment.center => pw.Alignment.center,
        DocumentImageAlignment.trailing => pw.Alignment.centerRight,
      },
      child: image,
    );
    if (node.caption == null) return aligned;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        aligned,
        pw.SizedBox(height: 4),
        pw.Text(
          node.caption!,
          textAlign: switch (node.alignment) {
            DocumentImageAlignment.leading => pw.TextAlign.left,
            DocumentImageAlignment.center => pw.TextAlign.center,
            DocumentImageAlignment.trailing => pw.TextAlign.right,
          },
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      ],
    );
  }

  pw.Widget _qrCodeWidget(DocumentQrCode node) => pw.Column(
    mainAxisSize: pw.MainAxisSize.min,
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      pw.BarcodeWidget(
        barcode: pw.Barcode.qrCode(),
        data: node.payload,
        width: node.sizePoints,
        height: node.sizePoints,
      ),
      if (node.caption != null)
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4),
          child: pw.Text(node.caption!, style: const pw.TextStyle(fontSize: 8)),
        ),
    ],
  );

  pw.Widget _signatureAreaWidget(DocumentSignatureArea node) {
    final details = <pw.Widget>[
      pw.Text(node.label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      if (node.signerName != null) pw.Text(node.signerName!),
      if (node.roleLabel != null) pw.Text(node.roleLabel!),
      if (node.approvalReference != null)
        pw.Text('Approval reference: ${node.approvalReference!}'),
      if (node.approvedAt != null)
        pw.Text('Approved at: ${node.approvedAt!.toIso8601String()}'),
    ];
    final imageBytes = node.visualSignatureBytes;
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.6),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: details,
            ),
          ),
          if (imageBytes != null)
            pw.SizedBox(
              width: 112,
              height: 52,
              child: pw.Image(
                pw.MemoryImage(imageBytes),
                fit: pw.BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }

  pw.ThemeData? _pdfTheme(DocumentBranding? branding) {
    if (branding == null) return null;
    final bodyBytes =
        branding.fontBytes(DocumentFontRole.body) ??
        branding.fontBytes(DocumentFontRole.numeric);
    final headingBytes =
        branding.fontBytes(DocumentFontRole.heading) ??
        branding.fontBytes(DocumentFontRole.display) ??
        bodyBytes;
    if (bodyBytes == null && headingBytes == null) return null;
    final baseBytes = bodyBytes ?? headingBytes!;
    final boldBytes = headingBytes ?? bodyBytes!;
    return pw.ThemeData.withFont(
      base: pw.Font.ttf(ByteData.sublistView(baseBytes)),
      bold: pw.Font.ttf(ByteData.sublistView(boldBytes)),
    );
  }

  pw.Widget _coverWidget(DocumentRenderOptions options) {
    final entries = options.coverMetadata.entries.toList();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        if (options.branding?.logoBytes case final logo?)
          pw.Container(
            height: 54,
            margin: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Image(pw.MemoryImage(logo), fit: pw.BoxFit.contain),
          ),
        if (options.branding case final branding?)
          pw.Text(
            branding.organizationName,
            style: pw.TextStyle(
              fontSize: 10,
              color: _pdfColor(branding.mutedTextColor),
            ),
          ),
        pw.Container(
          width: 64,
          height: 4,
          color: _pdfColor(options.branding?.primaryColor ?? '0D7A5F'),
          margin: const pw.EdgeInsets.only(bottom: 28),
        ),
        pw.Text(
          options.coverTitle!,
          style: pw.TextStyle(
            fontSize: 30,
            fontWeight: pw.FontWeight.bold,
            color: _pdfColor(options.branding?.textColor ?? '172033'),
          ),
        ),
        if (options.coverSubtitle case final subtitle?)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 12),
            child: pw.Text(
              subtitle,
              style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
            ),
          ),
        if (entries.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 42),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: entries
                  .map(
                    (entry) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Row(
                        children: [
                          pw.SizedBox(
                            width: 110,
                            child: pw.Text(
                              entry.key,
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.grey600,
                              ),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              entry.value,
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        pw.Spacer(),
        pw.Text(
          'Generated ${options.generatedAt.toUtc().toIso8601String()}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
        ),
      ],
    );
  }

  pw.Widget _runningHeader(String text) => pw.Container(
    alignment: pw.Alignment.centerLeft,
    padding: const pw.EdgeInsets.only(bottom: 8),
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
      ),
    ),
    child: pw.Text(
      text,
      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
    ),
  );

  pw.Widget _runningFooter(String? text, String? pageNumber) {
    final parts = <pw.Widget>[
      if (text != null)
        pw.Expanded(
          child: pw.Text(
            text,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ),
      if (pageNumber != null)
        pw.Text(
          pageNumber,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
    ];
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: parts,
      ),
    );
  }

  pw.Widget _metricWidget(
    String label,
    DocumentValue value,
    String? caption,
    DocumentBranding? branding,
  ) {
    final surface = _pdfColor(branding?.surfaceColor ?? 'F1F5F9');
    final primary = _pdfColor(branding?.primaryColor ?? 'CBD5E1');
    final text = _pdfColor(branding?.textColor ?? '172033');
    final muted = _pdfColor(branding?.mutedTextColor ?? '64748B');
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 5),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: surface,
        border: pw.Border.all(color: primary, width: 0.6),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 9, color: muted)),
          pw.SizedBox(height: 4),
          pw.Text(
            _valueText(value),
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: text,
            ),
          ),
          if (caption != null)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 3),
              child: pw.Text(
                caption,
                style: pw.TextStyle(fontSize: 8, color: muted),
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _metricGridWidget(
    List<DocumentMetric> metrics,
    int columns,
    DocumentBranding? branding,
  ) {
    final rows = <pw.Widget>[];
    for (var start = 0; start < metrics.length; start += columns) {
      final row = metrics.skip(start).take(columns).toList();
      rows.add(
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            for (final metric in row)
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(3),
                  child: _metricWidget(
                    metric.label,
                    metric.value,
                    metric.caption,
                    branding,
                  ),
                ),
              ),
            for (var empty = row.length; empty < columns; empty++)
              pw.Expanded(child: pw.SizedBox()),
          ],
        ),
      );
    }
    return pw.Column(children: rows);
  }

  pw.Widget _tableWidget(
    List<DocumentTableColumn> columns,
    List<DocumentTableRow> rows,
    DocumentTableStyle style,
  ) {
    final tableRows = <pw.TableRow>[
      pw.TableRow(
        repeat: true,
        decoration: pw.BoxDecoration(color: _pdfColor(style.headerColor)),
        children: columns
            .map(
              (column) => _tableCell(
                column.label,
                column.alignment,
                true,
                style.compact,
              ),
            )
            .toList(),
      ),
      ...rows.indexed.map(
        (entry) => pw.TableRow(
          decoration: style.stripedRows && entry.$1.isOdd
              ? pw.BoxDecoration(color: _pdfColor(style.alternateRowColor))
              : null,
          children: [
            for (var index = 0; index < entry.$2.cells.length; index++)
              _tableCell(
                _valueText(entry.$2.cells[index].value),
                columns[index].alignment,
                false,
                style.compact,
              ),
          ],
        ),
      ),
    ];
    final weights = style.columnWeights;
    return pw.Table(
      border: style.showBorders
          ? pw.TableBorder.all(color: PdfColors.grey400, width: 0.45)
          : pw.TableBorder(
              horizontalInside: const pw.BorderSide(
                color: PdfColors.grey300,
                width: 0.35,
              ),
            ),
      columnWidths: weights == null
          ? null
          : {
              for (var index = 0; index < weights.length; index++)
                index: pw.FlexColumnWidth(weights[index]),
            },
      children: tableRows,
    );
  }

  pw.Widget _tableCell(
    String text,
    DocumentCellAlignment alignment,
    bool isHeader,
    bool compact,
  ) {
    final textAlign = switch (alignment) {
      DocumentCellAlignment.leading => pw.TextAlign.left,
      DocumentCellAlignment.center => pw.TextAlign.center,
      DocumentCellAlignment.trailing ||
      DocumentCellAlignment.decimal => pw.TextAlign.right,
    };
    return pw.Padding(
      padding: pw.EdgeInsets.all(compact ? 3 : 6),
      child: pw.Text(
        text,
        textAlign: textAlign,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  List<pw.Widget> _chartWidgets(DocumentChart chart) {
    final categories = chart.series.first.points;
    final widgets = <pw.Widget>[
      pw.Header(
        level: 2,
        child: pw.Text(
          chart.title,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ),
      if (chart.subtitle != null)
        pw.Paragraph(
          text: chart.subtitle!,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      pw.SvgImage(svg: _chartSvg(chart), height: 180),
    ];

    if (chart.type == DocumentChartType.bar ||
        chart.type == DocumentChartType.line) {
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4),
          child: pw.Wrap(
            spacing: 8,
            runSpacing: 3,
            children: categories
                .map(
                  (point) => pw.Text(
                    point.label,
                    style: const pw.TextStyle(fontSize: 7),
                  ),
                )
                .toList(),
          ),
        ),
      );
    }

    if (chart.showLegend) {
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          child: pw.Wrap(
            spacing: 12,
            runSpacing: 5,
            children: chart.series
                .map(
                  (series) => pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Container(
                        width: 7,
                        height: 7,
                        decoration: pw.BoxDecoration(
                          color: _pdfColor(series.color),
                          shape: pw.BoxShape.circle,
                        ),
                      ),
                      pw.SizedBox(width: 4),
                      pw.Text(
                        series.label,
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      );
    }

    widgets.add(_chartDataTable(chart));
    widgets.add(pw.SizedBox(height: 12));
    return widgets;
  }

  pw.Widget _chartDataTable(DocumentChart chart) {
    final isCircular =
        chart.type == DocumentChartType.pie ||
        chart.type == DocumentChartType.donut;
    final categories = chart.series.first.points;
    final rows = <pw.TableRow>[
      pw.TableRow(
        repeat: true,
        children: [
          _chartTableCell(isCircular ? 'Category' : 'Period', true),
          for (final series in chart.series)
            _chartTableCell(isCircular ? 'Value' : series.label, true),
        ],
      ),
      for (var index = 0; index < categories.length; index++)
        pw.TableRow(
          children: [
            _chartTableCell(categories[index].label, false),
            for (final series in chart.series)
              _chartTableCell(
                series.points[index].displayValue ??
                    series.points[index].value.toString(),
                false,
              ),
          ],
        ),
    ];
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 5),
      child: pw.Table(
        border: const pw.TableBorder(
          horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.3),
        ),
        children: rows,
      ),
    );
  }

  pw.Widget _chartTableCell(String value, bool header) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 4),
    child: pw.Text(
      value,
      style: pw.TextStyle(
        fontSize: 7,
        fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );

  String _chartSvg(DocumentChart chart) {
    const width = 600.0;
    const height = 240.0;
    const left = 32.0;
    const right = 16.0;
    const top = 16.0;
    const bottom = 22.0;
    final plotWidth = width - left - right;
    final plotHeight = height - top - bottom;
    final buffer = StringBuffer(
      '<svg xmlns="http://www.w3.org/2000/svg" width="600" height="240" viewBox="0 0 600 240">',
    );

    if (chart.type == DocumentChartType.pie ||
        chart.type == DocumentChartType.donut) {
      final points = chart.series.single.points;
      final total = points.fold<double>(0, (sum, point) => sum + point.value);
      var angle = -math.pi / 2;
      const cx = 300.0;
      const cy = 120.0;
      const radius = 100.0;
      for (var index = 0; index < points.length; index++) {
        final sweep = points[index].value / total * math.pi * 2;
        if (sweep > 0) {
          final end = angle + sweep;
          final x1 = cx + radius * math.cos(angle);
          final y1 = cy + radius * math.sin(angle);
          final x2 = cx + radius * math.cos(end);
          final y2 = cy + radius * math.sin(end);
          final largeArc = sweep > math.pi ? 1 : 0;
          buffer.write(
            '<path d="M $cx $cy L $x1 $y1 A $radius $radius 0 $largeArc 1 $x2 $y2 Z" fill="#${_pieColor(index)}"/>',
          );
        }
        angle += sweep;
      }
      if (chart.type == DocumentChartType.donut) {
        buffer.write('<circle cx="$cx" cy="$cy" r="52" fill="#FFFFFF"/>');
      }
    } else {
      final allValues = chart.series
          .expand((series) => series.points.map((point) => point.value))
          .toList();
      var minValue = allValues.reduce((a, b) => a < b ? a : b);
      var maxValue = allValues.reduce((a, b) => a > b ? a : b);
      if (chart.type == DocumentChartType.bar) {
        minValue = minValue < 0 ? minValue : 0;
        maxValue = maxValue > 0 ? maxValue : 0;
      }
      if (minValue == maxValue) {
        maxValue = minValue + 1;
      }
      final range = maxValue - minValue;
      double yFor(double value) {
        return top + (maxValue - value) / range * plotHeight;
      }

      if (chart.showGrid) {
        for (var line = 0; line <= 4; line++) {
          final y = top + plotHeight * line / 4;
          buffer.write(
            '<line x1="$left" y1="$y" x2="${width - right}" y2="$y" stroke="#D7DEE7" stroke-width="1"/>',
          );
        }
      }
      if (chart.type == DocumentChartType.bar) {
        final count = chart.series.first.points.length;
        final groupWidth = plotWidth / count;
        final barWidth = math.min(34.0, groupWidth / (chart.series.length + 1));
        final baseline = yFor(0);
        for (
          var seriesIndex = 0;
          seriesIndex < chart.series.length;
          seriesIndex++
        ) {
          final series = chart.series[seriesIndex];
          for (
            var pointIndex = 0;
            pointIndex < series.points.length;
            pointIndex++
          ) {
            final value = series.points[pointIndex].value;
            final x =
                left +
                groupWidth * pointIndex +
                groupWidth / 2 +
                (seriesIndex - (chart.series.length - 1) / 2) * barWidth -
                barWidth / 2;
            final y = yFor(value);
            buffer.write(
              '<rect x="$x" y="${math.min(y, baseline)}" width="$barWidth" height="${math.max(1, (baseline - y).abs())}" rx="3" fill="#${series.color}"/>',
            );
          }
        }
      } else {
        for (final series in chart.series) {
          final points = <String>[];
          for (var index = 0; index < series.points.length; index++) {
            final x =
                left +
                (series.points.length == 1
                    ? plotWidth / 2
                    : plotWidth * index / (series.points.length - 1));
            points.add('$x,${yFor(series.points[index].value)}');
          }
          final path = points
              .asMap()
              .entries
              .map(
                (entry) =>
                    '${entry.key == 0 ? 'M' : 'L'} ${entry.value.replaceAll(',', ' ')}',
              )
              .join(' ');
          buffer.write(
            '<path d="$path" fill="none" stroke="#${series.color}" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>',
          );
          for (final point in points) {
            final coordinates = point.split(',');
            buffer.write(
              '<circle cx="${coordinates[0]}" cy="${coordinates[1]}" r="5" fill="#${series.color}"/>',
            );
          }
        }
      }
    }
    buffer.write('</svg>');
    return buffer.toString();
  }

  String _pieColor(int index) {
    const colors = ['0D7A5F', '2563EB', 'D97706', '7C3AED', 'DB2777', '0891B2'];
    return colors[index % colors.length];
  }

  PdfColor _pdfColor(String hex) {
    final value = int.parse(hex, radix: 16);
    return PdfColor(
      ((value >> 16) & 0xFF) / 255,
      ((value >> 8) & 0xFF) / 255,
      (value & 0xFF) / 255,
    );
  }

  String _valueText(DocumentValue value) => switch (value) {
    DocumentTextValue(:final value) => value,
    DocumentIntegerValue(:final value) => value.toString(),
    DocumentDecimalValue(:final value) => value,
    DocumentDateTimeValue(:final value) => value.toIso8601String(),
    DocumentBooleanValue(:final value) => value.toString(),
  };
}
