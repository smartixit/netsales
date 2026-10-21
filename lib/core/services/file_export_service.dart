import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:netsales/core/config/app_environment.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

/// استراتيجية وتنسيق تسمية الملفات المعتمد في الأنظمة والشركات العالمية (FileNamingStrategy)
///
/// تتيح التخصيص الكامل لأي مشروع مستقبلي مع اعتماد الأنماط القياسية العالمية:
/// - البادئة المؤسسية (App/Brand Prefix) مثل 'NetSales' أو 'Smartix'.
/// - تصنيف نوع الملف اختياري (Category Identifier) مثل 'IMG', 'DOC', 'SHEET'.
/// - تعقيم العنوان (Sanitization & Slugification) واستبدال المسافات والرموز غير الصالحة بالشرطات.
/// - التوقيت المعياري الدولي المقروء والفرز الزمني الأبجدي التلقائي (ISO-8601 Compact: YYYYMMDD_HHmmss).
/// - تقييد أقصى طول لتفادي قيود أنظمة التشغيل (MAX_PATH on Windows/Android).
class FileNamingStrategy {
  final String appPrefix;
  final bool includeCategory;
  final bool includeTimestamp;
  final bool useIsoTimestamp;
  final String separator;
  final String spaceReplacement;
  final int maxTitleLength;

  const FileNamingStrategy({
    this.appPrefix = 'NetSales',
    this.includeCategory = false,
    this.includeTimestamp = true,
    this.useIsoTimestamp = true,
    this.separator = '_',
    this.spaceReplacement = '-',
    this.maxTitleLength = 45,
  });

  /// النمط القياسي للشركات العالمية (Global Enterprise Standard)
  /// الصيغة: {Prefix}_{CleanTitle}_{YYYYMMDD_HHmmss}.{ext}
  /// مثال: NetSales_تقرير-المبيعات-الشهرية_20261021_180530.pdf
  static const FileNamingStrategy enterprise = FileNamingStrategy();

  /// نمط مصنف بنوع المستند (Categorized Enterprise)
  /// الصيغة: {Prefix}_{CATEGORY}_{CleanTitle}_{YYYYMMDD_HHmmss}.{ext}
  /// مثال: NetSales_DOC_فاتورة-رقم-105_20261021_180530.pdf
  static const FileNamingStrategy categorized = FileNamingStrategy(
    includeCategory: true,
  );

  /// نمط مخصص للفواتير والمستندات المالية
  static const FileNamingStrategy invoice = FileNamingStrategy(
    appPrefix: 'NetSales_INV',
  );

  /// نمط مخصص للتقارير وجداول البيانات
  static const FileNamingStrategy report = FileNamingStrategy(
    appPrefix: 'NetSales_REP',
  );
}

/// نتيجة عملية تصدير أو حفظ الملف
class FileExportResult {
  final bool isSuccess;
  final String? filePath;
  final String? fileName;
  final int bytesWritten;
  final String? errorMessage;

  const FileExportResult({
    required this.isSuccess,
    this.filePath,
    this.fileName,
    this.bytesWritten = 0,
    this.errorMessage,
  });

  factory FileExportResult.success({
    required String filePath,
    required String fileName,
    required int bytesWritten,
  }) =>
      FileExportResult(
        isSuccess: true,
        filePath: filePath,
        fileName: fileName,
        bytesWritten: bytesWritten,
      );

  factory FileExportResult.failure(String message) => FileExportResult(
        isSuccess: false,
        errorMessage: message,
      );
}

/// عقد خدمة تصدير وحفظ ومشاركة الملفات في النظام (IFileExportService)
abstract class IFileExportService {
  /// حفظ مصفوفة بايتات كملف في مجلد التنزيلات المخصص للتطبيق
  Future<FileExportResult> saveFile({
    required Uint8List bytes,
    required String fileName,
    String? extension,
    String folderName = 'NetSales',
    FileNamingStrategy namingStrategy = FileNamingStrategy.enterprise,
    DateTime? timestamp,
    bool autoOpen = true,
    bool showFeedback = true,
  });

  /// مشاركة ملف عبر نافذة مشاركة النظام الرسمية
  Future<bool> shareBytes({
    required Uint8List bytes,
    required String fileName,
    String? extension,
    FileNamingStrategy namingStrategy = FileNamingStrategy.enterprise,
    DateTime? timestamp,
  });

