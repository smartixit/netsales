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

  test('restores the exact device UUID without resolving another platform ID', () async {
    const resolver = DeviceIdentityStore();
    final firstIdentity = await resolver.resolve(
      resolvePlatformIdentifier: () async => 'platform-id-at-login',
      hardwareFingerprint: 'fingerprint-at-login',
      generateFallback: () => 'generated-at-login',
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
    expect(
      StorageService.instance.getString(StorageKeys.deviceUuid),
      firstIdentity,
    );
  });

  test('persists the generated fallback for the next process launch', () async {
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

  test('uses and persists OS fingerprint if platform plugin is unavailable', () async {
    const resolver = DeviceIdentityStore();
    final identity = await resolver.resolve(
      resolvePlatformIdentifier: () async => null,
      hardwareFingerprint: 'ANDROID/build:fingerprint-123',
      generateFallback: () => 'unused-fallback',
    );

    expect(identity, 'dev-ANDROIDbuildfingerprint123');
    expect(
      StorageService.instance.getString(StorageKeys.deviceUuid),
      identity,
    );
  });

  test('rejects an empty final fallback rather than rotating on every launch', () async {
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

  test('normalizes persisted identifiers to the server-supported 64 characters', () async {
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
