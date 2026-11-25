import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:netsales/core/services/api_request_replay_state.dart';
import 'package:netsales/core/services/infinityfree_challenge_interceptor.dart';
import 'package:netsales/core/services/infinityfree_challenge_solver.dart';

void main() {
  group('InfinityFreeChallengeInterceptor', () {
    test(
      'POST challenge verifies with GET then replays original POST unchanged',
      () async {
        final baseUri = Uri.parse('https://post-success.example');
        final loginUri = baseUri.resolve('/api/v1/auth/login');
        final challenge = _challenge(loginUri);
        const originalBody = '{"payload":"sealed-login-payload"}';
        var postCount = 0;
        final adapter = _ScriptedAdapter((request, body) async {
          if (request.method == 'POST') {
            postCount++;
            return postCount == 1 ? _html(challenge) : _text('login-ok', 200);
          }

          if (request.method == 'GET' &&
              request.uri.queryParameters['i'] == '1') {
            return _text('Method Not Allowed', 405);
          }
          return _text('unexpected request', 400);
        });
        final dio = _dio(baseUri, adapter);

        final response = await dio.post<String>(
          '/api/v1/auth/login',
          data: originalBody,
          options: Options(
            contentType: Headers.jsonContentType,
            responseType: ResponseType.plain,
            headers: {'Cookie': 'laravel_session=session-1; __test=stale'},
          ),
        );

        expect(response.statusCode, 200);
        expect(response.data, 'login-ok');

        // Initial POST -> browser-equivalent verification GET -> original POST.
        expect(adapter.requests, hasLength(3));
        final initial = adapter.requests[0];
        final probe = adapter.requests[1];
        final replay = adapter.requests[2];

        expect(initial.method, 'POST');
        expect(initial.uri, loginUri);
        expect(initial.body, isNotNull);
        expect(String.fromCharCodes(initial.body!), originalBody);

        expect(probe.method, 'GET');
        expect(probe.uri, loginUri.replace(queryParameters: {'i': '1'}));
        expect(probe.body, isNull);
        expect(probe.header('Content-Type'), isNull);
        expect(probe.header('Cookie'), contains('laravel_session=session-1'));
        expect(
          probe.header('Cookie'),
          contains('__test=e84330a69c6df373fc2fd2a2827a5f0d'),
        );
        expect(
          probe.header('User-Agent'),
          InfinityFreeChallengeSolver.browserUserAgent,
        );

        expect(ApiRequestReplayState.isCryptoPrepared(replay.options), isTrue);
        expect(ApiRequestReplayState.isCryptoPrepared(probe.options), isFalse);
        expect(replay.method, 'POST');
        expect(replay.uri, loginUri);
        expect(String.fromCharCodes(replay.body!), originalBody);
        expect(replay.header('Cookie'), contains('laravel_session=session-1'));
        expect(
          replay.header('Cookie'),
          contains('__test=e84330a69c6df373fc2fd2a2827a5f0d'),
        );
        expect(
          replay.header('User-Agent'),
          InfinityFreeChallengeSolver.browserUserAgent,
        );
        dio.close(force: true);
      },
    );

    test(
      'GET challenge verifies with GET then replays the original GET',
      () async {
        final baseUri = Uri.parse('https://get-success.example');
        final publicKeysUri = baseUri.resolve('/api/v1/security/public-keys');
        var originalGetCount = 0;
        final adapter = _ScriptedAdapter((request, body) async {
          if (request.method == 'GET' &&
              request.uri.path == publicKeysUri.path &&
              request.uri.queryParameters.isEmpty) {
            originalGetCount++;
            return originalGetCount == 1
                ? _html(_challenge(publicKeysUri))
                : _text('{"data":{"keys":[]}}', 200);
          }
          if (request.method == 'GET' &&
              request.uri.queryParameters['i'] == '1') {
            return _text('verification accepted', 200);
          }
          return _text('unexpected request', 400);
        });
        final dio = _dio(baseUri, adapter);

        final response = await dio.get<String>(
          '/api/v1/security/public-keys',
          options: Options(responseType: ResponseType.plain),
        );

        expect(response.statusCode, 200);
        expect(response.data, '{"data":{"keys":[]}}');
        expect(adapter.requests, hasLength(3));
        expect(adapter.requests.map((e) => e.method), ['GET', 'GET', 'GET']);
        expect(adapter.requests[0].uri, publicKeysUri);
        expect(
          adapter.requests[1].uri,
          publicKeysUri.replace(queryParameters: {'i': '1'}),
        );
        expect(adapter.requests[2].uri, publicKeysUri);
        expect(
          adapter.requests[1].header('Cookie'),
          contains('__test=e84330a69c6df373fc2fd2a2827a5f0d'),
        );
        expect(
          adapter.requests[2].header('Cookie'),
          contains('__test=e84330a69c6df373fc2fd2a2827a5f0d'),
        );
        dio.close(force: true);
      },
    );

    test(
      'uses the freshly solved cookie instead of a stale host cache',
      () async {
        final baseUri = Uri.parse('https://cookie-refresh.example');
        final primeUri = baseUri.resolve('/api/v1/prime');
        final updateUri = baseUri.resolve('/api/v1/update');
        final cachedCookie = 'e84330a69c6df373fc2fd2a2827a5f0d';
        const refreshedCookie = '4142434445464748494a4b4c4d4e0d0c';
        var primeOriginalCount = 0;
        var updateOriginalCount = 0;
        final adapter = _ScriptedAdapter((request, body) async {
          if (request.uri.path == primeUri.path &&
              request.uri.queryParameters.isEmpty) {
            primeOriginalCount++;
            return primeOriginalCount == 1
                ? _html(_challenge(primeUri))
                : _text('primed', 200);
          }
          if (request.uri.path == primeUri.path &&
              request.uri.queryParameters['i'] == '1') {
            return _text('prime-verified', 200);
          }
          if (request.uri.path == updateUri.path &&
              request.uri.queryParameters.isEmpty) {
            updateOriginalCount++;
            return updateOriginalCount == 1
                ? _html(
                    _challenge(
                      updateUri,
                      cipherText: '7faa7da20fa612dde3cf9b7f3331b50c',
                    ),
                  )
                : _text('updated', 200);
          }
          if (request.uri.path == updateUri.path &&
              request.uri.queryParameters['i'] == '1') {
            final cookie = request.headers.entries
                .firstWhere((entry) => entry.key.toLowerCase() == 'cookie')
                .value
                .toString();
            expect(cookie, contains('__test=$refreshedCookie'));
            expect(cookie, isNot(contains('__test=$cachedCookie')));
            return _text('update-verified', 200);
          }
          return _text('unexpected request', 400);
        });
        final dio = _dio(baseUri, adapter);

        final primeResponse = await dio.get<String>(
          '/api/v1/prime',
          options: Options(responseType: ResponseType.plain),
        );
        expect(primeResponse.data, 'primed');

        final updateResponse = await dio.get<String>(
          '/api/v1/update',
          options: Options(responseType: ResponseType.plain),
        );
        expect(updateResponse.data, 'updated');
        expect(adapter.requests, hasLength(6));
        expect(adapter.requests[4].header('Cookie'), contains(refreshedCookie));
        dio.close(force: true);
      },
    );

    test('authenticated /auth/me probe preserves only session credentials and replays the original GET', () async {
      final baseUri = Uri.parse('https://authenticated-me.example');
      final meUri = baseUri.resolve('/api/v1/auth/me');
      final challenge = _challenge(meUri);
      var originalGetCount = 0;

      final adapter = _ScriptedAdapter((request, body) async {
        if (request.method == 'GET' &&
            request.uri.path == meUri.path &&
            request.uri.queryParameters.isEmpty) {
          originalGetCount++;
          return originalGetCount == 1
              ? _html(challenge)
              : _text('profile-ok', 200);
        }

        if (request.method == 'GET' &&
            request.uri.path == meUri.path &&
            request.uri.queryParameters['i'] == '1') {
          expect(
            _headerValue(request.headers, 'X-Session-Id'),
            'session-test-value',
          );
          expect(
            _headerValue(request.headers, 'X-Device-Uuid'),
            'device-test-value',
          );
          expect(_headerValue(request.headers, 'X-Client-Public-Key'), isNull);
          expect(_headerValue(request.headers, 'Authorization'), isNull);
          expect(body, isNull);
          return _text('verification accepted', 200);
        }

        return _text('unexpected request', 400);
      });
      final dio = _dio(baseUri, adapter);

      final response = await dio.get<String>(
        '/api/v1/auth/me',
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            'X-Session-Id': 'session-test-value',
            'X-Device-Uuid': 'device-test-value',
            'X-Client-Public-Key': 'must-not-be-forwarded',
            'Authorization': 'must-not-be-forwarded',
          },
        ),
      );

      expect(response.statusCode, 200);
      expect(response.data, 'profile-ok');
      expect(adapter.requests, hasLength(3));
      final probe = adapter.requests[1];
      final replay = adapter.requests[2];
      expect(probe.method, 'GET');
      expect(probe.uri.queryParameters, {'i': '1'});
      expect(probe.header('X-Session-Id'), 'session-test-value');
      expect(probe.header('X-Device-Uuid'), 'device-test-value');
      expect(probe.header('X-Client-Public-Key'), isNull);
      expect(probe.header('Authorization'), isNull);
      expect(replay.method, 'GET');
      expect(replay.uri, meUri);
      expect(replay.header('X-Session-Id'), 'session-test-value');
      expect(replay.header('X-Device-Uuid'), 'device-test-value');
      dio.close(force: true);
    });

    test('returns canonical Laravel 401 from authenticated probe as a real session rejection', () async {
      final baseUri = Uri.parse('https://authenticated-rejection.example');
      final meUri = baseUri.resolve('/api/v1/auth/me');
      var originalGetCount = 0;
      final adapter = _ScriptedAdapter((request, body) async {
        if (request.uri.path == meUri.path &&
            request.uri.queryParameters.isEmpty) {
          originalGetCount++;
          if (originalGetCount == 1) {
            return _html(_challenge(meUri));
          }
          return _json(
            '{"success":false,"message":"الجلسة غير صالحة","data":{},"errors":[]}',
            401,
          );
        }
        if (request.uri.path == meUri.path &&
            request.uri.queryParameters['i'] == '1') {
          return _json(
            '{"success":false,"message":"الجلسة غير صالحة","data":{},"errors":[]}',
            401,
          );
        }
        return _text('unexpected request', 400);
      });
      final dio = _dio(baseUri, adapter);

      DioException? failure;
      try {
        await dio.get<String>(
          '/api/v1/auth/me',
          options: Options(
            responseType: ResponseType.plain,
            headers: {
              'X-Session-Id': 'session-test-value',
              'X-Device-Uuid': 'device-test-value',
            },
          ),
        );
      } on DioException catch (error) {
        failure = error;
      }

      expect(failure, isNotNull);
      expect(failure!.response?.statusCode, 401);
      expect(failure.requestOptions.path, '/api/v1/auth/me');
      expect(
        failure.requestOptions.extra[infinityFreeVerificationProbeFlagKey],
        isNot(true),
      );
      expect(adapter.requests, hasLength(3));
      expect(adapter.requests[1].uri.queryParameters, {'i': '1'});
      expect(adapter.requests[1].header('X-Session-Id'), 'session-test-value');
      expect(adapter.requests[2].uri.queryParameters, isEmpty);
      expect(adapter.requests[2].header('X-Session-Id'), 'session-test-value');
      expect(adapter.requests[2].header('X-Device-Uuid'), 'device-test-value');
      dio.close(force: true);
    });

    test('does not treat an unstructured verification 401 as an authenticated session rejection', () async {
      final baseUri = Uri.parse('https://untrusted-401.example');
      final meUri = baseUri.resolve('/api/v1/auth/me');
      final adapter = _ScriptedAdapter((request, body) async {
        if (request.uri.path == meUri.path) {
          return request.uri.queryParameters.isEmpty
              ? _html(_challenge(meUri))
              : _text('Access denied by hosting gateway', 401);
        }
        return _text('unexpected request', 400);
      });
      final dio = _dio(baseUri, adapter);

      DioException? failure;
      try {
        await dio.get<String>(
          '/api/v1/auth/me',
          options: Options(
            responseType: ResponseType.plain,
            headers: {
              'X-Session-Id': 'session-test-value',
              'X-Device-Uuid': 'device-test-value',
            },
          ),
        );
      } on DioException catch (error) {
        failure = error;
      }

      expect(failure, isNotNull);
      expect(failure!.response?.statusCode, 401);
      expect(
        failure.requestOptions.extra[infinityFreeChallengeFailureFlagKey],
        isTrue,
      );
      expect(adapter.requests, hasLength(2));
      expect(adapter.requests.last.uri.queryParameters, {'i': '1'});
      dio.close(force: true);
    });

    test('solves an HTTP 401 InfinityFree challenge on two-factor verification before session rejection', () async {
      final baseUri = Uri.parse('https://two-factor-challenge.example');
      final verifyUri = baseUri.resolve('/api/v1/auth/2fa/verify');
      final challenge = _challenge(verifyUri);
      var verificationPostCount = 0;

      final adapter = _ScriptedAdapter((request, body) async {
        if (request.uri.path == verifyUri.path && request.method == 'POST') {
          verificationPostCount++;
          if (verificationPostCount == 1) {
            return _html(challenge, 401);
          }
          return _json(
            '{"success":true,"message":"تم التحقق","data":{"session_id":"new-session"},"errors":[]}',
            200,
          );
        }

        if (request.uri.path == verifyUri.path &&
            request.method == 'GET' &&
            request.uri.queryParameters['i'] == '1') {
          expect(body, isNull);
          expect(
            _headerValue(request.headers, 'X-Device-Uuid'),
            'device-after-otp',
          );
          return _text('hosting challenge accepted', 200);
        }

        return _text('unexpected request', 400);
      });

      SharedPreferences.setMockInitialValues({});
      await StorageService.instance.init();
      var unauthorizedCount = 0;
      ApiService.onUnauthorized = () async {
        unauthorizedCount++;
      };
      addTearDown(() => ApiService.onUnauthorized = null);

      final dio = _dio(baseUri, adapter);
      dio.interceptors.add(SessionAuthInterceptor());
      final response = await dio.post<String>(
        '/api/v1/auth/2fa/verify',
        data: '{"otp":"123456"}',
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.plain,
          headers: {'X-Device-Uuid': 'device-after-otp'},
        ),
      );

      expect(response.statusCode, 200);
      expect(response.data, contains('"session_id":"new-session"'));
      expect(unauthorizedCount, 0);
      expect(verificationPostCount, 2);
      expect(adapter.requests, hasLength(3));
      expect(adapter.requests.map((request) => request.method), [
        'POST',
        'GET',
        'POST',
      ]);
      expect(adapter.requests[0].options.responseType, ResponseType.plain);
      expect(adapter.requests[1].uri.queryParameters, {'i': '1'});
      expect(adapter.requests[1].body, isNull);
      expect(adapter.requests[2].body, isNotNull);
      expect(
        String.fromCharCodes(adapter.requests[2].body!),
        '{"otp":"123456"}',
      );
      expect(adapter.requests[2].header('Cookie'), contains('__test='));
      dio.close(force: true);
    });

    test('passes a real Laravel 401 from the two-factor replay to session invalidation', () async {
      SharedPreferences.setMockInitialValues({});
      await StorageService.instance.init();

      var unauthorizedCount = 0;
      ApiService.onUnauthorized = () async {
        unauthorizedCount++;
      };
      addTearDown(() => ApiService.onUnauthorized = null);

      final baseUri = Uri.parse('https://two-factor-real-401.example');
      final verifyUri = baseUri.resolve('/api/v1/auth/2fa/verify');
      final challenge = _challenge(verifyUri);
      var postCount = 0;

      final adapter = _ScriptedAdapter((request, body) async {
        if (request.uri.path == verifyUri.path && request.method == 'POST') {
          postCount++;
          if (postCount == 1) {
            return _html(challenge, 401);
          }
          return _json(
            '{"success":false,"message":"انتهت صلاحية الجلسة","data":null,"errors":[]}',
            401,
          );
        }

        if (request.uri.path == verifyUri.path &&
            request.method == 'GET' &&
            request.uri.queryParameters['i'] == '1') {
          expect(body, isNull);
          return _text('hosting challenge accepted', 200);
        }

        return _text('unexpected request', 400);
      });

      final dio = _dio(baseUri, adapter);
      dio.interceptors.add(SessionAuthInterceptor());

      DioException? failure;
      try {
        await dio.post<String>(
          '/api/v1/auth/2fa/verify',
          data: '{"otp":"123456"}',
          options: Options(
            contentType: Headers.jsonContentType,
            responseType: ResponseType.plain,
          ),
        );
      } on DioException catch (error) {
        failure = error;
      }

      expect(failure, isNotNull);
      expect(failure!.response?.statusCode, 401);
      expect(unauthorizedCount, 1);
      expect(postCount, 2);
      expect(adapter.requests, hasLength(3));
      expect(adapter.requests.map((request) => request.method), [
        'POST',
        'GET',
        'POST',
      ]);
      expect(failure.response?.data, contains('انتهت صلاحية الجلسة'));
      dio.close(force: true);
    });

    test(
      'does not replay or cache cookie when verification GET is challenged',
      () async {
        final baseUri = Uri.parse('https://probe-fails.example');
        final loginUri = baseUri.resolve('/api/v1/auth/login');
        final challenge = _challenge(loginUri);
        var firstTwoRequests = 0;
        final adapter = _ScriptedAdapter((request, body) async {
          if (request.uri.path == '/api/v1/auth/login') {
            firstTwoRequests++;
            return _html(challenge);
          }
          return _text('health-ok', 200);
        });
        final dio = _dio(baseUri, adapter);

        DioException? failure;
        try {
          await dio.post<String>(
            '/api/v1/auth/login',
            data: '{"payload":"must-not-replay"}',
            options: Options(
              contentType: Headers.jsonContentType,
              responseType: ResponseType.plain,
            ),
          );
        } on DioException catch (error) {
          failure = error;
        }

        if (failure == null) {
          fail('Expected the failed verification GET to throw DioException.');
        }
        expect(failure.response?.statusCode, 200);
        expect(failure.response?.data, contains('aes.js'));
        expect(failure.requestOptions.uri.queryParameters, {'i': '1'});

        expect(firstTwoRequests, 2);
        expect(adapter.requests, hasLength(2));
        expect(adapter.requests[0].method, 'POST');
        expect(adapter.requests[1].method, 'GET');
        expect(adapter.requests[1].uri.queryParameters, {'i': '1'});

        await dio.get<String>(
          '/api/v1/health',
          options: Options(responseType: ResponseType.plain),
        );
        expect(adapter.requests, hasLength(3));
        expect(
          adapter.requests[2].header('Cookie') ?? '',
          isNot(contains('__test=')),
        );
        dio.close(force: true);
      },
    );

    test(
      'does not start another handshake when original replay is challenged',
      () async {
        final baseUri = Uri.parse('https://replay-fails.example');
        final loginUri = baseUri.resolve('/api/v1/auth/login');
        final challenge = _challenge(loginUri);
        final adapter = _ScriptedAdapter((request, body) async {
          if (request.method == 'GET' &&
              request.uri.queryParameters['i'] == '1') {
            return _text('verified', 200);
          }
          if (request.uri.path == '/api/v1/auth/login') {
            return _html(challenge);
          }
          return _text('unexpected request', 400);
        });
        final dio = _dio(baseUri, adapter);

        await expectLater(
          dio.post<String>(
            '/api/v1/auth/login',
            data: '{"payload":"sealed"}',
            options: Options(
              contentType: Headers.jsonContentType,
              responseType: ResponseType.plain,
            ),
          ),
          throwsA(isA<DioException>()),
        );

        expect(adapter.requests, hasLength(3));
        expect(adapter.requests.map((e) => e.method), ['POST', 'GET', 'POST']);
        expect(adapter.requests.map((e) => e.uri.queryParameters), [
          <String, String>{},
          {'i': '1'},
          <String, String>{},
        ]);
        dio.close(force: true);
      },
    );
  });
}