  /// الحصول على المجلد المخصص لحفظ تنزيلات ومخرجات التطبيق عبر كافة المنصات
  Future<Directory> getAppExportDirectory({String folderName = 'NetSales'});

  /// تنظيف وتوليد اسم ملف آمن وخالٍ من الرموز الممنوعة في كافة أنظمة التشغيل
  String sanitizeFileName(
    String fileName, {
    String? extensionToRemove,
    String spaceReplacement = '-',
    int maxLength = 45,
  });
}

/// خدمة تصدير وحفظ ومشاركة الملفات الموحدة والشاملة لكافة المنصات (FileExportService)
///
/// تم تصميمها كخدمة مستقلة قابلة لإعادة الاستخدام في أي شاشة أو مشروع مع:
/// - استراتيجية تسمية عالمية مرنة تدعم ISO-8601 Compact Sortable Timestamps.
/// - دعم متعدد المنصات (Android Scoped Storage / Downloads, iOS Documents, Windows, macOS, Linux).
/// - معالجة تفادي تصادم الأسماء وتكرار الامتدادات (Collision Resolution).
/// - الفتح التلقائي للملف فور حفظه عبر [OpenFilex].
/// - إشعارات موحدة للمستخدم عبر [CustomSnackbar].
class FileExportService implements IFileExportService {
  FileExportService._();

  static final FileExportService instance = FileExportService._();

  @override
  Future<FileExportResult> saveFile({
    required Uint8List bytes,
    required String fileName,
    String? extension,
    String folderName = 'NetSales',
    FileNamingStrategy namingStrategy = FileNamingStrategy.enterprise,
    DateTime? timestamp,
    bool autoOpen = true,
    bool showFeedback = true,
  }) async {
    if (bytes.isEmpty) {
      if (showFeedback) {
        CustomSnackbar.show(
          title: 'تنبيه',
          message: 'تعذر حفظ الملف، محتوى البيانات فارغ',
          type: SnackType.warning,
        );
      }
      return FileExportResult.failure('Empty bytes provided');
    }

    try {
      final exportDir = await getAppExportDirectory(folderName: folderName);
      final safeExt = resolveExtension(fileName: fileName, explicitExtension: extension);

      // توليد اسم الملف المؤسسي الموحد وفق استراتيجية التسمية
      final baseGeneratedName = buildFileNameWithoutExtension(
        rawTitle: fileName,
        extension: safeExt,
        strategy: namingStrategy,
        timestamp: timestamp,
      );

      // صياغة اسم ملف مميز مع منع التضارب (Collision-Proof)
      final uniqueFileName = _generateCollisionFreeFileName(
        directory: exportDir,
        baseFullName: baseGeneratedName,
        extension: safeExt,
      );

      final targetFile = File('${exportDir.path}/$uniqueFileName');
      await targetFile.writeAsBytes(bytes, flush: true);

      if (showFeedback) {
        CustomSnackbar.show(
          title: 'تم الحفظ بنجاح',
          message: 'تم حفظ الملف في مجلد التنزيلات ($folderName):\n$uniqueFileName',
          type: SnackType.success,
        );
      }

      if (autoOpen) {
        try {
          await OpenFilex.open(targetFile.path);
        } catch (openErr) {
          if (AppEnvironment.enableLogging) {
            log('⚠️ FileExportService: تعذر فتح الملف بعد حفظه: $openErr');
          }
        }
      }

      return FileExportResult.success(
        filePath: targetFile.path,
        fileName: uniqueFileName,
        bytesWritten: bytes.length,
      );
    } catch (e, stack) {
      if (AppEnvironment.enableLogging) {
        log('❌ FileExportService.saveFile خطأ أثناء التصدير: $e', stackTrace: stack);
      }
      final message = 'تعذر إتمام عملية الحفظ: $e';
      if (showFeedback) {
        CustomSnackbar.show(
          title: 'خطأ أثناء الحفظ',
          message: message,
          type: SnackType.error,
        );
      }
      return FileExportResult.failure(message);
    }
  }

