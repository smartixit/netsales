import 'package:dio/dio.dart';

/// Tracks the crypto lifecycle of a Dio request across interceptor replays.
///
/// Replays re-enter the interceptor chain with the same RequestOptions.
/// The sealed body and ephemeral response key must be reused, and the key
/// pair must be finalized only once.
abstract final class ApiRequestReplayState {
  static const _cryptoPreparedKey = '__netsales_crypto_request_prepared';
  static const _cryptoLifecycleFinishedKey =
      '__netsales_crypto_lifecycle_finished';

  /// Whether this request has already passed through crypto preparation.
  static bool isCryptoPrepared(RequestOptions options) {
    return options.extra[_cryptoPreparedKey] == true;
  }

  /// Marks the current body/key pair as prepared for safe replay.
  static void markCryptoPrepared(RequestOptions options) {
    options.extra[_cryptoPreparedKey] = true;
  }

  /// Marks the crypto lifecycle as finished exactly once.
  ///
  /// Returns true for the first completion and false for subsequent handlers.
  static bool tryFinishCryptoLifecycle(RequestOptions options) {
    if (options.extra[_cryptoLifecycleFinishedKey] == true) {
      return false;
    }

    options.extra[_cryptoLifecycleFinishedKey] = true;
    return true;
  }
}