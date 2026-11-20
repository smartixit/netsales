import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/services/storage_service.dart';

/// Raised when the platform's authoritative device identifier is unavailable.
class DeviceIdentityUnavailableException implements Exception {
  const DeviceIdentityUnavailableException({this.cause});

  final Object? cause;

  @override
  String toString() {
    return 'The authoritative Android device identifier (Settings.Secure.ANDROID_ID) '
        'could not be read. Device-bound authentication cannot continue safely'
        '${cause == null ? '.' : ' (${cause.runtimeType}).'}';
  }
}

/// Resolves and persists the device identity used by device-bound sessions.
///
/// Android is deliberately handled differently from other platforms:
/// Settings.Secure.ANDROID_ID, obtained through FlutterUdid, is the only
/// accepted identity. A previously persisted value is not trusted on Android,
/// because older app versions could have stored Build.FINGERPRINT or a random
/// fallback there. Build identifiers and random values must never replace the
/// Android ID for session binding.
///
/// Other platforms retain the existing persisted-first resolution policy.
class DeviceIdentityStore {
  const DeviceIdentityStore();

  Future<String> resolve({
    required Future<String?> Function() resolvePlatformIdentifier,
    required String? hardwareFingerprint,
    required String Function() generateFallback,
    bool requirePlatformIdentifier = false,
  }) async {
    final storage = StorageService.instance;

    if (requirePlatformIdentifier) {
      return _resolveRequiredPlatformIdentifier(
        storage: storage,
        resolvePlatformIdentifier: resolvePlatformIdentifier,
      );
    }

    final persisted = storage.getString(StorageKeys.deviceUuid)?.trim();
    if (persisted != null && persisted.isNotEmpty) {
      final normalized = _limitLength(persisted);
      if (normalized != persisted) {
        final normalizedSaved = await storage.setString(
          StorageKeys.deviceUuid,
          normalized,
        );
        if (!normalizedSaved) {
          throw StateError('Failed to normalize the persisted device identity.');
        }
      }
      return normalized;
    }

    String resolved = '';
    try {
      resolved = (await resolvePlatformIdentifier())?.trim() ?? '';
    } catch (_) {
      // Continue to the platform-specific fallback for non-Android platforms.
    }

    if (resolved.isEmpty) {
      final fingerprint = hardwareFingerprint?.trim() ?? '';
      if (fingerprint.isNotEmpty) {
        final normalized = fingerprint.replaceAll(
          RegExp(r'[^a-zA-Z0-9]'),
          '',
        );
        if (normalized.isNotEmpty) {
          resolved = 'dev-$normalized';
        }
      }
    }

    if (resolved.isEmpty) {
      resolved = generateFallback().trim();
    }

    if (resolved.isEmpty) {
      throw StateError('Unable to resolve a persistent device identity.');
    }

    resolved = _limitLength(resolved);
    final saved = await storage.setString(StorageKeys.deviceUuid, resolved);
    if (!saved) {
      throw StateError('Failed to persist the resolved device identity.');
    }
    return resolved;
  }

  Future<String> _resolveRequiredPlatformIdentifier({
    required StorageService storage,
    required Future<String?> Function() resolvePlatformIdentifier,
  }) async {
    String? platformIdentifier;
    try {
      platformIdentifier = await resolvePlatformIdentifier();
    } catch (error) {
      throw DeviceIdentityUnavailableException(cause: error);
    }

    final resolved = platformIdentifier?.trim() ?? '';
    if (resolved.isEmpty) {
      throw const DeviceIdentityUnavailableException();
    }

    // Never truncate or transform a security identifier: doing so could
    // create collisions and would no longer be the exact platform ID.
    if (resolved.length > 64) {
      throw StateError(
        'The platform device identifier exceeds the supported 64 characters.',
      );
    }

    // Always refresh this value from Android ID. This intentionally replaces
    // legacy values persisted by earlier builds (Build.FINGERPRINT/random ID).
    final saved = await storage.setString(StorageKeys.deviceUuid, resolved);
    if (!saved) {
      throw StateError('Failed to persist the authoritative device identity.');
    }

    return resolved;
  }

  String _limitLength(String value) =>
      value.length <= 64 ? value : value.substring(0, 64);
}
