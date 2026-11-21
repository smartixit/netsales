/// Resolves a device identity directly from the platform's authoritative API.
class DeviceIdentityUnavailableException implements Exception {
  const DeviceIdentityUnavailableException({
    required this.platform,
    this.cause,
  });
  final String platform;
  final Object? cause;

  @override
  String toString() {
    final source = platform.toLowerCase() == 'android'
        ? 'Settings.Secure.ANDROID_ID'
        : 'the native platform identifier';
    return 'Unable to read $source for $platform. '
        'Device-bound authentication cannot continue safely'
        '${cause == null ? '.' : ' (${cause.runtimeType}).'}';
  }
}

class DeviceIdentityResolver {
  const DeviceIdentityResolver();

  Future<String> resolve({
    required String platform,
    required Future<String?> Function() readPlatformIdentifier,
  }) async {
    String? value;
    try {
      value = await readPlatformIdentifier();
    } catch (error) {
      throw DeviceIdentityUnavailableException(
        platform: platform,
        cause: error,
      );
    }

    final identity = value?.trim() ?? '';
    if (identity.isEmpty) {
      throw DeviceIdentityUnavailableException(platform: platform);
    }
    if (identity.length > 64) {
      throw StateError(
        'The $platform device identifier exceeds the supported 64 characters.',
      );
    }
    return identity;
  }
}
