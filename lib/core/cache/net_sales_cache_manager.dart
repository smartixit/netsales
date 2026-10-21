import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:netsales/core/config/app_environment.dart';
import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/core/services/device_service.dart';
import 'package:netsales/core/services/infinityfree_challenge_solver.dart';
import 'package:netsales/core/services/storage_service.dart';

/// مدير الكاش المؤمّن لوسائط وملفات نظام NetSales (NetSalesCacheManager)
///
/// يدير التخزين المؤقت المحلي للملفات والصور والمستندات على القرص والذاكرة مع:
/// - حل تحديات الاستضافة الأمنية وتصفية صفحات الـ HTML.
/// - حقن ترويسات الجلسة والأمان (X-Session-ID, X-Device-Uuid, Authorization).
/// - منع تلويث الكاش باستجابات الأخطاء (Anti-Cache Poisoning).
/// - تطبيق سياسة استبقاء LRU بسقف 500 عنصر ومدة 14 يوماً.
class NetSalesCacheManager extends CacheManager {
  static const String key = 'netsales_secure_media_cache';

  static final NetSalesCacheManager _instance = NetSalesCacheManager._();
  static NetSalesCacheManager get instance => _instance;

  NetSalesCacheManager._()
      : super(
          Config(
            key,
            stalePeriod: const Duration(days: 14),
            maxNrOfCacheObjects: 500,
            fileService: NetSalesDioFileService(),
          ),
        );
}

/// خدمة جلب الملفات عبر شبكة مؤمنة تعتمد على كائن [Dio] الخاص بـ [ApiService].
class NetSalesDioFileService extends FileService {
  final ApiService _apiService;

