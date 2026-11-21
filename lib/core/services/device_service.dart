import 'dart:developer';
import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/services/device_identity_resolver.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/utils/idempotency_helper.dart';

/// Device metadata and authoritative platform identity.
/// Android identity is Settings.Secure.ANDROID_ID via FlutterUdid.
/// Native identities come from FlutterUdid; no native fingerprint or random
/// fallback is allowed. Web has its own persisted browser-installation ID.
class DeviceService extends GetxService {
  DeviceService._();
  static final DeviceService instance = DeviceService._();
  static DeviceService get to =>
      Get.isRegistered<DeviceService>() ? Get.find<DeviceService>() : instance;

  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  String _deviceUuid = '';
  String _deviceName = '';
  String _deviceType = 'UNKNOWN';
  String _osVersion = '';
  String _model = '';
  String _brand = '';

  String get deviceUuid => _deviceUuid;
  String get deviceName => _deviceName;
  String get deviceType => _deviceType;
  String get osVersion => _osVersion;
  String get model => _model;
  String get brand => _brand;

  Future<DeviceService> init() async {
    try {
      if (kIsWeb) {
        await _extractWebInfo();
      } else if (Platform.isAndroid) {
        await _extractAndroidInfo();
      } else if (Platform.isIOS) {
        await _extractIosInfo();
      } else if (Platform.isWindows) {
        await _extractWindowsInfo();
      } else if (Platform.isMacOS) {
        await _extractMacInfo();
      } else if (Platform.isLinux) {
        await _extractLinuxInfo();
      } else {
        _fallbackDeviceInfo();
      }
    } catch (error, stack) {
      log(
        '⚠️ [DeviceService] Failed to extract platform device info: $error',
        stackTrace: stack,
      );
      _fallbackDeviceInfo();
    }
    await _resolveDeviceUuid();
    log('📱 [DeviceService] Device identity initialized. Type=$_deviceType');
    return this;
  }

  Future<void> _extractWebInfo() async {
    final web = await _deviceInfoPlugin.webBrowserInfo;
    _deviceType = 'WEB';
    _brand = 'Web Browser';
    _model = web.browserName.name;
    _osVersion = web.platform ?? 'Web';
    _deviceName = '${web.browserName.name} (${web.platform ?? 'Web'})';
  }

  Future<void> _extractAndroidInfo() async {
    final android = await _deviceInfoPlugin.androidInfo;
    _deviceType = 'ANDROID';
    _brand = android.brand.isNotEmpty ? android.brand : android.manufacturer;
    _model = android.model;
    _osVersion = 'Android ${android.version.release}';
    _deviceName = '${_capitalize(_brand)} $_model ($_osVersion)'.trim();
    // android.fingerprint and android.id are Build.FINGERPRINT and Build.ID,
    // not Settings.Secure.ANDROID_ID. They are intentionally never read.
  }

  Future<void> _extractIosInfo() async {
    final ios = await _deviceInfoPlugin.iosInfo;
    _deviceType = 'IOS';
    _brand = 'Apple';
    _model = ios.utsname.machine.isNotEmpty ? ios.utsname.machine : ios.model;
    _osVersion = 'iOS ${ios.systemVersion}';
    final friendlyName = ios.name.isNotEmpty ? ios.name : _model;
    _deviceName = '$friendlyName ($_osVersion)';
  }

  Future<void> _extractWindowsInfo() async {
    final win = await _deviceInfoPlugin.windowsInfo;
    _deviceType = 'WINDOWS';
    _brand = 'Microsoft';
    _model = win.productName;
    _osVersion = win.displayVersion;
    _deviceName = '${win.computerName} (${win.productName})';
  }

  Future<void> _extractMacInfo() async {
    final mac = await _deviceInfoPlugin.macOsInfo;
    _deviceType = 'MAC';
    _brand = 'Apple';
    _model = mac.model;
    _osVersion = 'macOS ${mac.osRelease}';
    _deviceName = '${mac.computerName} (${mac.model})';
  }

  Future<void> _extractLinuxInfo() async {
    final linux = await _deviceInfoPlugin.linuxInfo;
    _deviceType = 'LINUX';
    _brand = 'Linux';
    _model = linux.name;
    _osVersion = linux.version ?? '';
    _deviceName = linux.prettyName.isNotEmpty ? linux.prettyName : linux.name;
  }

  void _fallbackDeviceInfo() {
    _deviceType = _resolvePlatformType();
    _brand = 'Generic';
    _model = 'Terminal';
    _osVersion = 'Unknown';
    _deviceName = 'NetSales Client Device';
  }

  String _resolvePlatformType() {
    if (kIsWeb) return 'WEB';
    if (Platform.isAndroid) return 'ANDROID';
    if (Platform.isIOS) return 'IOS';
    if (Platform.isWindows) return 'WINDOWS';
    if (Platform.isMacOS) return 'MAC';
    if (Platform.isLinux) return 'LINUX';
    return 'UNKNOWN';
  }

  Future<void> _resolveDeviceUuid() async {
    if (kIsWeb) {
      _deviceUuid = await _resolveWebDeviceUuid();
      return;
    }
    final platform = Platform.operatingSystem;
    try {
      _deviceUuid = await const DeviceIdentityResolver().resolve(
        platform: platform,
        readPlatformIdentifier: () => FlutterUdid.udid,
      );
    } catch (error, stack) {
      log(
        '⚠️ [DeviceService] FlutterUdid lookup failed on $platform. '
        'Authoritative device identity is unavailable; authentication is blocked: $error',
        error: error,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  Future<String> _resolveWebDeviceUuid() async {
    final storage = StorageService.instance;
    final stored = storage.getString(StorageKeys.webDeviceUuid)?.trim();
    if (stored != null && stored.isNotEmpty) {
      if (stored.length > 64) {
        throw StateError(
          'Persisted Web device identifier exceeds 64 characters.',
        );
      }
      return stored;
    }
    final generated = IdempotencyHelper.generate('web');
    final saved = await storage.setString(StorageKeys.webDeviceUuid, generated);
    if (!saved) throw StateError('Failed to persist the Web browser identity.');
    return generated;
  }

  String _capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}
