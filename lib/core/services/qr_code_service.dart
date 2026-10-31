import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:share_plus/share_plus.dart';

import 'package:netsales/core/services/file_export_service.dart';

/// ============================================================================
/// نتيجة عملية توليد QR
/// ============================================================================
class QrCodeGenerationResult {
  final bool isSuccess;
  final Uint8List? bytes;
  final String? errorMessage;
  final Object? error;

  const QrCodeGenerationResult({
    required this.isSuccess,
    this.bytes,
    this.errorMessage,
    this.error,
  });

  factory QrCodeGenerationResult.success(Uint8List bytes) {
    return QrCodeGenerationResult(isSuccess: true, bytes: bytes);
  }

  factory QrCodeGenerationResult.failure(String message, {Object? error}) {
    return QrCodeGenerationResult(
      isSuccess: false,
      errorMessage: message,
      error: error,
    );
  }
}

/// ============================================================================
/// نتيجة عملية مشاركة QR
/// ============================================================================
class QrCodeShareResult {
  final bool isSuccess;
  final ShareResultStatus? status;
  final String? errorMessage;
  final Object? error;

  const QrCodeShareResult({
    required this.isSuccess,
    this.status,
    this.errorMessage,
    this.error,
  });

  factory QrCodeShareResult.success(ShareResultStatus status) {
    return QrCodeShareResult(isSuccess: true, status: status);
  }

  factory QrCodeShareResult.failure(
    String message, {
    Object? error,
    ShareResultStatus? status,
  }) {
    return QrCodeShareResult(
      isSuccess: false,
      status: status,
      errorMessage: message,
      error: error,
    );
  }
}

/// ============================================================================
/// إعدادات خدمة QR
/// ============================================================================
class QrCodeServiceConfig {
  final int defaultExportSize;
  final String defaultFileName;
  final String exportFolderName;
  final bool enableLogging;

  const QrCodeServiceConfig({
    this.defaultExportSize = 1024,
    this.defaultFileName = 'QR_Code',
    this.exportFolderName = 'NetSales',
    this.enableLogging = true,
  });
}

/// ============================================================================
/// خدمة QR الموحدة
///
/// المسؤوليات:
/// 1. إنشاء QR Image.
/// 2. تحويل QR إلى PNG.
/// 3. حفظ QR.
/// 4. مشاركة QR.
///
/// تعتمد على:
/// - pretty_qr_code
/// - FileExportService
/// - share_plus
/// ============================================================================
class QrCodeService {
  QrCodeService._();

  static final QrCodeService instance = QrCodeService._();

  QrCodeServiceConfig _config = const QrCodeServiceConfig();

  /// تحديث إعدادات الخدمة
  void configure(QrCodeServiceConfig config) {
    _config = config;
  }

  // ===========================================================================
  // 1. إنشاء QR Image
  // ===========================================================================

  /// إنشاء كائن QR قابل للعرض أو التصدير.
  ///
  /// لا يتم إنشاء QrImage داخل build مباشرة.
  static QrImage createQrImage({required String data}) {
    final cleanData = data.trim();

    if (cleanData.isEmpty) {
      throw ArgumentError('بيانات QR لا يمكن أن تكون فارغة.');
    }

    final qrCode = QrCode.fromData(data: cleanData, errorCorrectLevel: 1);

    return QrImage(qrCode);
  }

  // ===========================================================================
  // 2. تحويل QR إلى صورة PNG
  // ===========================================================================

  Future<QrCodeGenerationResult> generateImage({
    required String data,
    PrettyQrDecoration decoration = const PrettyQrDecoration(),
    int? size,
    ImageConfiguration configuration = ImageConfiguration.empty,
  }) async {
    try {
      final qrImage = createQrImage(data: data);

      return await generateImageFromQrImage(
        qrImage: qrImage,
        decoration: decoration,
        size: size,
        configuration: configuration,
      );
    } catch (e) {
      return QrCodeGenerationResult.failure('تعذر إنشاء صورة QR.', error: e);
    }
  }