  @override
  Future<bool> shareBytes({
    required Uint8List bytes,
    required String fileName,
    String? extension,
    FileNamingStrategy namingStrategy = FileNamingStrategy.enterprise,
    DateTime? timestamp,
  }) async {
    if (bytes.isEmpty) return false;

    try {
      final safeExt = resolveExtension(fileName: fileName, explicitExtension: extension);
      final baseGeneratedName = buildFileNameWithoutExtension(
        rawTitle: fileName,
        extension: safeExt,
        strategy: namingStrategy,
        timestamp: timestamp,
      );
      final finalName = '$baseGeneratedName.$safeExt';

      await Printing.sharePdf(
        bytes: bytes,
        filename: finalName,
      );
      return true;
    } catch (e) {
      if (AppEnvironment.enableLogging) {
        log('⚠️ FileExportService.shareBytes خطأ أثناء المشاركة: $e');
      }
      // محاولة بديلة: حفظ مؤقت ثم الفتح الخارجي
      try {
        final tempDir = await getTemporaryDirectory();
        final safeExt = resolveExtension(fileName: fileName, explicitExtension: extension);
        final baseGeneratedName = buildFileNameWithoutExtension(
          rawTitle: fileName,
          extension: safeExt,
          strategy: namingStrategy,
          timestamp: timestamp,
        );
        final tempFile = File('${tempDir.path}/${baseGeneratedName}_tmp.$safeExt');
        await tempFile.writeAsBytes(bytes);
        final openResult = await OpenFilex.open(tempFile.path);
        return openResult.type == ResultType.done;
      } catch (_) {
        return false;
      }
    }
  }

  @override
  Future<Directory> getAppExportDirectory({String folderName = 'NetSales'}) async {
    // 1. بيئة الاختبارات الآلية (Unit Tests)
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      final testDir = Directory('${Directory.systemTemp.path}/netsales_export_test/$folderName');
      if (!testDir.existsSync()) {
        testDir.createSync(recursive: true);
      }
      return testDir;
    }

    Directory? targetDir;

    // 2. بيئة أندرويد (Android)
    if (Platform.isAndroid) {
      try {
        // أ. مسار التنزيلات العام المباشر للجهاز (/storage/emulated/0/Download)
        final publicDownload = Directory('/storage/emulated/0/Download');
        if (publicDownload.existsSync()) {
          targetDir = Directory('${publicDownload.path}/$folderName');
        }
      } catch (_) {}

      // ب. التنزيلات عبر مسار التخزين الخارجي للتطبيق (Scoped Storage Safe)
      if (targetDir == null) {
        try {
          final extDirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
          if (extDirs != null && extDirs.isNotEmpty) {
            targetDir = Directory('${extDirs.first.path}/$folderName');
          }
        } catch (_) {}
      }
    }

    // 3. بيئات سطح المكتب (Windows / macOS / Linux)
    if (targetDir == null && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      try {
        final downloads = await getDownloadsDirectory();
        if (downloads != null) {
          targetDir = Directory('${downloads.path}/$folderName');
        }
      } catch (_) {}
    }

    // 4. بيئة نظام iOS (تخزين بمستندات التطبيق مع إتاحة المشاركة للملفات)
    if (targetDir == null && Platform.isIOS) {
      try {
        final appDocs = await getApplicationDocumentsDirectory();
        targetDir = Directory('${appDocs.path}/$folderName');
      } catch (_) {}
    }

    // 5. البديل النهائي العام (Universal Fallback)
    if (targetDir == null) {
      try {
        final appDocs = await getApplicationDocumentsDirectory();
        targetDir = Directory('${appDocs.path}/$folderName');
      } catch (_) {
        targetDir = Directory('${Directory.systemTemp.path}/$folderName');
      }
    }

    if (!targetDir.existsSync()) {
      await targetDir.create(recursive: true);
    }

