import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/services/api_request_replay_state.dart';

void main() {
  group('ApiRequestReplayState', () {
    test('marks a sealed request so replay does not prepare it twice', () {
      final options = RequestOptions(
        path: '/auth/login',
        method: 'POST',
        data: {'payload': 'already-sealed'},
      );

      expect(ApiRequestReplayState.isCryptoPrepared(options), isFalse);

      ApiRequestReplayState.markCryptoPrepared(options);

      expect(ApiRequestReplayState.isCryptoPrepared(options), isTrue);
      expect(options.data, {'payload': 'already-sealed'});
    });

    test('finishes a replayed request crypto lifecycle only once', () {
      final options = RequestOptions(path: '/auth/login', method: 'POST');

      expect(
        ApiRequestReplayState.tryFinishCryptoLifecycle(options),
        isTrue,
      );
      expect(
        ApiRequestReplayState.tryFinishCryptoLifecycle(options),
        isFalse,
      );
    });
  });
}