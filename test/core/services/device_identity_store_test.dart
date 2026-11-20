import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/services/device_identity_store.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
  });

  test('restores the same Android ID across launches by resolving it each time', () async {
    const resolver = DeviceIdentityStore();
    var lookupCount = 0;

    final firstIdentity = await resolver.resolve(
      resolvePlatformIdentifier: () async {
        lookupCount++;
        return 'android-id-0123456789abcdef';
      },
      hardwareFingerprint: 'ignored-build-fingerprint',
      generateFallback: () => 'unused-random-fallback',
      requirePlatformIdentifier: true,
    );

    final restoredIdentity = await resolver.resolve(
      resolvePlatformIdentifier: () async {
        lookupCount++;
        return 'android-id-0123456789abcdef';
      },
      hardwareFingerprint: 'different-build-fingerprint-after-restart',
      generateFallback: () => 'different-random-fallback',
      requirePlatformIdentifier: true,
    );

    expect(firstIdentity, 'android-id-0123456789abcdef');
    expect(restoredIdentity, firstIdentity);
    expect(lookupCount, 2);
    expect(
      StorageService.instance.getString(StorageKeys.deviceUuid),
      firstIdentity,
    );
  });

  test('replaces a legacy persisted fingerprint or random UUID with Android ID', () async {
    await StorageService.instance.setString(
      StorageKeys.deviceUuid,
      'legacy-build-fingerprint-or-random-id',
    );
    const resolver = DeviceIdentityStore();
    var fallbackCalled = false;

    final identity = await resolver.resolve(
      resolvePlatformIdentifier: () async => 'a1b2c3d4e5f60718',
      hardwareFingerprint: 'Build.FINGERPRINT-must-not-be-used',
      generateFallback: () {
        fallbackCalled = true;
        return 'must-not-be-used';
      },
      requirePlatformIdentifier: true,
    );

    expect(identity, 'a1b2c3d4e5f60718');
    expect(fallbackCalled, isFalse);
    expect(
      StorageService.instance.getString(StorageKeys.deviceUuid),
      'a1b2c3d4e5f60718',
    );
  });

  test('fails closed when Android ID is unavailable and ignores other fallbacks', () async {
    await StorageService.instance.setString(
      StorageKeys.deviceUuid,
      'legacy-untrusted-identity',
    );
    const resolver = DeviceIdentityStore();
    var fallbackCalled = false;

    await expectLater(
      resolver.resolve(
        resolvePlatformIdentifier: () async => null,
        hardwareFingerprint: 'Build.FINGERPRINT-must-not-be-used',
        generateFallback: () {
          fallbackCalled = true;
          return 'random-identity-must-not-be-used';
        },
        requirePlatformIdentifier: true,
      ),
      throwsA(isA<DeviceIdentityUnavailableException>()),
    );

    expect(fallbackCalled, isFalse);
    expect(
      StorageService.instance.getString(StorageKeys.deviceUuid),
      'legacy-untrusted-identity',
    );
  });

  test('fails closed when reading Android ID throws', () async {
    const resolver = DeviceIdentityStore();

    await expectLater(
      resolver.resolve(
        resolvePlatformIdentifier: () async =>
            throw StateError('plugin unavailable'),
        hardwareFingerprint: 'Build.FINGERPRINT-must-not-be-used',
        generateFallback: () => 'random-identity-must-not-be-used',
        requirePlatformIdentifier: true,
      ),
      throwsA(isA<DeviceIdentityUnavailableException>()),
    );
  });

  test('rejects oversized Android IDs instead of truncating a security identifier', () async {
    const resolver = DeviceIdentityStore();

    await expectLater(
      resolver.resolve(
        resolvePlatformIdentifier: () async => List<String>.filled(65, 'a').join(),
        hardwareFingerprint: null,
        generateFallback: () => 'unused',
        requirePlatformIdentifier: true,
      ),
      throwsStateError,
    );
  });

  test('keeps the persisted-first policy for non-Android platforms', () async {
    const resolver = DeviceIdentityStore();
    final firstIdentity = await resolver.resolve(
      resolvePlatformIdentifier: () async => 'platform-id-at-login',
      hardwareFingerprint: 'non-android-fingerprint',
      generateFallback: () => 'unused',
    );

    var platformLookupCalled = false;
    final restoredIdentity = await resolver.resolve(
      resolvePlatformIdentifier: () async {
        platformLookupCalled = true;
        return 'different-platform-id-after-restart';
      },
      hardwareFingerprint: 'different-fingerprint-after-restart',
      generateFallback: () => 'different-generated-id-after-restart',
    );

    expect(firstIdentity, 'platform-id-at-login');
    expect(restoredIdentity, firstIdentity);
    expect(platformLookupCalled, isFalse);
  });

  test('persists a non-Android generated fallback for the next process launch', () async {
    const resolver = DeviceIdentityStore();
    final firstIdentity = await resolver.resolve(
      resolvePlatformIdentifier: () async => null,
      hardwareFingerprint: null,
      generateFallback: () => 'generated-device-identity',
    );

    final restoredIdentity = await resolver.resolve(
      resolvePlatformIdentifier: () async => 'platform-id-now-available',
      hardwareFingerprint: 'new-hardware-fingerprint',
      generateFallback: () => 'a-different-generated-identity',
    );

    expect(firstIdentity, 'generated-device-identity');
    expect(restoredIdentity, firstIdentity);
  });

  test('uses a non-Android OS fingerprint fallback when platform ID is unavailable', () async {
    const resolver = DeviceIdentityStore();
    final identity = await resolver.resolve(
      resolvePlatformIdentifier: () async => null,
      hardwareFingerprint: 'WINDOWS/device:fingerprint-123',
      generateFallback: () => 'unused-fallback',
    );

    expect(identity, 'dev-WINDOWSdevicefingerprint123');
    expect(
      StorageService.instance.getString(StorageKeys.deviceUuid),
      identity,
    );
  });

  test('rejects an empty fallback on platforms that permit generated identities', () async {
    const resolver = DeviceIdentityStore();

    await expectLater(
      resolver.resolve(
        resolvePlatformIdentifier: () async => null,
        hardwareFingerprint: null,
        generateFallback: () => '',
      ),
      throwsStateError,
    );
  });

  test('normalizes persisted non-Android identifiers to 64 characters', () async {
    const resolver = DeviceIdentityStore();
    final identity = await resolver.resolve(
      resolvePlatformIdentifier: () async => List<String>.filled(80, 'd').join(),
      hardwareFingerprint: null,
      generateFallback: () => 'unused-fallback',
    );

    expect(identity.length, 64);
    expect(
      StorageService.instance.getString(StorageKeys.deviceUuid),
      identity,
    );
  });
}
