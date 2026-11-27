import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:netsales/core/exceptions/app_exception.dart';

/// التقاط RepaintBoundary كصورة PNG دون وضع منطق التصوير داخل Widgets.
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
    await WidgetsBinding.instance.endOfFrame;

    final renderObject = boundaryKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw const AppException('تعذر تجهيز بطاقة الدعوة للتصدير.');
    }

    final image = await renderObject.toImage(pixelRatio: pixelRatio);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        throw const AppException('تعذر تحويل بطاقة الدعوة إلى صورة.');
      }
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      if (bytes.isEmpty) {
        throw const AppException('الصورة الناتجة لبطاقة الدعوة فارغة.');
      }
      return bytes;
    } finally {
      image.dispose();
    }
  }
}
