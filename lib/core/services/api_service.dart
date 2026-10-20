import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:netsales/core/config/app_environment.dart';
import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/app_crypto_service.dart';
import 'package:netsales/core/services/device_service.dart';
import 'package:netsales/core/services/infinityfree_challenge_solver.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/utils/connection_failure.dart';
import 'package:sodium/sodium.dart' show KeyPair;

/// ============================================================================
/// عميل الشبكة الموحد لنظام NetSales (Core HTTP Network Client)
/// ============================================================================
/// يوفر اتصالاً شبكياً آمناً ومجرداً ومطابقاً لعقود الواجهة الخلفية netsales_api:
/// - إدارة كائن Dio مع معالجة الشهادات وإعادة المحاولة التلقائية.
/// - حقن الترويسات الرسمية (X-Session-Id, X-Device-Uuid, X-Idempotency-Key).
/// - استخراج وتنسيق الاستجابات العامة [ApiResponse<T>].
/// - تحويل أخطاء الشبكة والتحقق إلى رسائل عربية معقمة عبر [AppException].
class ApiService {
  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectTimeout,
        ),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeout,
        ),
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ),
    );

    _configureHttpClient();
    _configureInterceptors();
  }

  static final ApiService instance = ApiService._internal();
  factory ApiService() => instance;

  late final Dio _dio;
  Dio get dio => _dio;

  /// دالة رد نداء تُستدعى تلقائياً عند انتهاء صلاحية الجلسة (401 Unauthorized)
  static void Function()? onUnauthorized;

  /// تهيئة عميل الاتصال وضبط تجاوز الشهادات في بيئة التطوير
  void _configureHttpClient() {
    final allowBadCerts = AppEnvironment.allowBadCertificates;
    final adapter = _dio.httpClientAdapter;

    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        final client = HttpClient();
        client.idleTimeout = Duration.zero;
        if (allowBadCerts) {
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
        }
        return client;
      };
    }
  }

  /// تسجيل المعترضات (Interceptors)
  void _configureInterceptors() {
    _dio.interceptors.addAll([
      _RetryInterceptor(_dio),
      _InfinityFreeChallengeInterceptor(_dio),
      _SessionAuthInterceptor(),
      _CryptoInterceptor(),
    ]);
  }

  // ==========================================================================
  // دوال الـ HTTP الأساسية العامة (Generic HTTP Methods)
  // ==========================================================================

  /// طلب GET عام لعنصر واحد أو كائن استجابة
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _processResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e, endpoint);
    } catch (e) {
      return _handleUnexpectedError<T>(e, endpoint);
    }
  }

  /// طلب GET مخصص للقوائم المصفحة (Cursor أو Pagination)
  Future<ApiResponse<List<T>>> getList<T>(
    String endpoint, {
    required T Function(dynamic json) fromJson,
    Map<String, dynamic>? queryParameters,
    String? cursor,
    int? perPage,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final params = <String, dynamic>{
        ...?queryParameters,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        if (perPage != null) 'per_page': perPage,
      };

      final response = await _dio.get(
        endpoint,
        queryParameters: params.isEmpty ? null : params,
        options: options,
        cancelToken: cancelToken,
      );

      final rawData = response.data;
      final Map<String, dynamic> jsonData = rawData is List
          ? {'data': rawData, 'success': true}
          : (rawData is Map<String, dynamic>
                ? rawData
                : (rawData is Map
                      ? Map<String, dynamic>.from(rawData)
                      : throw FormatException('تنسيق رد غير متوقع: $rawData')));

      return ApiResponse<List<T>>.fromJson(jsonData, (data) {
        if (data is List) {
          return data.map((item) => fromJson(item)).toList();
        }
        if (data is Map) {
          final list = data['data'] ?? data['items'] ?? data['records'];
          if (list is List) {
            return list.map((item) => fromJson(item)).toList();
          }
        }
        return <T>[];
      });
    } on DioException catch (e) {
      return _handleDioError<List<T>>(e, endpoint);
    } catch (e) {
      return _handleUnexpectedError<List<T>>(e, endpoint);
    }
  }

  /// طلب POST عام مع دعم مفتاح عدم التكرار (Idempotency Key)
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
    String? idempotencyKey,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final effectiveOptions = (options ?? Options()).copyWith(
        extra: {
          ...?options?.extra,
          if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
        },
      );

      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: effectiveOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return _processResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e, endpoint);
    } catch (e) {
      return _handleUnexpectedError<T>(e, endpoint);
    }
  }

  /// طلب PUT عام للتعديل الشامل مع دعم مفتاح عدم التكرار (Idempotency Key)
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
    String? idempotencyKey,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final effectiveOptions = (options ?? Options()).copyWith(
        extra: {
          ...?options?.extra,
          if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
        },
      );

      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: effectiveOptions,
        cancelToken: cancelToken,
      );
      return _processResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e, endpoint);
    } catch (e) {
      return _handleUnexpectedError<T>(e, endpoint);
    }
  }

  /// طلب PATCH عام للتعديل الجزئي مع دعم مفتاح عدم التكرار (Idempotency Key)
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
    String? idempotencyKey,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final effectiveOptions = (options ?? Options()).copyWith(
        extra: {
          ...?options?.extra,
          if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
        },
      );

      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: effectiveOptions,
        cancelToken: cancelToken,
      );
      return _processResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e, endpoint);
    } catch (e) {
      return _handleUnexpectedError<T>(e, endpoint);
    }
  }

  /// طلب DELETE عام مع دعم مفتاح عدم التكرار (Idempotency Key)
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
    String? idempotencyKey,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final effectiveOptions = (options ?? Options()).copyWith(
        extra: {
          ...?options?.extra,
          if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
        },
      );

      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: effectiveOptions,
        cancelToken: cancelToken,
      );
      return _processResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e, endpoint);
    } catch (e) {
      return _handleUnexpectedError<T>(e, endpoint);
    }
  }

  /// رفع ملف منفرد بصيغة MultipartFormData مع دعم مفتاح عدم التكرار
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint, {
    required String filePath,
    required String fileField,
    Map<String, dynamic>? extraFields,
    T Function(dynamic json)? fromJson,
    String? idempotencyKey,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        return ApiResponse<T>(
          success: false,
          message: 'الملف المحدد غير موجود على الجهاز',
        );
      }

      final fileName = file.uri.pathSegments.last;
      final multipartFile = await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      );

      final formData = FormData.fromMap({
        fileField: multipartFile,
        ...?extraFields,
      });

      final effectiveOptions = Options(
        extra: {
          if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
        },
      );

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: effectiveOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return _processResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e, endpoint);
    } catch (e) {
      return _handleUnexpectedError<T>(e, endpoint);
    }
  }

  /// تحميل ملف وحفظه في مسار محلي
  Future<ApiResponse<String>> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );

      return ApiResponse<String>(
        success: true,
        message: 'تم تحميل الملف بنجاح',
        data: savePath,
      );
    } on DioException catch (e) {
      return _handleDioError<String>(e, url);
    } catch (e) {
      return _handleUnexpectedError<String>(e, url);
    }
  }

  /// تحميل ملف كمصفوفة بايتات مباشرة (للصور والأصوات والـ PDF)
  Future<Uint8List?> downloadBytes(
    String url, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );

      final data = response.data;
      if (data == null) return null;
      if (data is Uint8List) return data;
      return Uint8List.fromList(data);
    } catch (e) {
      if (AppEnvironment.enableLogging) {
        log('❌ downloadBytes failed [$url]: $e');
      }
      return null;
    }
  }

  /// تنفيذ مجموعة من الطلبات بالتوازي (Parallel Batch)
  Future<List<ApiResponse<T>>> batch<T>(
    List<Future<ApiResponse<T>>> requests, {
    bool stopOnError = false,
  }) async {
    if (stopOnError) {
      final results = <ApiResponse<T>>[];
      for (final req in requests) {
        final res = await req;
        results.add(res);
        if (!res.success) break;
      }
      return results;
    }
    return await Future.wait(requests);
  }

  // ==========================================================================
  // معالجة الردود والأخطاء (Response & Error Parsers)
  // ==========================================================================

  ApiResponse<T> _processResponse<T>(
    Response<dynamic> response,
    T Function(dynamic json)? fromJson,
  ) {
    final body = response.data;
    final isIdempotentHit =
        response.headers.value('X-Idempotency-Hit')?.toLowerCase() == 'true';
    final idempotencyKey = response.headers.value('X-Idempotency-Key') ??
        response.requestOptions.headers['X-Idempotency-Key']?.toString();

    if (body is Map<String, dynamic>) {
      if (fromJson != null) {
        return ApiResponse<T>.fromJson(
          body,
          fromJson,
          isIdempotentHit: isIdempotentHit,
          idempotencyKey: idempotencyKey,
        );
      }
      return ApiResponse<T>.fromSimpleJson(
        body,
        isIdempotentHit: isIdempotentHit,
        idempotencyKey: idempotencyKey,
      );
    }

    if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      if (fromJson != null) {
        return ApiResponse<T>.fromJson(
          map,
          fromJson,
          isIdempotentHit: isIdempotentHit,
          idempotencyKey: idempotencyKey,
        );
      }
      return ApiResponse<T>.fromSimpleJson(
        map,
        isIdempotentHit: isIdempotentHit,
        idempotencyKey: idempotencyKey,
      );
    }

    final isSuccess = response.statusCode == 200 || response.statusCode == 201;
    return ApiResponse<T>(
      success: isSuccess,
      message: isSuccess ? 'تمت العملية بنجاح' : 'حدث خطأ في الاستجابة',
      data: isSuccess && fromJson != null && body != null ? fromJson(body) : null,
      isIdempotentHit: isIdempotentHit,
      idempotencyKey: idempotencyKey,
    );
  }

  ApiResponse<T> _handleDioError<T>(DioException e, String endpoint) {
    if (AppEnvironment.enableLogging) {
      log('❌ Dio Error [$endpoint]: ${e.message} | Status: ${e.response?.statusCode}');
      if (e.response?.data != null) {
        log('Response data: ${e.response?.data}');
      }
    }

    // 1. فحص انقطاع أو ضعف الاتصال بالإنترنت
    if (ConnectionFailureDetector.isConnectionFailure(e)) {
      return ApiResponse<T>(
        success: false,
        message: 'لا يتوفر اتصال بالإنترنت، يرجى التحقق من اتصالك والمحاولة مجدداً',
      );
    }

    // 2. فحص انتهاء وقت الاتصال (Timeouts)
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiResponse<T>(
        success: false,
        message: 'انتهت مهلة الاتصال بالخادم، يرجى المحاولة مرة أخرى',
      );
    }

    // 3. معالجة رد الخادم إن وجد
    final response = e.response;
    if (response != null) {
      final statusCode = response.statusCode;
      final body = response.data;

      String? serverMessage;
      List<dynamic>? errors;

      if (body is Map) {
        serverMessage = body['message']?.toString();
        final rawErrors = body['errors'];
        if (rawErrors is List) {
          errors = rawErrors;
        } else if (rawErrors is Map) {
          errors = rawErrors.values.expand((v) => v is List ? v : [v]).toList();
        }
      }

      final message = _extractUserFriendlyMessage(
        statusCode: statusCode,
        serverMessage: serverMessage,
        errors: errors,
      );

      return ApiResponse<T>(
        success: false,
        message: AppException.sanitizeMessage(message),
        errors: errors,
      );
    }

    return ApiResponse<T>(
      success: false,
      message: 'تعذر الاتصال بالخادم، يرجى التحقق من الشبكة',
    );
  }

  ApiResponse<T> _handleUnexpectedError<T>(dynamic error, String endpoint) {
    if (AppEnvironment.enableLogging) {
      log('❌ Unexpected Error [$endpoint]: $error');
    }
    return ApiResponse<T>(
      success: false,
      message: AppException.sanitizeMessage(
        error,
        fallback: 'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً',
      ),
    );
  }

  String _extractUserFriendlyMessage({
    int? statusCode,
    String? serverMessage,
    List<dynamic>? errors,
  }) {
    if (errors != null && errors.isNotEmpty) {
      final firstError = errors.first.toString().trim();
      if (firstError.isNotEmpty) return firstError;
    }

    if (serverMessage != null && serverMessage.trim().isNotEmpty) {
      return serverMessage.trim();
    }

    return switch (statusCode) {
      400 => 'طلب غير صالح، يرجى التأكد من البيانات',
      401 => 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً',
      403 => 'ليس لديك الصلاحية لتنفيذ هذا الإجراء',
      404 => 'العنصر أو المسار المطلوب غير موجود',
      409 => 'العملية مكررة أو قيد المعالجة بالفعل',
      422 => 'بيانات الإدخال غير صحيحة، يرجى مراجعة الحقول',
      429 => 'تم تجاوز حد الطلبات المسموح، يرجى الانتظار قليلاً',
      500 => 'حدث خطأ داخلي في الخادم، يرجى المحاولة لاحقاً',
      502 || 503 || 504 => 'الخدمة غير متاحة حالياً، يرجى المحاولة لاحقاً',
      _ => 'تعذر إتمام العملية بنجاح',
    };
  }

  /// تحويل المسار النسبي للملفات إلى رابط كامل صالح للاستعراض
  static String resolveStorageUrl(String rawPath) {
    final trimmed = rawPath.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final cleanPath = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    return '${ApiConstants.baseUrl}/$cleanPath';
  }
}

