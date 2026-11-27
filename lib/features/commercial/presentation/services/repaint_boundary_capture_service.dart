import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/widgets/charts/adapters/netsales_charts_export_adapter.dart';

/// يضيف تجهيز أصول بطاقة الدعوة فوق آلية التقاط PNG المشتركة المعتمدة في النظام.
class RepaintBoundaryCaptureService {
  const RepaintBoundaryCaptureService._();

  static Future<Uint8List> capture({
    required BuildContext context,
    required GlobalKey boundaryKey,
    String? preloadAsset,
    double pixelRatio = 1,
  }) async {
    if (preloadAsset != null) {
      await precacheImage(AssetImage(preloadAsset), context);
    }

    final bytes = await NetSalesChartsExportAdapter.capturePng(
      boundaryKey,
      pixelRatio: pixelRatio,
    );
    if (bytes == null || bytes.isEmpty) {
      throw const AppException('تعذر تجهيز بطاقة الدعوة للتصدير.');
    }
    return bytes;
  }
}
