import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:netsales/core/services/sound_service.dart';
import 'package:netsales/widgets/qr/qr_scan_result.dart';

/// متحكم ماسح الرموز الموحد (Custom QR Scanner Controller)
///
/// يدير حالة دورة حياة الكاميرا، مصباح الإضاءة، تبديل العدسات،
/// واستيراد الصور من المعرض، بالإضافة إلى التغذية الصوتية وحماية التكرار.
class CustomQrScannerController extends GetxController {
  final ValueChanged<QrScanResult>? onScan;
  final bool enableAudioFeedback;
  final bool autoStopOnScan;

  late final MobileScannerController mobileScannerController;
  final ImagePicker _imagePicker = ImagePicker();

  final RxBool isTorchOn = false.obs;
  final RxBool isFrontCamera = false.obs;
  final RxBool isProcessing = false.obs;
  final RxBool isStarting = true.obs;
  final RxnString errorMessage = RxnString();

  CustomQrScannerController({
    this.onScan,
    this.enableAudioFeedback = true,
    this.autoStopOnScan = true,
  });

  @override
  void onInit() {
    super.onInit();
    mobileScannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
      returnImage: false,
    );
    isStarting.value = false;
  }

  /// تبديل حالة مصباح الكاميرا (الفلاش)
  Future<void> toggleTorch() async {
    try {
      await mobileScannerController.toggleTorch();
      isTorchOn.value = !isTorchOn.value;
    } catch (e) {
      errorMessage.value = 'تعذر تشغيل الفلاش';
    }
  }

  /// تبديل الكاميرا (أمامية / خلفية)
  Future<void> switchCamera() async {
    try {
      await mobileScannerController.switchCamera();
      isFrontCamera.value = !isFrontCamera.value;
    } catch (e) {
      errorMessage.value = 'تعذر تبديل الكاميرا';
    }
  }

  /// استيراد صورة رمز QR من المعرض وفحصها
  Future<void> pickAndScanFromGallery() async {
    if (isProcessing.value) return;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile == null) return;

      final capture = await mobileScannerController.analyzeImage(
        pickedFile.path,
      );

      if (capture == null || capture.barcodes.isEmpty) {
        errorMessage.value = 'لم يتم العثور على رمز QR صالح في الصورة المحددة';
        return;
      }

      final validBarcode = capture.barcodes.firstWhereOrNull(
        (b) => b.rawValue != null && b.rawValue!.trim().isNotEmpty,
      );

      if (validBarcode == null || validBarcode.rawValue == null) {
        errorMessage.value = 'الرمز الموجود في الصورة غير قابل للقراءة';
        return;
      }

      await _handleSuccessfulBarcode(
        validBarcode.rawValue!,
        validBarcode.format.name,
        validBarcode.corners,
      );
    } catch (e) {
      errorMessage.value = 'فشل فحص الصورة من المعرض: ${e.toString()}';
    }
  }

  /// معالجة حزمة الباركود الملتقطة عبر الكاميرا
  void handleBarcodeCapture(BarcodeCapture capture) {
    if (isProcessing.value) return;

    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw != null && raw.trim().isNotEmpty) {
        _handleSuccessfulBarcode(raw, barcode.format.name, barcode.corners);
        break;
      }
    }
  }

  Future<void> _handleSuccessfulBarcode(
    String rawValue,
    String format,
    List<Offset>? corners,
  ) async {
    isProcessing.value = true;
    errorMessage.value = null;

    if (enableAudioFeedback) {
      try {
        await SoundService.instance.playSound(
          soundPath: 'sounds/barcode_beep.wav',
        );
      } catch (_) {}
    }

    final result = QrScanResult(
      rawValue: rawValue.trim(),
      format: format,
      scannedAt: DateTime.now(),
      corners: corners,
    );

    if (autoStopOnScan) {
      try {
        await mobileScannerController.stop();
      } catch (_) {}
    }

    onScan?.call(result);
  }

  /// استئناف المسح مجدداً بعد إتمام المعالجة أو في حال الرفض
  Future<void> resumeScanning() async {
    isProcessing.value = false;
    errorMessage.value = null;
    try {
      await mobileScannerController.start();
    } catch (_) {}
  }

  @override
  void onClose() {
    mobileScannerController.dispose();
    super.onClose();
  }
}