Dio _dio(Uri baseUri, _ScriptedAdapter adapter) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUri.toString(),
      responseType: ResponseType.plain,
      connectTimeout: const Duration(seconds: 2),
      receiveTimeout: const Duration(seconds: 2),
    ),
  );
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(InfinityFreeChallengeInterceptor(dio));
  return dio;
}

String _challenge(
  Uri requestUri, {
  String cipherText = '25b509cc7dadcdb532275647f94524cc',
}) {
  final redirect = requestUri.replace(queryParameters: {'i': '1'});
  return '''
<html><body><script type="text/javascript" src="/aes.js"></script><script>
function toNumbers(d){var e=[];d.replace(/(..)/g,function(d){e.push(parseInt(d,16))});return e}
var a=toNumbers("f655ba9d09a112d4968c63579db590b4"),b=toNumbers("98344c2eee86c3994890592585b49f80"),c=toNumbers("$cipherText");
document.cookie="__test="+toHex(slowAES.decrypt(c,2,a,b))+"; max-age=21600; path=/";
location.href="$redirect";
</script></body></html>
''';
}

ResponseBody _html(String body, [int statusCode = 200]) {
  return ResponseBody.fromString(
    body,
    statusCode,
    headers: {
      Headers.contentTypeHeader: ['text/html; charset=utf-8'],
    },
  );
}

