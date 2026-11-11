import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

/// Reusable read-only PDF bytes preview. It never generates or mutates a PDF.
class DocumentPdfBytesPreview extends StatelessWidget {
  const DocumentPdfBytesPreview({
    required this.bytes,
    required this.fileName,
    this.loadingWidget,
    this.errorBuilder,
    this.padding = const EdgeInsets.all(16),
    this.previewPageMargin = const EdgeInsets.all(12),
    this.maxPageWidth = 900,
    this.scrollViewDecoration,
    super.key,
  });

  final Uint8List bytes;
  final String fileName;
  final Widget? loadingWidget;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final EdgeInsets padding;
  final EdgeInsets previewPageMargin;
  final double maxPageWidth;
  final BoxDecoration? scrollViewDecoration;

  @override
  Widget build(BuildContext context) {
    return PdfPreview(
      build: (_) async => bytes,
      pdfFileName: fileName,
      allowPrinting: false,
      allowSharing: false,
      canChangePageFormat: false,
      canChangeOrientation: false,
      canDebug: false,
      useActions: false,
      loadingWidget: loadingWidget,
      onError: errorBuilder,
      padding: padding,
      previewPageMargin: previewPageMargin,
      maxPageWidth: maxPageWidth,
      dynamicLayout: false,
      scrollViewDecoration: scrollViewDecoration,
    );
  }
}