// ============================================================================
// المعترضات الداخلية المتخصصة (Specialized Internal Interceptors)
// ============================================================================

/// معترض المصادقة وحقن الترويسات الرسمية (X-Session-Id, X-Device-Uuid)
class _SessionAuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final storage = StorageService.instance;

    // حقن معرف الجلسة
    final sessionId = storage.sessionId;
    if (sessionId != null && sessionId.isNotEmpty) {
      options.headers['X-Session-Id'] = sessionId;
    }

    // حقن معرف الجهاز الدائم مباشرة من الذاكرة
    final deviceUuid = DeviceService.instance.deviceUuid;
    if (deviceUuid.isNotEmpty) {
      options.headers['X-Device-Uuid'] = deviceUuid;
    }

    // حقن مفتاح عدم التكرار إن وُجد
    final idempotencyKey = options.extra['idempotency_key'];
    if (idempotencyKey != null) {
      options.headers['X-Idempotency-Key'] = idempotencyKey.toString();
    }

    // تجاوز التشفير أثناء بيئة التطوير والاختبار
    if (!AppEnvironment.isProd) {
      options.headers['X-Bypass-Encryption'] = 'true';
    }

    if (AppEnvironment.enableLogging) {
      log('🌐 [HTTP Request] ${options.method} ${options.uri}');
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;

    // التعامل مع انتهاء صلاحية الجلسة
    if (statusCode == 401) {
      final path = err.requestOptions.path;
      final isPublicAuth = path.contains('/auth/login') ||
          path.contains('/auth/register') ||
          path.contains('/auth/password');

      if (!isPublicAuth) {
        await StorageService.instance.clearSession();
        ApiService.onUnauthorized?.call();
      }
    }

    return handler.next(err);
  }
}