  NetSalesDioFileService({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final normalizedUrl = normalizeMediaUrl(url);
    final uri = Uri.parse(normalizedUrl);

    final mergedHeaders = <String, dynamic>{
      'Accept': '*/*',
    };

    if (headers != null) {
      mergedHeaders.addAll(headers);
    }

    // حقن ترويسات الجلسة والأمان تلقائياً إن وجدت
    final sessionId = StorageService.instance.getString(StorageKeys.session);
    if (sessionId != null && sessionId.isNotEmpty) {
      mergedHeaders['X-Session-Id'] = sessionId;
      mergedHeaders['Authorization'] = 'Bearer $sessionId';
    }

    final deviceUuid = DeviceService.instance.deviceUuid;
    if (deviceUuid.isNotEmpty) {
      mergedHeaders['X-Device-Uuid'] = deviceUuid;
    }

    try {
      final response = await _apiService.dio.getUri<dynamic>(
        uri,
        options: Options(
          responseType: ResponseType.bytes,
          headers: mergedHeaders,
          validateStatus: (status) => status != null && status < 400,
        ),
      );

      final data = response.data;
      Uint8List bytes;
      if (data is Uint8List) {
        bytes = data;
      } else if (data is List<int>) {
        bytes = Uint8List.fromList(data);
      } else if (data is String) {
        bytes = Uint8List.fromList(data.codeUnits);
      } else {
        throw HttpExceptionWithStatus(
          response.statusCode ?? 500,
          'Invalid response data type: ${data.runtimeType}',
          uri: uri,
        );
      }

      // حماية الكاش من صفحات التحدي الأمني HTML Challenge
      if (InfinityFreeChallengeSolver.isChallengeBody(bytes) ||
          InfinityFreeChallengeSolver.computeFromBytes(bytes) != null) {
        if (AppEnvironment.enableLogging) {
          log('⚠️ NetSalesDioFileService: تم اكتشاف صفحة تحدي أمني HTML، تم منع حفظها في الكاش [$url]');
        }
        throw HttpExceptionWithStatus(
          403,
          'Security challenge page received instead of binary asset',
          uri: uri,
        );
      }

      // التحقق الصارم من نوع المحتوى: رفض صفحات HTML والـ JSON التي تشير لأخطاء
      final contentType = response.headers
          .value(HttpHeaders.contentTypeHeader)
          ?.toLowerCase();
      if (contentType != null &&
          (contentType.contains('text/html') ||
              contentType.contains('application/xhtml+xml') ||
              contentType.contains('application/json'))) {
        throw HttpExceptionWithStatus(
          415,
          'Invalid Content-Type for media asset: $contentType',
          uri: uri,
        );
      }

      final extension = extractExtension(uri.path, contentType);

      return NetSalesDioFileResponse(
        response: response,
        bytes: bytes,
        fileExtension: extension,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 500;
      throw HttpExceptionWithStatus(
        statusCode,
        e.message ?? 'DioException during asset fetch',
        uri: uri,
      );
    }
  }

  /// تطبيع روابط الملفات والوسائط وفق مسارات الباك إند المعتمدة في NetSales
  static String normalizeMediaUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return trimmed;

    // إذا كان الرابط كاملاً بمفتاحه البروتوكولي (http:// أو https://)
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final cleanBase = ApiConstants.baseUrl.replaceAll(RegExp(r'/+$'), '');

    // مسار يبدأ بـ /api/v1/files/
    if (trimmed.startsWith('/api/v1/')) {
      final uri = Uri.parse(cleanBase);
      final origin = '${uri.scheme}://${uri.authority}';
      return '$origin$trimmed';
    }

    // مسار يبدأ بـ /files/ أو files/
    if (trimmed.startsWith('/files/') || trimmed.startsWith('files/')) {
      final pathPart = trimmed.startsWith('/') ? trimmed : '/$trimmed';
      return '$cleanBase$pathPart';
    }

    // مسار نسبي مباشر من القرص المحمي (مثل networks/logos/... أو users/avatars/...)
    final cleanPath = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    return '$cleanBase/files/$cleanPath';
  }

  /// استخراج الامتداد المناسب بناءً على المسار ونوع MIME
  static String extractExtension(String path, String? contentType) {
    // 1. محاولة استخراجه من مسار الرابط
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < path.length - 1) {
      final ext = path.substring(dotIndex).toLowerCase();
      if (ext.length <= 5 && !ext.contains('/')) {
        return ext;
      }
    }

    // 2. الاستدلال عبر ترويسة Content-Type
    if (contentType != null) {
      if (contentType.contains('image/jpeg')) return '.jpg';
      if (contentType.contains('image/png')) return '.png';
      if (contentType.contains('image/webp')) return '.webp';
      if (contentType.contains('image/gif')) return '.gif';
      if (contentType.contains('image/svg')) return '.svg';
      if (contentType.contains('application/pdf')) return '.pdf';
      if (contentType.contains('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')) {
        return '.xlsx';
      }
      if (contentType.contains('application/vnd.ms-excel')) return '.xls';
      if (contentType.contains('text/csv')) return '.csv';
      if (contentType.contains('application/zip')) return '.zip';
    }

    return '.bin';
  }
}

/// كائن رد خدمة الملفات المتوافق مع [FileServiceResponse] لمكتبة flutter_cache_manager.
class NetSalesDioFileResponse implements FileServiceResponse {
  final Response<dynamic> _response;
  final Uint8List _bytes;
  final String _fileExtension;
  final DateTime _receivedTime;

  NetSalesDioFileResponse({
    required Response<dynamic> response,
    required Uint8List bytes,
    required String fileExtension,
  })  : _response = response,
        _bytes = bytes,
        _fileExtension = fileExtension,
        _receivedTime = DateTime.now();

  @override
  Stream<List<int>> get content => Stream.value(_bytes);

  @override
  int? get contentLength => _bytes.length;

  @override
  int get statusCode => _response.statusCode ?? 200;

  @override
  DateTime get validTill => _receivedTime.add(const Duration(days: 14));

  @override
  String? get eTag => _response.headers.value(HttpHeaders.etagHeader);

  @override
  String get fileExtension => _fileExtension;
}
