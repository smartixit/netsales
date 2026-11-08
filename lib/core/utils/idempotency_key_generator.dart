import 'dart:convert';
import 'dart:math';

/// Generates opaque, cryptographically strong keys for retry-safe mutations.
abstract final class IdempotencyKeyGenerator {
  IdempotencyKeyGenerator._();

  static final Random _secureRandom = Random.secure();

  static String generate() {
    final bytes = List<int>.generate(
      32,
      (_) => _secureRandom.nextInt(256),
      growable: false,
    );
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}