/// معترض حل تحدي الاستضافة المجانية InfinityFree تلقائياً
class _InfinityFreeChallengeInterceptor extends Interceptor {
  final Dio _dio;
  static const _retryFlagKey = '__test_retried';
  static final Map<String, String> _cachedCookies = {};
  static final Map<String, DateTime> _cookieExpiry = {};

  _InfinityFreeChallengeInterceptor(this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final host = Uri.tryParse(options.uri.toString())?.host;
    if (host != null && _cachedCookies.containsKey(host)) {
      final expiry = _cookieExpiry[host];
      if (expiry == null || DateTime.now().isBefore(expiry)) {
        options.headers['Cookie'] = '__test=${_cachedCookies[host]}';
      } else {
        _cachedCookies.remove(host);
        _cookieExpiry.remove(host);
      }
    }
    options.headers['User-Agent'] = InfinityFreeChallengeSolver.browserUserAgent;
    return handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final body = response.data;

    final isChallenge =
        (body is String && InfinityFreeChallengeSolver.isChallengeBody(body)) ||
        (body is Uint8List &&
            InfinityFreeChallengeSolver.computeFromBytes(body) != null);

    if (!isChallenge) return handler.next(response);

    if (response.requestOptions.extra[_retryFlagKey] == true) {
      return handler.next(response);
    }

    final String? cookie;
    if (body is String) {
      cookie = InfinityFreeChallengeSolver.solveChallenge(body);
    } else if (body is Uint8List) {
      cookie = InfinityFreeChallengeSolver.computeFromBytes(body);
    } else {
      cookie = null;
    }

    if (cookie == null) return handler.next(response);

    final host =
        Uri.tryParse(response.requestOptions.uri.toString())?.host ?? '';
    _cachedCookies[host] = cookie;
    _cookieExpiry[host] = DateTime.now().add(const Duration(hours: 5));

    final options = response.requestOptions;
    options.headers['Cookie'] = '__test=$cookie';
    options.headers['User-Agent'] = InfinityFreeChallengeSolver.browserUserAgent;
    options.extra[_retryFlagKey] = true;

    try {
      final retried = await _dio.fetch(options);
      return handler.resolve(retried);
    } catch (e) {
      if (AppEnvironment.enableLogging) {
        log('❌ إعادة المحاولة بعد تحدي InfinityFree فشلت: $e');
      }
      return handler.next(response);
    }
  }
}