  /// تحويل كائن QR موجود إلى PNG.
  ///
  /// استخدام هذه الدالة يسمح بتصدير نفس كائن QR المستخدم في العرض.
  Future<QrCodeGenerationResult> generateImageFromQrImage({
    required QrImage qrImage,
    PrettyQrDecoration decoration = const PrettyQrDecoration(),
    int? size,
    ImageConfiguration configuration = ImageConfiguration.empty,
  }) async {
    try {
      final exportSize = size ?? _config.defaultExportSize;

      if (exportSize <= 0) {
        return QrCodeGenerationResult.failure('أبعاد صورة QR غير صحيحة.');
      }

      final byteData = await qrImage.toImageAsBytes(
        size: exportSize,
        format: ui.ImageByteFormat.png,
        decoration: decoration,
        configuration: configuration,
      );

      if (byteData == null) {
        return QrCodeGenerationResult.failure('تعذر تحويل QR إلى صورة.');
      }

      final bytes = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );

      if (bytes.isEmpty) {
        return QrCodeGenerationResult.failure('الصورة الناتجة فارغة.');
      }

      return QrCodeGenerationResult.success(bytes);
    } catch (e) {
      return QrCodeGenerationResult.failure(
        'حدث خطأ أثناء توليد صورة QR.',
        error: e,
      );
    }
  }

  // ===========================================================================
  // 3. حفظ QR
  // ===========================================================================

  Future<FileExportResult> saveQrCode({
    required String data,
    String? fileName,
    PrettyQrDecoration decoration = const PrettyQrDecoration(),
    int? size,
    String? folderName,
    FileNamingStrategy namingStrategy = FileNamingStrategy.enterprise,
    ImageConfiguration configuration = ImageConfiguration.empty,
    bool autoOpen = false,
    bool showFeedback = true,
  }) async {
    final generationResult = await generateImage(
      data: data,
      decoration: decoration,
      size: size,
      configuration: configuration,
    );

    if (!generationResult.isSuccess || generationResult.bytes == null) {
      return FileExportResult.failure(
        generationResult.errorMessage ?? 'تعذر إنشاء صورة QR.',
      );
    }

    return FileExportService.instance.saveFile(
      bytes: generationResult.bytes!,
      fileName: fileName ?? _config.defaultFileName,
      extension: 'png',
      folderName: folderName ?? _config.exportFolderName,
      namingStrategy: namingStrategy,
      autoOpen: autoOpen,
      showFeedback: showFeedback,
    );
  }

  // ===========================================================================
  // 4. مشاركة QR
  // ===========================================================================

  Future<QrCodeShareResult> shareQrCode({
    required String data,
    String? fileName,
    String? shareTitle,
    String? shareText,
    PrettyQrDecoration decoration = const PrettyQrDecoration(),
    int? size,
    ImageConfiguration configuration = ImageConfiguration.empty,
    Rect? sharePositionOrigin,
  }) async {
    try {
      final generationResult = await generateImage(
        data: data,
        decoration: decoration,
        size: size,
        configuration: configuration,
      );

      if (!generationResult.isSuccess || generationResult.bytes == null) {
        return QrCodeShareResult.failure(
          generationResult.errorMessage ?? 'تعذر إنشاء صورة QR.',
        );
      }

      final imageFile = XFile.fromData(
        generationResult.bytes!,
        mimeType: 'image/png',
        name: '${fileName ?? _config.defaultFileName}.png',
      );

      final result = await SharePlus.instance.share(
        ShareParams(
          title: shareTitle,
          text: shareText,
          files: [imageFile],
          fileNameOverrides: ['${fileName ?? _config.defaultFileName}.png'],
          sharePositionOrigin: sharePositionOrigin,
        ),
      );

      return QrCodeShareResult.success(result.status);
    } catch (e) {
      return QrCodeShareResult.failure('تعذرت مشاركة صورة QR.', error: e);
    }
  }
}