ResponseBody _text(String body, int statusCode) {
  return ResponseBody.fromString(
    body,
    statusCode,
    headers: {
      Headers.contentTypeHeader: ['text/plain; charset=utf-8'],
    },
  );
}

ResponseBody _json(String body, int statusCode) {
  return ResponseBody.fromString(
    body,
    statusCode,
    headers: {
      Headers.contentTypeHeader: ['application/json; charset=utf-8'],
    },
  );
}

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.respond);

  final Future<ResponseBody> Function(RequestOptions request, List<int>? body)
  respond;
  final requests = <_RecordedRequest>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = requestStream == null
        ? null
        : await requestStream.fold<List<int>>(
            <int>[],
            (bytes, chunk) => bytes..addAll(chunk),
          );
    requests.add(_RecordedRequest(options, body));
    return respond(options, body);
  }

  @override
  void close({bool force = false}) {}
}

String? _headerValue(Map<String, dynamic> headers, String name) {
  for (final entry in headers.entries) {
    if (entry.key.toLowerCase() == name.toLowerCase()) {
      return entry.value?.toString();
    }
  }
  return null;
}

class _RecordedRequest {
  const _RecordedRequest(this.options, this.body);

  final RequestOptions options;
  final List<int>? body;

  String get method => options.method;
  Uri get uri => options.uri;

  String? header(String name) => _headerValue(options.headers, name);
}
