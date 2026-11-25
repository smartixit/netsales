import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:netsales/core/config/app_environment.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/api_request_replay_state.dart';
import 'package:netsales/core/services/infinityfree_challenge_solver.dart';
import 'package:sodium/sodium.dart' show KeyPair;

const String infinityFreeVerificationProbeFlagKey =
    '__netsales_infinityfree_verification_probe';
const String infinityFreeChallengeFailureFlagKey =
    '__netsales_infinityfree_challenge_failure';
const String infinityFreeSessionAuthHandledFlagKey =
    '__netsales_infinityfree_session_auth_already_handled';

/// Handles the InfinityFree JavaScript test-cookie challenge.
///
/// The browser executes the challenge's location.href as a GET navigation.
/// We therefore verify the cookie with a standalone GET before replaying the
/// original request with its original method, URI, and body.
class InfinityFreeChallengeInterceptor extends Interceptor {
  final Dio _dio;
  static const _retryFlagKey = '__test_retried';
  static final Map<String, String> _cachedCookies = {};
  static final Map<String, DateTime> _cookieExpiry = {};

  InfinityFreeChallengeInterceptor(this._dio);

  static String? _headerValue(Map<String, dynamic> headers, String name) {
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == name.toLowerCase()) {
        return entry.value?.toString();
      }
    }
    return null;
  }

  static void _setHeader(
    Map<String, dynamic> headers,
    String name,
    String value,
  ) {
    final matchingKeys = headers.keys
        .where((key) => key.toLowerCase() == name.toLowerCase())
        .toList();
    for (final key in matchingKeys) {
      headers.remove(key);
    }
    headers[name] = value;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final host = options.uri.host;
    final isVerificationProbe =
        options.extra[infinityFreeVerificationProbeFlagKey] == true;
    if (!isVerificationProbe &&
        host.isNotEmpty &&
        _cachedCookies.containsKey(host)) {
      final expiry = _cookieExpiry[host];
      if (expiry != null && DateTime.now().isBefore(expiry)) {
        final existingCookie = _headerValue(options.headers, 'Cookie');
        _setHeader(
          options.headers,
          'Cookie',
          InfinityFreeChallengeSolver.mergeChallengeCookie(
            existingCookieHeader: existingCookie,
            challengeCookie: _cachedCookies[host]!,
          ),
        );
      } else {
        _cachedCookies.remove(host);
        _cookieExpiry.remove(host);
      }
    }

    _setHeader(
      options.headers,
      'User-Agent',
      InfinityFreeChallengeSolver.browserUserAgent,
    );
    handler.next(options);
  }

  void _clearCachedCookie(String host) {
    _cachedCookies.remove(host);
    _cookieExpiry.remove(host);
  }

  void _finishCryptoLifecycle(RequestOptions options) {
    if (!ApiRequestReplayState.tryFinishCryptoLifecycle(options)) {
      return;
    }

    final keyPair = options.extra['_crypto_keypair'] as KeyPair?;
    try {
      keyPair?.dispose();
    } catch (_) {}
  }

  DioException _challengeFailure({
    required RequestOptions options,
    Response<dynamic>? response,
    required String message,
    Object? cause,
  }) {
    options.extra[infinityFreeChallengeFailureFlagKey] = true;
    return DioException(
      requestOptions: options,
      response: response,
      type: DioExceptionType.badResponse,
      error: AppException(message),
      message: cause?.toString(),
    );
  }

  Map<String, dynamic>? _responseBodyAsJson(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is! String) {
      return null;
    }

    try {
      final decoded = jsonDecode(data);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } on FormatException {
      return null;
    }
  }

  bool _isBackendApiResponse(Response<dynamic> response) {
    final contentType = response.headers.value(Headers.contentTypeHeader);
    if (contentType == null ||
        !contentType.toLowerCase().contains('application/json')) {
      return false;
    }

    final body = _responseBodyAsJson(response.data);
    return body != null &&
        body['success'] is bool &&
        body['message'] is String &&
        body.containsKey('data') &&
        body.containsKey('errors');
  }

  Response<dynamic> _responseForOriginalRequest(
    Response<dynamic> response,
    RequestOptions original,
  ) {
    return Response<dynamic>(
      requestOptions: original,
      data: response.data,
      headers: response.headers,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      isRedirect: response.isRedirect,
      redirects: response.redirects,
      extra: response.extra,
    );
  }

  RequestOptions _createVerificationOptions({
    required RequestOptions original,
    required Uri redirectUri,
    required String challengeCookie,
  }) {
    final existingCookie = _headerValue(original.headers, 'Cookie');
    final headers = <String, dynamic>{
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'Cookie': InfinityFreeChallengeSolver.mergeChallengeCookie(
        existingCookieHeader: existingCookie,
        challengeCookie: challengeCookie,
      ),
      'User-Agent': InfinityFreeChallengeSolver.browserUserAgent,
    };

    // The probe stays on the exact same origin and path (validated by the
    // challenge solver). Forward only the two credentials required by
    // SessionAuthMiddleware; never copy the original payload or other headers.
    for (final name in const ['X-Session-Id', 'X-Device-Uuid']) {
      final value = _headerValue(original.headers, name);
      if (value != null && value.isNotEmpty) {
        headers[name] = value;
      }
    }

    final verificationOptions = original.copyWith(
      method: 'GET',
      queryParameters: <String, dynamic>{...redirectUri.queryParameters},
      headers: headers,
      extra: <String, dynamic>{
        _retryFlagKey: true,
        infinityFreeVerificationProbeFlagKey: true,
        'bypass_encryption': true,
      },
      responseType: ResponseType.plain,
      validateStatus: (status) => status != null,
      receiveDataWhenStatusError: true,
      followRedirects: false,
    );

    // RequestOptions.copyWith treats data:null as "keep the old data".
    // Clear it explicitly so a POST login body can never reach the probe GET.
    verificationOptions.data = null;
    verificationOptions.contentType = null;
    return verificationOptions;
  }

  Future<Response<dynamic>> _processChallengeResponse(
    Response<dynamic> response,
  ) async {
    final options = response.requestOptions;
    final challengeHtml = InfinityFreeChallengeSolver.challengeHtml(
      response.data,
    );

    if (challengeHtml == null) return response;

    // A challenge on a verification probe or a replay means that the
    // handshake did not complete. Never start an unbounded second handshake.
    if (options.extra[_retryFlagKey] == true) {
      _clearCachedCookie(options.uri.host);
      _finishCryptoLifecycle(options);
      throw _challengeFailure(
        options: options,
        response: response,
        message: 'رفضت الاستضافة طلب التحقق؛ ما زالت صفحة JavaScript تصل إلى التطبيق.',
      );
    }

    final requestUri = options.uri;
    final cookie = InfinityFreeChallengeSolver.solveChallenge(challengeHtml);
    final redirectUri = InfinityFreeChallengeSolver.extractChallengeRedirectUri(
      challengeHtml,
      requestUri: requestUri,
    );

    if (cookie == null || redirectUri == null) {
      _finishCryptoLifecycle(options);
      if (AppEnvironment.enableLogging) {
        log(
          'تعذر إكمال تحدي InfinityFree: challenge cookie أو '
          'same-endpoint redirect غير صالح.',
        );
      }
      throw _challengeFailure(
        options: options,
        response: response,
        message: 'تعذر استخراج بيانات خطوة تحقق الاستضافة.',
      );
    }

    // FormData and streaming bodies are one-shot and cannot be replayed safely.
    if (options.data is FormData || options.data is Stream) {
      _finishCryptoLifecycle(options);
      throw _challengeFailure(
        options: options,
        response: response,
        message: 'طلب يحتوي على ملفات أو تدفق بيانات لا يمكن إعادة إرساله بأمان بعد تحقق الاستضافة.',
      );
    }

    if (requestUri.host.isEmpty) {
      _finishCryptoLifecycle(options);
      throw _challengeFailure(
        options: options,
        response: response,
        message: 'تعذر تحديد نطاق الاستضافة لحفظ كوكي التحقق.',
      );
    }

    final verificationOptions = _createVerificationOptions(
      original: options,
      redirectUri: redirectUri,
      challengeCookie: cookie,
    );

    // Verify the browser-equivalent location.href navigation before replaying
    // the original method and body. validateStatus on the probe accepts 401,
    // 403, 404, and 405 so a real Laravel response is distinguishable from
    // another hosting challenge.
    Response<dynamic>? verificationResponse;
    try {
      final probeResponse = await _dio.fetch<dynamic>(verificationOptions);
      verificationResponse = probeResponse;

      if (InfinityFreeChallengeSolver.isChallengeResponse(probeResponse.data)) {
        throw _challengeFailure(
          options: verificationOptions,
          response: probeResponse,
          message: 'رفضت الاستضافة كوكي التحقق؛ أعادت صفحة التحدي إلى طلب GET الخاص بالتحقق.',
        );
      }

      final verificationStatus = probeResponse.statusCode;
      final acceptedVerificationStatus =
          (verificationStatus != null &&
              ((verificationStatus >= 200 && verificationStatus < 300) ||
                  verificationStatus == 404 ||
                  verificationStatus == 405)) ||
          _isBackendApiResponse(probeResponse);

      if (!acceptedVerificationStatus) {
        throw _challengeFailure(
          options: verificationOptions,
          response: verificationResponse,
          message:
              'لم يثبت طلب GET اجتياز تحقق الاستضافة '
              '(HTTP ${verificationStatus ?? 'unknown'}).',
        );
      }
    } catch (error) {
      final dioError = error is DioException ? error : null;
      final failedOptions = dioError?.requestOptions ?? verificationOptions;
      final failedResponse = dioError?.response ?? verificationResponse;
      _finishCryptoLifecycle(options);

      if (AppEnvironment.enableLogging) {
        log(
          'فشل GET التحقق من InfinityFree: '
          'HTTP ${failedResponse?.statusCode ?? 'unknown'}, '
          'type=${dioError?.type.name ?? error.runtimeType}.',
        );
      }

      throw _challengeFailure(
        options: failedOptions,
        response: failedResponse,
        message:
            'فشل طلب GET المستقل للتحقق من كوكي الاستضافة؛ '
            'لم يُعَد إرسال الطلب الأصلي.',
        cause:
            dioError?.error ??
            dioError?.message ??
            error.runtimeType.toString(),
      );
    }

    // Cache only after the verification navigation has been accepted.
    _cachedCookies[requestUri.host] = cookie;
    _cookieExpiry[requestUri.host] = DateTime.now().add(
      const Duration(hours: 6),
    );

    // Replay the original request unchanged apart from the verified cookie,
    // User-Agent, and one-shot recursion guard.
    final replayOptions = options.copyWith(
      queryParameters: <String, dynamic>{...options.queryParameters},
      extra: <String, dynamic>{...options.extra, _retryFlagKey: true},
    );

    final existingCookie = _headerValue(replayOptions.headers, 'Cookie');
    _setHeader(
      replayOptions.headers,
      'Cookie',
      InfinityFreeChallengeSolver.mergeChallengeCookie(
        existingCookieHeader: existingCookie,
        challengeCookie: cookie,
      ),
    );
    _setHeader(
      replayOptions.headers,
      'User-Agent',
      InfinityFreeChallengeSolver.browserUserAgent,
    );

    // Keep the original sealed payload and ephemeral response key alive until
    // the replay has passed through the normal crypto response lifecycle.
    ApiRequestReplayState.markCryptoPrepared(replayOptions);

    try {
      return await _dio.fetch<dynamic>(replayOptions);
    } catch (error) {
      final dioError = error is DioException ? error : null;
      final failedOptions = dioError?.requestOptions ?? replayOptions;
      final failedResponse = dioError?.response ?? response;
      _finishCryptoLifecycle(replayOptions);

      // A structured Laravel API response is a real application result (for
      // example, an expired session), not an InfinityFree challenge failure.
      if (dioError?.response != null &&
          _isBackendApiResponse(dioError!.response!)) {
        // The replay traversed the production session interceptor already.
        // Prevent the outer challenge request from invoking the same logout
        // callback a second time when this canonical Laravel error is bubbled up.
        options.extra[infinityFreeSessionAuthHandledFlagKey] = true;
        throw DioException(
          requestOptions: options,
          response: _responseForOriginalRequest(dioError.response!, options),
          type: DioExceptionType.badResponse,
          message: dioError.message,
        );
      }

      if (AppEnvironment.enableLogging) {
        log(
          'فشلت إعادة الطلب الأصلي بعد تحقق InfinityFree: '
          'HTTP ${failedResponse.statusCode ?? 'unknown'}, '
          'type=${dioError?.type.name ?? error.runtimeType}.',
        );
      }

      throw _challengeFailure(
        options: failedOptions,
        response: failedResponse,
        message: 'تعذرت إعادة الطلب الأصلي بعد اجتياز تحقق الاستضافة.',
        cause:
            dioError?.error ??
            dioError?.message ??
            error.runtimeType.toString(),
      );
    }
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    if (!InfinityFreeChallengeSolver.isChallengeResponse(response.data)) {
      handler.next(response);
      return;
    }

    try {
      final replayedResponse = await _processChallengeResponse(response);
      handler.resolve(replayedResponse);
    } on DioException catch (error) {
      handler.reject(error);
    } catch (error) {
      _finishCryptoLifecycle(response.requestOptions);
      handler.reject(
        _challengeFailure(
          options: response.requestOptions,
          response: response,
          message: 'تعذر إكمال تحقق الاستضافة.',
          cause: error,
        ),
      );
    }
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) async {
    final response = error.response;
    if (response == null ||
        !InfinityFreeChallengeSolver.isChallengeResponse(response.data)) {
      handler.next(error);
      return;
    }

    // InfinityFree can serve the same JavaScript challenge with an HTTP error
    // status (commonly 401/403). It must be solved before SessionAuthInterceptor
    // interprets that status as an expired application session.
    try {
      final replayedResponse = await _processChallengeResponse(response);
      handler.resolve(replayedResponse);
    } on DioException catch (challengeError) {
      handler.reject(challengeError);
    } catch (challengeError) {
      _finishCryptoLifecycle(error.requestOptions);
      handler.reject(
        _challengeFailure(
          options: error.requestOptions,
          response: response,
          message: 'تعذر إكمال تحقق الاستضافة.',
          cause: challengeError,
        ),
      );
    }
  }
}