/// معترض إعادة المحاولة التلقائية (Retry with Exponential Backoff) لطلبات GET الآمنة
class _RetryInterceptor extends Interceptor {
  final Dio _dio;
  static const int _maxRetries = 2;

  _RetryInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final retryCount = (requestOptions.extra['retry_count'] as int?) ?? 0;

    final statusCode = err.response?.statusCode;
    final isTransientStatus =
        statusCode != null &&
        (statusCode == 502 || statusCode == 503 || statusCode == 504);

    final isTimeout =
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout;

    final isGetRequest = requestOptions.method.toUpperCase() == 'GET';
    final hasIdempotencyKey =
        requestOptions.headers['X-Idempotency-Key'] != null ||
        requestOptions.extra['idempotency_key'] != null;

    final isSafeToRetry = isGetRequest || hasIdempotencyKey;

    if ((isTransientStatus || isTimeout) &&
        isSafeToRetry &&
        retryCount < _maxRetries) {
      final nextRetry = retryCount + 1;
      final delayMs = 1000 * (1 << retryCount);

      if (AppEnvironment.enableLogging) {
        log(
          '🔄 [RetryInterceptor] Retrying ${requestOptions.path} in ${delayMs}ms (attempt $nextRetry of $_maxRetries)...',
        );
      }
      await Future.delayed(Duration(milliseconds: delayMs));

      requestOptions.extra['retry_count'] = nextRetry;
      try {
        final response = await _dio.fetch(requestOptions);
        return handler.resolve(response);
      } on DioException catch (retryErr) {
        return handler.next(retryErr);
      } catch (_) {
        return handler.next(err);
      }
    }

