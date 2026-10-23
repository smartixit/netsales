import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:netsales/core/utils/file_size_formatter.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart';
import 'package:netsales/core/cache/netsales_cache_manager.dart';
import 'package:netsales/core/config/app_environment.dart';
import 'package:path_provider/path_provider.dart';

/// عنصر كاش الذاكرة المؤقتة مع معلومات انتهاء الصلاحية والوسوم
class _MemoryCacheEntry<T> {
  final T data;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Set<String> tags;

  _MemoryCacheEntry({
    required this.data,
    required this.createdAt,
    this.expiresAt,
    Set<String>? tags,
  }) : tags = tags ?? <String>{};

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}

/// خدمة الكاش المركزية الموحدة والشاملة لكافة قطاعات نظام NetSales (AppCacheService)
///
/// تجمع وتنسق بين:
/// 1. **كاش الوسائط والملفات (Media & Files):** إدارة التخزين المؤقت للصور والمستندات
///    والـ PDF على القرص والذاكرة عبر [NetSalesCacheManager].
/// 2. **كاش البيانات والذاكرة الحية (Data & Memory with TTL):** تخزين كائنات الدومين
///    ونتائج الاستعلامات المؤقتة مع دعم مدة الصلاحية وإبطال الكاش المجمّع بالوسوم (Tags).
/// 3. **تشخيص وإفراغ الكاش (Diagnostics & Sanitation):** حساب الحجم الفعلي للكاش
///    وتفريغه بأمان عند تسجيل الخروج أو بناءً على طلب المستخدم.
class AppCacheService {
  AppCacheService._();

  static final AppCacheService instance = AppCacheService._();

  NetSalesCacheManager get _cacheManager => NetSalesCacheManager.instance;

  // حاوية كاش الذاكرة الحية (In-Memory Cache)
  final Map<String, _MemoryCacheEntry<dynamic>> _memoryCache = {};

  // ===========================================================================
  // 1. قطاع كاش الوسائط والملفات (Media & Attachment Cache)
  // ===========================================================================

  /// جلب الملف من الكاش المحلي فوراً أو تحميله عبر الشبكة وتخزينه
  Future<File> getFile(String url, {Map<String, String>? headers}) async {
    final normalizedUrl = NetSalesDioFileService.normalizeMediaUrl(url);
    try {
      return await _cacheManager.getSingleFile(normalizedUrl, headers: headers);
    } catch (e) {
      if (AppEnvironment.enableLogging) {
        log('❌ AppCacheService.getFile فشل التحميل [$normalizedUrl]: $e');
      }
      rethrow;
    }
  }

  /// جلب بايتات الملف الثنائية من الكاش أو الشبكة
  Future<Uint8List?> getBytes(
    String url, {
    Map<String, String>? headers,
  }) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;

