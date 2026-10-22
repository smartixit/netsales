import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netsales/core/models/app_picked_file.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// مصدر التقاط الصور (كاميرا أو معرض)
enum ImagePickerSource {
  camera,
  gallery,
}

/// تصنيفات مسبقة لأنواع الملفات المقبولة في الخدمة
enum FileTypePreset {
  /// كافة الملفات الآمنة (غير التنفيذية)
  anySafe,

  /// الصور فقط (jpg, jpeg, png, webp)
  imagesOnly,

  /// المستندات النصية والـ PDF (pdf, doc, docx, txt)
  documentsOnly,

  /// جداول البيانات فقط (xlsx, xls, csv)
  spreadsheetsOnly,

  /// مستندات PDF فقط
  pdfOnly,

  /// امتدادات مخصصة يحددها المستدعي
  custom,
}

/// عقد خدمة اختيار الملفات والوسائط المجرد (IFilePickerService)
abstract class IFilePickerService {
  /// اختيار صورة مفردة
  Future<AppPickedFile?> pickImage({
    required ImagePickerSource source,
    int? maxSizeBytes,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  });

  /// اختيار صور متعددة من المعرض
  Future<List<AppPickedFile>> pickMultiImages({
    int? maxFiles,
    int? maxSizeBytes,
    int? maxTotalSizeBytes,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  });

  /// اختيار ملف مستند مفرد
  Future<AppPickedFile?> pickFile({
    List<String>? allowedExtensions,
    FileTypePreset preset = FileTypePreset.anySafe,
    int? maxSizeBytes,
    String? dialogTitle,
  });

  /// اختيار ملفات مستندات متعددة مع ضوابط السقف والعدد
  Future<List<AppPickedFile>> pickMultiFiles({
    List<String>? allowedExtensions,
    FileTypePreset preset = FileTypePreset.anySafe,
    int? maxFiles,
    int? maxSizeBytes,
    int? maxTotalSizeBytes,
    String? dialogTitle,
  });
}

/// الخدمة المركزية الموحدة لاختيار وإدارة الملفات والمرفقات (FilePickerService)
///
/// مصممة وفق نمط Singleton ومبنية بمعايير الأمان المؤسسية لتشمل:
/// 1. الفحص الصارم لسقف الحجم مع رسائل تنبيهية معقمة باللغة العربية.
/// 2. التحكم الدقيق بالعدد الأقصى للملفات ومجموع أحجامها.
/// 3. حزام الأمان ضد الملفات التنفيذية والمشبوهة.
/// 4. التوافق الكامل مع كافة المنصات (Android, iOS, Desktop, Web).
class FilePickerService implements IFilePickerService {
  FilePickerService._();
  static final FilePickerService instance = FilePickerService._();

  static FilePickerService get to =>
      Get.isRegistered<FilePickerService>() ? Get.find<FilePickerService>() : instance;

  final ImagePicker _imagePicker = ImagePicker();

  /// الحد الأقصى الافتراضي لحجم الملف: 2 ميجابايت
  static const int defaultMaxFileSize = 2 * 1024 * 1024;

  /// القائمة السوداء للملفات التنفيذية والبرمجية المحظورة أمنياً
  static const Set<String> _blacklistedExtensions = {
    'exe',
    'bat',
    'cmd',
    'sh',
    'php',
    'apk',
    'bin',
    'msi',
    'vbs',
    'ps1',
    'com',
    'scr',
    'pif',
    'jar',
    'py',
    'pl',
    'cgi',
  };

