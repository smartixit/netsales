import 'dart:developer';
import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:get/get.dart';
import 'package:netsales/core/utils/idempotency_helper.dart';

/// ============================================================================
/// خدمة معلومات وبصمة الجهاز السيادية (Enterprise Device Intelligence Service)
/// ============================================================================
/// تمثل المصدر الأوحد لاستخراج بيانات العتاد وهوية الأجهزة وفق أعلى المعايير العالمية:
/// 1. استخراج معرّف عتادي فريد ودائم (Persistent Hardware Device UUID) يصمد أمام:
///    - مسح بيانات التطبيق (Clear App Data).
///    - إلغاء التثبيت وإعادة التثبيت (Uninstall & Reinstall).
///    - عبر iOS Keychain في هواتف آبل، و MediaDrm/Android ID في أجهزة أندرويد.
/// 2. صياغة اسم مقروء ومعبّر للجهاز (مثل: Samsung Galaxy S24 Ultra (Android 14)).
/// 3. تحديد نوع النظام المعتمد في الواجهة الخلفية (ANDROID, IOS, WINDOWS, MAC, LINUX, WEB).
class DeviceService extends GetxService {
  DeviceService._();

  static final DeviceService instance = DeviceService._();

  static DeviceService get to => Get.find<DeviceService>();

  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  String _deviceUuid = '';
  String _deviceName = '';
  String _deviceType = 'UNKNOWN';
  String _osVersion = '';
  String _model = '';
  String _brand = '';
  String _hardwareFingerprint = '';

  /// المعرف السيادي الفريد والدائم للجهاز
  String get deviceUuid => _deviceUuid;

  /// اسم الجهاز المقروء للإنسان
  String get deviceName => _deviceName;

  /// نوع الجهاز المعتمد في الواجهة الخلفية
  String get deviceType => _deviceType;

  /// إصدار نظام التشغيل
  String get osVersion => _osVersion;

  /// طراز الجهاز
  String get model => _model;

  /// العلامة التجارية
  String get brand => _brand;

  /// البصمة العتادية المستخرجة
  String get hardwareFingerprint => _hardwareFingerprint;

  /// تهيئة الخدمة واستخراج بيانات العتاد وتثبيت معرّف الجهاز الدائم
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
    } catch (e, stack) {
      log(
        '⚠️ [DeviceService] Failed to extract platform device info: $e',
        stackTrace: stack,
      );
      _fallbackDeviceInfo();
    }

    // تثبيت واستعادة معرّف الجهاز السيادي الدائم المقاوم لإعادة التثبيت
    await _resolveDeviceUuid();

    log(
      '📱 [DeviceService] Enterprise Ready: Name="$_deviceName", Type=$_deviceType, UUID=$_deviceUuid',
    );
    return this;
  }

  /// استخراج معلومات المتصفح
  Future<void> _extractWebInfo() async {
    final web = await _deviceInfoPlugin.webBrowserInfo;
    _deviceType = 'WEB';
    _brand = 'Web Browser';
    _model = web.browserName.name;
    _osVersion = web.platform ?? 'Web';
    _hardwareFingerprint = '${web.vendor ?? ''}-${web.userAgent ?? ''}';
    _deviceName = '${web.browserName.name} (${web.platform ?? 'Web'})';
  }

  /// استخراج معلومات أجهزة أندرويد
  Future<void> _extractAndroidInfo() async {
    final android = await _deviceInfoPlugin.androidInfo;
    _deviceType = 'ANDROID';
    _brand = android.brand.isNotEmpty ? android.brand : android.manufacturer;
    _model = android.model;
    _osVersion = 'Android ${android.version.release}';
    _hardwareFingerprint = android.fingerprint.isNotEmpty
        ? android.fingerprint
        : android.id;

    final formattedBrand = _capitalize(_brand);
    _deviceName = '$formattedBrand $_model ($_osVersion)'.trim();
  }

  /// استخراج معلومات أجهزة آبل (iOS)
  Future<void> _extractIosInfo() async {
    final ios = await _deviceInfoPlugin.iosInfo;
    _deviceType = 'IOS';
    _brand = 'Apple';
    _model = ios.utsname.machine.isNotEmpty ? ios.utsname.machine : ios.model;
    _osVersion = 'iOS ${ios.systemVersion}';
    _hardwareFingerprint = ios.identifierForVendor ?? '';

    final deviceFriendlyName = ios.name.isNotEmpty ? ios.name : _model;
    _deviceName = '$deviceFriendlyName ($_osVersion)';
  }

  /// استخراج معلومات أنظمة ويندوز
  Future<void> _extractWindowsInfo() async {
    final win = await _deviceInfoPlugin.windowsInfo;
    _deviceType = 'WINDOWS';
    _brand = 'Microsoft';
    _model = win.productName;
    _osVersion = win.displayVersion;
    _hardwareFingerprint = win.deviceId;

    _deviceName = '${win.computerName} (${win.productName})';
  }

  /// استخراج معلومات أجهزة ماك
  Future<void> _extractMacInfo() async {
    final mac = await _deviceInfoPlugin.macOsInfo;
    _deviceType = 'MAC';
    _brand = 'Apple';
    _model = mac.model;
    _osVersion = 'macOS ${mac.osRelease}';
    _hardwareFingerprint = mac.systemGUID ?? '';

    _deviceName = '${mac.computerName} (${mac.model})';
  }

  /// استخراج معلومات أنظمة لينكس
  Future<void> _extractLinuxInfo() async {
    final linux = await _deviceInfoPlugin.linuxInfo;
    _deviceType = 'LINUX';
    _brand = 'Linux';
    _model = linux.name;
    _osVersion = linux.version ?? '';
    _hardwareFingerprint = linux.machineId ?? '';

    _deviceName = linux.prettyName.isNotEmpty ? linux.prettyName : linux.name;
  }

  /// وضع الاحتياط في حال تعذر الوصول لمنفذ النظام
  void _fallbackDeviceInfo() {
    _deviceType = 'UNKNOWN';
    _brand = 'Generic';
    _model = 'Terminal';
    _osVersion = 'Unknown';
    _hardwareFingerprint = '';
    _deviceName = 'NetSales Client Device';
  }

  /// حل وتثبيت معرّف الجهاز السيادي الدائم والمقاوم لإلغاء التثبيت ومسح البيانات
  Future<void> _resolveDeviceUuid() async {
    // 1. الأولوية القصوى للمعرف العتادي الثابت (iOS Keychain / Android MediaDrm & SSAID / Windows Registry)
    if (!kIsWeb) {
      try {
        final udid = await FlutterUdid.udid;
        if (udid.trim().isNotEmpty) {
          _deviceUuid = udid.trim();
          if (_deviceUuid.length > 64) {
            _deviceUuid = _deviceUuid.substring(0, 64);
          }
          return;
        }
      } catch (e) {
        log('⚠️ [DeviceService] FlutterUdid lookup failed: $e');
      }
    }

    // 2. استخدام البصمة العتادية المقروءة من نظام التشغيل إن وُجدت
    if (_hardwareFingerprint.isNotEmpty) {
      _deviceUuid =
          'dev-${_hardwareFingerprint.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}';
      if (_deviceUuid.length > 64) {
        _deviceUuid = _deviceUuid.substring(0, 64);
      }
      return;
    }

    // 3. التوليد السيبراني المقاوم للتصادم كشبكة أمان نهائية
    _deviceUuid = IdempotencyHelper.generate('dev');
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