    try {
      final file = await getFile(trimmed, headers: headers);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      if (AppEnvironment.enableLogging) {
        log('⚠️ AppCacheService.getBytes خطأ أثناء القراءة [$trimmed]: $e');
      }
      return null;
    }
  }

  /// إبطال وحذف ملف وسائط معين من كاش القرص وكاش محرك تسييل الصور في فلاتر
  Future<void> evictMedia(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    final normalizedUrl = NetSalesDioFileService.normalizeMediaUrl(url.trim());

    try {
      // 1. الحذف من كاش القرص flutter_cache_manager
      await _cacheManager.removeFile(normalizedUrl);
    } catch (e) {
      if (AppEnvironment.enableLogging) {
        log('⚠️ AppCacheService.evictMedia خطأ كاش القرص: $e');
      }
    }

    try {
      // 2. الحذف من كاش صور فلاتر بالذاكرة
      await CachedNetworkImage.evictFromCache(
        normalizedUrl,
        cacheManager: _cacheManager,
      );
      PaintingBinding.instance.imageCache.evict(
        CachedNetworkImageProvider(normalizedUrl, cacheManager: _cacheManager),
      );
    } catch (e) {
      if (AppEnvironment.enableLogging) {
        log('⚠️ AppCacheService.evictMedia خطأ كاش الذاكرة: $e');
      }
    }
  }

  /// حساب الحجم الإجمالي لكاش الوسائط الفعلي على القرص بالبايت
  Future<int> getCacheSizeBytes() async {
    var totalBytes = 0;

    try {
      final tempDir = await getTemporaryDirectory();
      if (!await tempDir.exists()) return 0;

      await for (final entity in tempDir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File) {
          try {
            final path = entity.path.toLowerCase();
            if (path.contains(NetSalesCacheManager.key.toLowerCase()) ||
                path.contains('cache') ||
                path.contains('.jpg') ||
                path.contains('.png') ||
                path.contains('.pdf') ||
                path.contains('.webp')) {
              totalBytes += await entity.length();
            }
          } catch (_) {
            // تجاهل الملفات المقفولة بواسطة النظام
          }
        }
      }
    } catch (e) {
      if (AppEnvironment.enableLogging) {
        log('⚠️ AppCacheService.getCacheSizeBytes خطأ أثناء حساب الحجم: $e');
      }
    }

    return totalBytes;
  }

  /// إرجاع حجم كاش الوسائط بصيغة عربية منسقة (ميجابايت / كيلوبايت)
  Future<String> getFormattedCacheSize() async {
    final bytes = await getCacheSizeBytes();
    return FileSizeFormatter.format(bytes);
  }

  /// تفريغ كاش الوسائط والملفات بالكامل من القرص والذاكرة
  Future<bool> clearMediaCache() async {
    var success = true;

    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (_) {}

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return true;
    }

    try {
      await _cacheManager.emptyCache();
    } catch (e) {
      if (AppEnvironment.enableLogging) {
        log('⚠️ AppCacheService.clearMediaCache فشل تفريغ كاش المدير: $e');
      }
      success = false;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await for (final entity in tempDir.list(
          recursive: true,
          followLinks: false,
        )) {
          if (entity is File) {
            final path = entity.path.toLowerCase();
            if (path.contains(NetSalesCacheManager.key.toLowerCase())) {
              try {
                await entity.delete();
              } catch (_) {}
            }
          }
        }
      }
    } catch (_) {}

    return success;
  }

  // ===========================================================================
  // 2. قطاع كاش البيانات والذاكرة الحية مع الصلاحية والوسوم (Data & TTL Cache)
  // ===========================================================================

  /// تخزين قيمة في كاش الذاكرة مع مدة صلاحية اختيارية ووسوم تجميعية
  void set<T>(
    String key,
    T data, {
    Duration? ttl,
    List<String>? tags,
  }) {
    final now = DateTime.now();
    final expiresAt = ttl != null ? now.add(ttl) : null;
    _memoryCache[key] = _MemoryCacheEntry<T>(
      data: data,
      createdAt: now,
      expiresAt: expiresAt,
      tags: tags?.toSet(),
    );
  }

  /// جلب قيمة مخزنة في كاش الذاكرة إذا كانت صالحة وغير منتهية
  T? get<T>(String key) {
    final entry = _memoryCache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _memoryCache.remove(key);
      return null;
    }

    return entry.data as T?;
  }

  /// التحقق من وجود مفتاح صالح وغير منتهي في كاش البيانات
  bool has(String key) {
    return get<dynamic>(key) != null;
  }

  /// إبطال مفتاح بيانات معين
  void invalidate(String key) {
    _memoryCache.remove(key);
  }

  /// إبطال مجموعة بيانات مرتبطة بوسم معين دفعة واحدة (Bulk Tag Invalidation)
  ///
  /// يُستخدم مثلاً عند تعديل باقات الشبكة لإبطال كل ما وُسم بـ 'packages'
  void invalidateByTag(String tag) {
    _memoryCache.removeWhere((key, entry) => entry.tags.contains(tag));
  }

  /// تفريغ كاش بيانات الذاكرة بالكامل
  void clearDataCache() {
    _memoryCache.clear();
  }

  // ===========================================================================
  // 3. التنظيف الأمني الشامل لكافة قطاعات الكاش (Full Cache Wipe on Logout)
  // ===========================================================================

  /// تفريغ كامل وشامل لكافة أنواع الكاش (الوسائط + البيانات) لحماية الخصوصية عند تسجيل الخروج
  Future<void> clearAllCache() async {
    clearDataCache();
    await clearMediaCache();
  }
}
