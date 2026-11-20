import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/services/device_identity_resolver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('returns the exact platform identifier', () async {
    final value = await const DeviceIdentityResolver().resolve(
      platform: 'android',
      readPlatformIdentifier: () async => 'a1b2c3d4e5f60718',
    );
    expect(value, 'a1b2c3d4e5f60718');
  });

  test('reads platform identity on every initialization', () async {
    var reads = 0;
    final resolver = const DeviceIdentityResolver();
    final first = await resolver.resolve(
      platform: 'android',
      readPlatformIdentifier: () async { reads++; return 'android-id'; },
    );
    final second = await resolver.resolve(
      platform: 'android',
      readPlatformIdentifier: () async { reads++; return 'android-id'; },
    );
    expect(first, second);
    expect(reads, 2);
  });

  test('rejects missing and empty identifiers', () async {
    final resolver = const DeviceIdentityResolver();
    await expectLater(
      resolver.resolve(platform: 'android', readPlatformIdentifier: () async => null),
      throwsA(isA<DeviceIdentityUnavailableException>()),
    );
    await expectLater(
      resolver.resolve(platform: 'android', readPlatformIdentifier: () async => '  '),
      throwsA(isA<DeviceIdentityUnavailableException>()),
    );
  });

  test('fails without generating a substitute when native lookup throws', () async {
    await expectLater(
      const DeviceIdentityResolver().resolve(
        platform: 'android',
        readPlatformIdentifier: () async => throw StateError('unavailable'),
      ),
      throwsA(isA<DeviceIdentityUnavailableException>()),
    );
  });

  test('rejects oversized identifiers instead of truncating them', () async {
    await expectLater(
      const DeviceIdentityResolver().resolve(
        platform: 'android',
        readPlatformIdentifier: () async => List.filled(65, 'a').join(),
      ),
      throwsStateError,
    );
  });
}