    return handler.next(err);
  }
}

/// ============================================================================
/// معترض التشفير اللامتناظر وحماية البيانات (Asymmetric Crypto Interceptor)
/// ============================================================================
/// يتولى وفق أعلى المعايير السيبرانية:
/// 1. تشفير حمولة الطلبات (POST, PUT, PATCH) بمفتاح الخادم العام عبر `crypto_box_seal`.
/// 2. توليد زوج مفاتيح مؤقت لكل طلب في الـ RAM وحقن المفتاح العام في [X-Client-Public-Key].
/// 3. فك تشفير استجابات الخادم الآمنة (NTS_ENC_...) بالمفتاح المؤقت للطلب.
/// 4. مسح وتحرير المفتاح المؤقت من الذاكرة فور انتهاء دورة الطلب في finally.
class _CryptoInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final crypto = AppCryptoService.instance;

    // استثناء المسارات العامة أو الطلبات المستثناة صراحة
    final isBypassed = options.headers['X-Bypass-Encryption'] == 'true' ||
        options.extra['bypass_encryption'] == true ||
        _isBypassEndpoint(options.path);

    if (isBypassed || !crypto.isEncryptionActive) {
      return handler.next(options);
    }

    try {
      final method = options.method.toUpperCase();

      // 1. طلبات التعديل والإرسال التي تحتوي حمولة (POST, PUT, PATCH) وليست FormData
      if (['POST', 'PUT', 'PATCH'].contains(method) &&
          options.data != null &&
          options.data is! FormData) {
        final sealed = crypto.sealRequestPayload(options.data);
        options.data = sealed.body;
        options.headers['X-Client-Public-Key'] = sealed.clientPublicKeyHex;
        options.extra['_crypto_keypair'] = sealed.ephemeralKeyPair;
      } else {
        // 2. طلبات القراءة أو الحذف التي تتطلب استجابة مشفرة من الخادم
        final ephemeral = crypto.generateEphemeralKeyPair();
        final clientPublicKeyHex =
            AppCryptoService.bytesToHex(ephemeral.publicKey);
        options.headers['X-Client-Public-Key'] = clientPublicKeyHex;
        options.extra['_crypto_keypair'] = ephemeral;
      }
    } catch (e, stack) {
      log('⚠️ [CryptoInterceptor] Encryption failed for ${options.uri}: $e\n$stack');
    }

    return handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final keyPair =
        response.requestOptions.extra['_crypto_keypair'] as KeyPair?;

    if (keyPair != null) {
      try {
        final body = response.data;
        if (body is Map) {
          final rawData = body['data'];
          if (rawData is String &&
              rawData.startsWith(AppCryptoService.encResponsePrefix)) {
            final unsealed = AppCryptoService.instance.unsealResponseData(
              rawResponseData: rawData,
              ephemeralKeyPair: keyPair,
            );
            body['data'] = unsealed;
          }
        }
      } catch (e, stack) {
        log('❌ [CryptoInterceptor] Decryption failed for ${response.requestOptions.uri}: $e\n$stack');
      } finally {
        // تحرير الذاكرة الآمنة ومسح المفتاح المؤقت للطلب فوراً
        keyPair.dispose();
      }
    }

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final keyPair =
        err.requestOptions.extra['_crypto_keypair'] as KeyPair?;
    try {
      keyPair?.dispose();
    } catch (_) {}

    return handler.next(err);
  }

  /// فحص مسارات النظام العامة المستثناة من التشفير
  bool _isBypassEndpoint(String path) {
    return path.contains(ApiConstants.securityPublicKeys) ||
        path.contains('/auth/health-check') ||
        path.contains('/up') ||
        path.contains('/files/');
  }
}
