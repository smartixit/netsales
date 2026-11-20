import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/services/storage_service.dart';

/// Resolves and persists the device identity used by device-bound sessions.
///
/// The persisted value has priority over fresh platform lookups. This matters
/// when a platform identifier provider is temporarily unavailable or changes
/// its returned value between process launches: an existing server session
/// must keep presenting the same device UUID it was created with.
class DeviceIdentityStore {
  const DeviceIdentityStore();

  Future<String> resolve({
    required Future<String?> Function() resolvePlatformIdentifier,
    required String? hardwareFingerprint,
    required String Function() generateFallback,
  }) async {
    final storage = StorageService.instance;
    final persisted = storage.getString(StorageKeys.deviceUuid)?.trim();
    if (persisted != null && persisted.isNotEmpty) {
      return _limitLength(persisted);
    }

    String resolved = '';
    try {
      resolved = (await resolvePlatformIdentifier())?.trim() ?? '';
    } catch (_) {
      // Continue to the OS fingerprint and final persistent fallback.
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
    await storage.setString(StorageKeys.deviceUuid, resolved);
    return resolved;
  }

  String _limitLength(String value) =>
      value.length <= 64 ? value : value.substring(0, 64);
}