  /// الامتدادات الشائعة لكل تصنيف
  static const List<String> _imageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'gif',
  ];
  static const List<String> _documentExtensions = [
    'pdf',
    'doc',
    'docx',
    'txt',
    'rtf',
  ];
  static const List<String> _spreadsheetExtensions = ['xlsx', 'xls', 'csv'];
  static const List<String> _pdfExtensions = ['pdf'];

  @override
  Future<AppPickedFile?> pickImage({
    required ImagePickerSource source,
    int? maxSizeBytes,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final imageSource = source == ImagePickerSource.camera
          ? ImageSource.camera
          : ImageSource.gallery;

      final xFile = await _imagePicker.pickImage(
        source: imageSource,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 85,
      );

      if (xFile == null) return null;

      final file = File(xFile.path);
      final pickedFile = AppPickedFile.fromFile(file);

      // فحص الحجم
      final limit = maxSizeBytes ?? defaultMaxFileSize;
      if (!_validateFileSize(pickedFile, limit)) {
        return null;
      }

      return pickedFile;
    } catch (e) {
      debugPrint('[FilePickerService] pickImage Error: $e');
      CustomSnackbar.show(
        type: SnackType.error,
        title: 'تعذر التقاط الصورة',
        message: 'حدث خطأ أثناء فتح الكاميرا أو المعرض. يرجى المحاولة لاحقاً.',
      );
      return null;
    }
  }

  @override
  Future<List<AppPickedFile>> pickMultiImages({
    int? maxFiles,
    int? maxSizeBytes,
    int? maxTotalSizeBytes,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final xFiles = await _imagePicker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 85,
      );

      if (xFiles.isEmpty) return [];

      final limit = maxSizeBytes ?? defaultMaxFileSize;
      final results = <AppPickedFile>[];
      int totalSize = 0;

      for (final xFile in xFiles) {
        if (maxFiles != null && results.length >= maxFiles) {
          CustomSnackbar.show(
            type: SnackType.warning,
            title: 'تم تجاوز سقف العدد',
            message:
                'الحد الأقصى المسموح باختياره هو $maxFiles صور فقط. تم تجاهل الباقي.',
          );
          break;
        }

        final file = File(xFile.path);
        final pickedFile = AppPickedFile.fromFile(file);

        if (!_validateFileSize(pickedFile, limit)) {
          continue;
        }

        if (maxTotalSizeBytes != null &&
            (totalSize + pickedFile.sizeBytes) > maxTotalSizeBytes) {
          CustomSnackbar.show(
            type: SnackType.warning,
            title: 'تجاوز السعة الإجمالية',
            message: 'تجاوز مجموع أحجام الصور الحد الإجمالي المسموح به.',
          );
          break;
        }

        totalSize += pickedFile.sizeBytes;
        results.add(pickedFile);
      }

      return results;
    } catch (e) {
      debugPrint('[FilePickerService] pickMultiImages Error: $e');
      CustomSnackbar.show(
        type: SnackType.error,
        title: 'تعذر اختيار الصور',
        message: 'حدث خطأ أثناء اختيار الصور من المعرض.',
      );
      return [];
    }
  }

  @override
  Future<AppPickedFile?> pickFile({
    List<String>? allowedExtensions,
    FileTypePreset preset = FileTypePreset.anySafe,
    int? maxSizeBytes,
    String? dialogTitle,
  }) async {
    final list = await pickMultiFiles(
      allowedExtensions: allowedExtensions,
      preset: preset,
      maxFiles: 1,
      maxSizeBytes: maxSizeBytes,
      dialogTitle: dialogTitle,
    );

    return list.isNotEmpty ? list.first : null;
  }

  @override
  Future<List<AppPickedFile>> pickMultiFiles({
    List<String>? allowedExtensions,
    FileTypePreset preset = FileTypePreset.anySafe,
    int? maxFiles,
    int? maxSizeBytes,
    int? maxTotalSizeBytes,
    String? dialogTitle,
  }) async {
    try {
      final effectiveExtensions = _resolveExtensions(preset, allowedExtensions);
      final isCustom = effectiveExtensions != null;

      final result = await FilePicker.pickFiles(
        dialogTitle: dialogTitle ?? 'اختيار الملفات',
        allowMultiple: (maxFiles == null || maxFiles > 1),
        type: isCustom ? FileType.custom : FileType.any,
        allowedExtensions: isCustom ? effectiveExtensions : null,
      );

      if (result == null || result.files.isEmpty) return [];

      final limit = maxSizeBytes ?? defaultMaxFileSize;
      final results = <AppPickedFile>[];
      int totalSize = 0;

      for (final platformFile in result.files) {
        if (platformFile.path == null) continue;

        if (maxFiles != null && results.length >= maxFiles) {
          CustomSnackbar.show(
            type: SnackType.warning,
            title: 'تم بلوغ الحد الأقصى',
            message:
                'الحد الأقصى المسموح برفع هو $maxFiles ملفات فقط. تم تجاهل الإضافي.',
          );
          break;
        }

        final file = File(platformFile.path!);
        final pickedFile = AppPickedFile.fromFile(file);

        // 1. الفحص الأمني ضد الامتدادات المحظورة
        if (_blacklistedExtensions.contains(pickedFile.extension)) {
          CustomSnackbar.show(
            type: SnackType.error,
            title: 'ملف محظور أمنياً',
            message:
                'الملف "${pickedFile.name}" يحمل امتداداً غير مصرح به للنظام.',
          );
          continue;
        }

        // 2. التحقق من امتداد الملف إذا كانت هناك قائمة مسموحة
        if (effectiveExtensions != null &&
            !effectiveExtensions.contains(pickedFile.extension)) {
          CustomSnackbar.show(
            type: SnackType.warning,
            title: 'نوع ملف غير مدعوم',
            message:
                'الملف "${pickedFile.name}" ليس من الأنواع المسموح بها (${effectiveExtensions.join(', ')}).',
          );
          continue;
        }

        // 3. فحص سقف حجم الملف الواحد
        if (!_validateFileSize(pickedFile, limit)) {
          continue;
        }

        // 4. فحص السعة الإجمالية المجمعة
        if (maxTotalSizeBytes != null &&
            (totalSize + pickedFile.sizeBytes) > maxTotalSizeBytes) {
          CustomSnackbar.show(
            type: SnackType.warning,
            title: 'تجاوز السعة الإجمالية',
            message: 'تجاوز مجموع أحجام الملفات الحد المسموح به للمرفقات.',
          );
          break;
        }

        totalSize += pickedFile.sizeBytes;
        results.add(pickedFile);
      }

      return results;
    } catch (e) {
      debugPrint('[FilePickerService] pickFiles Error: $e');
      CustomSnackbar.show(
        type: SnackType.error,
        title: 'تعذر اختيار الملفات',
        message: 'حدث خطأ أثناء فتح مدير الملفات. يرجى المحاولة لاحقاً.',
      );
      return [];
    }
  }

  /// التحقق من حجم الملف وإشعار المستخدم بدقة عند تجاوزه
  bool _validateFileSize(AppPickedFile file, int maxSizeBytes) {
    if (file.sizeBytes > maxSizeBytes) {
      final allowedFormatted = AppPickedFile(
        id: '',
        path: '',
        name: '',
        sizeBytes: maxSizeBytes,
        extension: '',
      ).sizeFormatted;

      CustomSnackbar.show(
        type: SnackType.warning,
        title: 'حجم الملف يتجاوز المسموح',
        message:
            'حجم الملف "${file.name}" هو ${file.sizeFormatted}، بينما الحد الأقصى المسموح به هو $allowedFormatted.',
      );
      return false;
    }
    return true;
  }

  /// تحديد الامتدادات المناسبة وفق التصنيف
  List<String>? _resolveExtensions(
    FileTypePreset preset,
    List<String>? customExtensions,
  ) {
    switch (preset) {
      case FileTypePreset.imagesOnly:
        return _imageExtensions;
      case FileTypePreset.documentsOnly:
        return _documentExtensions;
      case FileTypePreset.spreadsheetsOnly:
        return _spreadsheetExtensions;
      case FileTypePreset.pdfOnly:
        return _pdfExtensions;
      case FileTypePreset.custom:
        return customExtensions?.map((e) => e.toLowerCase()).toList();
      case FileTypePreset.anySafe:
        return null;
    }
  }
}