    return targetDir;
  }

  @override
  String sanitizeFileName(
    String fileName, {
    String? extensionToRemove,
    String spaceReplacement = '-',
    int maxLength = 45,
  }) {
    var clean = fileName.trim();

    // إزالة الامتداد من نهاية الاسم إذا كان متطابقاً لمنع التكرار (مثل file.pdf.pdf)
    if (extensionToRemove != null && extensionToRemove.isNotEmpty) {
      final extWithDot = extensionToRemove.startsWith('.') ? extensionToRemove : '.$extensionToRemove';
      if (clean.toLowerCase().endsWith(extWithDot.toLowerCase())) {
        clean = clean.substring(0, clean.length - extWithDot.length);
      }
    }

    // استبدال الأحرف المحظورة والشرطات في أنظمة التشغيل (Windows, Android, Linux, macOS)
    clean = clean.replaceAll(RegExp(r'[\\/:*?"<>|\r\n\t#%!@$^&+=`~_]'), spaceReplacement).trim();

    // استبدال المسافات بالفاصل المحدد
    clean = clean.replaceAll(RegExp(r'\s+'), spaceReplacement);

    // تقليص الفواصل المتكررة وحذف البادئة والمنتهية
    final escapedSep = RegExp.escape(spaceReplacement);
    clean = clean.replaceAll(RegExp('$escapedSep+'), spaceReplacement);
    clean = clean.replaceAll(RegExp('^$escapedSep+|$escapedSep+\$'), '');

    // تقييد أقصى طول لتفادي تجاوز سقف الـ MAX_PATH
    if (clean.length > maxLength) {
      clean = clean.substring(0, maxLength);
      clean = clean.replaceAll(RegExp('^$escapedSep+|$escapedSep+\$'), '');
    }

    if (clean.isEmpty) {
      clean = 'ملف';
    }

    return clean;
  }

  /// استخراج الامتداد النظيف الصالح
  static String resolveExtension({
    required String fileName,
    String? explicitExtension,
  }) {
    if (explicitExtension != null && explicitExtension.trim().isNotEmpty) {
      var ext = explicitExtension.trim().toLowerCase();
      if (ext.startsWith('.')) ext = ext.substring(1);
      if (ext.isNotEmpty && ext.length <= 6) return ext;
    }

    final cleanName = fileName.split('?').first.trim();
    final dotIndex = cleanName.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < cleanName.length - 1) {
      final candidate = cleanName.substring(dotIndex + 1).toLowerCase();
      if (candidate.length <= 6 && !candidate.contains('/')) {
        return candidate;
      }
    }

    return 'bin';
  }

  /// استنتاج تصنيف الملف (IMG, DOC, SHEET, FILE)
  static String resolveCategory(String extension) {
    final ext = extension.toLowerCase().replaceAll('.', '').trim();
    if (ext == 'pdf' || ext == 'doc' || ext == 'docx' || ext == 'txt') return 'DOC';
    if (ext == 'jpg' || ext == 'jpeg' || ext == 'png' || ext == 'webp' || ext == 'gif' || ext == 'svg') {
      return 'IMG';
    }
    if (ext == 'xlsx' || ext == 'xls' || ext == 'csv') {
      return 'SHEET';
    }
    return 'FILE';
  }

  /// صياغة توقيت ISO-8601 مصغر مقروء وقابل للترتيب الأبجدي التلقائي (YYYYMMDD_HHmmss)
  static String formatIsoCompact(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$y$m${d}_$h$min$s';
  }

  /// بناء وتوليد اسم الملف الكامل بدون الامتداد وفق استراتيجية التسمية
  String buildFileNameWithoutExtension({
    required String rawTitle,
    required String extension,
    FileNamingStrategy strategy = FileNamingStrategy.enterprise,
    DateTime? timestamp,
  }) {
    final safeExt = extension.startsWith('.') ? extension.substring(1) : extension;
    final cleanTitle = sanitizeFileName(
      rawTitle,
      extensionToRemove: safeExt,
      spaceReplacement: strategy.spaceReplacement,
      maxLength: strategy.maxTitleLength,
    );

    final parts = <String>[];

    // 1. البادئة المؤسسية (مثلاً NetSales)
    if (strategy.appPrefix.isNotEmpty) {
      parts.add(strategy.appPrefix);
    }

    // 2. تصنيف نوع الملف إذا طُلب
    if (strategy.includeCategory) {
      parts.add(resolveCategory(safeExt));
    }

    // 3. العنوان المعقم
    if (cleanTitle.isNotEmpty) {
      parts.add(cleanTitle);
    }

    // 4. التوقيت الزمني (ISO-8601 Compact: YYYYMMDD_HHmmss)
    if (strategy.includeTimestamp) {
      final now = timestamp ?? DateTime.now();
      if (strategy.useIsoTimestamp) {
        parts.add(formatIsoCompact(now));
      } else {
        parts.add(now.millisecondsSinceEpoch.toString());
      }
    }

    return parts.join(strategy.separator);
  }

  /// توليد اسم ملف فريد يمنع تصادم الأسماء بإضافة أرقام تسلسلية عند وجود الملف مسبقاً
  String _generateCollisionFreeFileName({
    required Directory directory,
    required String baseFullName,
    required String extension,
  }) {
    final cleanExt = extension.startsWith('.') ? extension.substring(1) : extension;

    var candidate = '$baseFullName.$cleanExt';
    var counter = 1;

    while (File('${directory.path}/$candidate').existsSync()) {
      candidate = '$baseFullName ($counter).$cleanExt';
      counter++;
    }

    return candidate;
  }
}
