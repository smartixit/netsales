import 'package:document_engine/document_engine.dart';
import 'package:document_engine/document_engine_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

void main() => runApp(const NorthstarExampleApp());

class NorthstarExampleApp extends StatelessWidget {
  const NorthstarExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Northstar Labs — Document Studio',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0F766E),
        brightness: Brightness.light,
      ),
    ),
    home: const _ExampleDocumentHost(),
  );
}

/// Independent host: no GetX, no NetSales app services, and its own branding.
class _ExampleDocumentHost extends StatelessWidget {
  const _ExampleDocumentHost();

  Future<DocumentArtifact?> _buildArtifact() async {
    final generatedAt = DateTime.utc(2026, 11, 9, 12);
    final snapshot = DocumentSnapshot(
      metadata: DocumentMetadata(
        id: DocumentId('northstar-operations-brief-20261109'),
        documentTypeId: DocumentTypeId('northstar.operations.brief'),
        title: 'Northstar Operations Brief',
        subtitle: 'Independent host integration demonstration',
        locale: DocumentLocale(
          languageTag: 'en',
          direction: DocumentTextDirection.leftToRight,
        ),
        reference: 'NS-OPS-2026-1109',
        createdAt: generatedAt,
        timeZoneId: 'UTC',
      ),
      sections: [
        DocumentSection(
          id: 'overview',
          title: 'Executive snapshot',
          nodes: [
            DocumentMetricGrid(
              columns: 3,
              metrics: [
                DocumentMetric(
                  label: 'Active sites',
                  value: DocumentIntegerValue(42),
                ),
                DocumentMetric(
                  label: 'Open work orders',
                  value: DocumentIntegerValue(7),
                ),
                DocumentMetric(
                  label: 'Service availability',
                  value: DocumentTextValue('99.95%'),
                ),
              ],
            ),
            DocumentChart(
              title: 'Weekly service volume',
              type: DocumentChartType.line,
              series: [
                DocumentChartSeries(
                  id: 'service-volume',
                  label: 'Completed jobs',
                  points: [
                    DocumentChartPoint(label: 'Mon', value: 18),
                    DocumentChartPoint(label: 'Tue', value: 22),
                    DocumentChartPoint(label: 'Wed', value: 19),
                    DocumentChartPoint(label: 'Thu', value: 27),
                    DocumentChartPoint(label: 'Fri', value: 31),
                    DocumentChartPoint(label: 'Sat', value: 24),
                    DocumentChartPoint(label: 'Sun', value: 29),
                  ],
                ),
              ],
            ),
            DocumentSignatureArea(
              label: 'Reviewed by',
              signerName: 'Alex Morgan',
              roleLabel: 'Operations Director',
              approvalReference: 'NS-REVIEW-1109',
              approvedAt: generatedAt,
            ),
          ],
        ),
      ],
      schemaVersion: 1,
    );

    final template = DocumentTemplateDefinition(
      id: TemplateId('northstar.operations.branded'),
      version: TemplateVersion(major: 1, minor: 0, patch: 0),
      documentTypeId: DocumentTypeId('northstar.operations.brief'),
      displayName: 'Northstar Branded Operations Brief',
      supportedLocaleTags: const ['en'],
      capabilities: TemplateCapabilities([
        TemplateCapability.metrics,
        TemplateCapability.charts,
        TemplateCapability.signatureArea,
        TemplateCapability.watermark,
        TemplateCapability.pageNumbering,
        TemplateCapability.portraitPage,
      ]),
      isDefault: true,
    );

    final result = await const PdfDocumentRenderer().render(
      snapshot: snapshot,
      template: template,
      options: DocumentRenderOptions(
        pageProfile: DocumentPageProfile.a4Portrait(),
        generatedAt: generatedAt,
        watermark: DocumentWatermark(
          text: 'NORTHSTAR INTERNAL',
          color: '0F766E',
          opacity: 0.08,
        ),
      ),
    );
    return result is DocumentRenderSuccess ? result.artifact : null;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Northstar Labs')),
    body: FutureBuilder<DocumentArtifact?>(
      future: _buildArtifact(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final artifact = snapshot.data;
        if (artifact == null) {
          return const Center(
            child: Text('The sample PDF could not be generated.'),
          );
        }
        return _ExamplePreview(artifact: artifact);
      },
    ),
  );
}

class _ExamplePreview extends StatelessWidget {
  const _ExamplePreview({required this.artifact});

  final DocumentArtifact artifact;

  @override
  Widget build(BuildContext context) {
    final adapter = const _ExampleOutputAdapter();
    final output = DocumentOutputCoordinator(
      savePort: adapter,
      sharePort: adapter,
      printPort: adapter,
    );
    const fileName = 'Northstar-Operations-Brief.pdf';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: DocumentArtifactPreview(
        artifact: artifact,
        title: 'Northstar Operations Brief',
        toolbar: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => _run(
                context,
                output.save(artifact: artifact, fileName: fileName),
              ),
              icon: const Icon(Icons.save_alt),
              label: const Text('Save'),
            ),
            OutlinedButton.icon(
              onPressed: () => _run(
                context,
                output.share(artifact: artifact, fileName: fileName),
              ),
              icon: const Icon(Icons.share),
              label: const Text('Share'),
            ),
            OutlinedButton.icon(
              onPressed: () => _run(
                context,
                output.print(artifact: artifact, fileName: fileName),
              ),
              icon: const Icon(Icons.print),
              label: const Text('Print'),
            ),
          ],
        ),
        metadataPanel: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Artifact integrity'),
                const SizedBox(height: 8),
                Text('Bytes: ${artifact.byteLength}'),
                Text('SHA-256: ${artifact.sha256.substring(0, 20)}…'),
                Text('Pages: ${artifact.pageCount ?? 'Unknown'}'),
                const SizedBox(height: 8),
                const Text('Brand profile: Northstar Teal'),
                const Text('Host architecture: Flutter Material, no GetX'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _run(
    BuildContext context,
    Future<DocumentOutputResult> operation,
  ) async {
    final result = await operation;
    if (!context.mounted) return;
    final message = switch (result) {
      DocumentOutputSuccess() => 'Output operation completed.',
      DocumentOutputCancelled() => 'Operation cancelled.',
      DocumentOutputFailure(:final message) => message,
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ExampleOutputAdapter
    implements DocumentSavePort, DocumentSharePort, DocumentPrintPort {
  const _ExampleOutputAdapter();

  @override
  Future<DocumentOutputResult> save(DocumentOutputRequest request) async {
    final path = await FilePicker.saveFile(
      fileName: request.fileName,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      bytes: request.artifact.bytes,
    );
    return path == null
        ? const DocumentOutputCancelled()
        : DocumentOutputSuccess(location: path);
  }

  @override
  Future<DocumentOutputResult> share(DocumentOutputRequest request) async {
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            request.artifact.bytes,
            mimeType: 'application/pdf',
            name: request.fileName,
          ),
        ],
        fileNameOverrides: [request.fileName],
      ),
    );
    return result.status == ShareResultStatus.dismissed
        ? const DocumentOutputCancelled()
        : const DocumentOutputSuccess();
  }

  @override
  Future<DocumentOutputResult> print(DocumentOutputRequest request) async {
    final printed = await Printing.layoutPdf(
      name: request.fileName,
      dynamicLayout: false,
      onLayout: (_) async => request.artifact.bytes,
    );
    return printed
        ? const DocumentOutputSuccess()
        : const DocumentOutputCancelled();
  }
}
