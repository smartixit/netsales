import 'package:flutter/material.dart';

import 'document_pdf_bytes_preview.dart';

import '../rendering/document_render_result.dart';

/// Custom preview surface for a previously generated immutable artifact.
///
/// The printing package's built-in action bar is disabled. The host supplies
/// its own toolbar and metadata UI, then routes actions through
/// DocumentOutputCoordinator. This widget never invokes the renderer.
class DocumentArtifactPreview extends StatelessWidget {
  const DocumentArtifactPreview({
    required this.artifact,
    this.title,
    this.toolbar,
    this.metadataPanel,
    this.loadingWidget,
    this.errorBuilder,
    this.headerBuilder,
    this.padding = const EdgeInsets.all(16),
    this.previewPageMargin = const EdgeInsets.all(12),
    this.maxPageWidth = 900,
    super.key,
  });

  final DocumentArtifact artifact;
  final String? title;
  final Widget? toolbar;
  final Widget? metadataPanel;
  final Widget? loadingWidget;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final Widget Function(BuildContext context, DocumentArtifact artifact)?
  headerBuilder;
  final EdgeInsets padding;
  final EdgeInsets previewPageMargin;
  final double maxPageWidth;

  @override
  Widget build(BuildContext context) {
    final preview = DocumentPdfBytesPreview(
      bytes: artifact.bytes,
      fileName: 'document.pdf',
      loadingWidget: loadingWidget,
      errorBuilder: errorBuilder,
      padding: padding,
      previewPageMargin: previewPageMargin,
      maxPageWidth: maxPageWidth,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 960 && metadataPanel != null;
        final header =
            headerBuilder?.call(context, artifact) ??
            _DefaultHeader(
              title: title ?? artifact.documentId.value,
              pageCount: artifact.pageCount,
              toolbar: toolbar,
            );

        if (wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: preview),
                    SizedBox(width: 280, child: metadataPanel),
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            Expanded(child: preview),
            ?metadataPanel,
          ],
        );
      },
    );
  }
}

class _DefaultHeader extends StatelessWidget {
  const _DefaultHeader({
    required this.title,
    required this.pageCount,
    this.toolbar,
  });

  final String title;
  final int? pageCount;
  final Widget? toolbar;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleMedium),
                if (pageCount != null)
                  Text('$pageCount pages', style: textTheme.bodySmall),
              ],
            ),
          ),
          ?toolbar,
        ],
      ),
    );
  }
}
