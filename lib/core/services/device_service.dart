import 'dart:developer';
import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/utils/idempotency_helper.dart';

/// ============================================================================
/// خدمة معلومات وبصمة الجهاز السيادية (Enterprise Device Intelligence Service)
/// ============================================================================
/// تمثل المصدر الأوحد لاستخراج بيانات العتاد وهوية الأجهزة وفق أعلى المعايير:
/// 1. قراءة بيانات العتاد الحقيقية عبر [DeviceInfoPlugin].
/// 2. توليد وتثبيت معرّف عتادي فريد ودائم للجهاز (Device UUID) لا يتأثر بالخروج أو إعادة التشغيل.
/// 3. صياغة اسم معبّر ومقروء للجهاز (Device Name) يُرسل للواجهة الخلفية لإشعارات الأمان وجدول الأجهزة.
/// 4. تحديد نوع المنصة المعتمد في Enums الباك إند (ANDROID, IOS, WINDOWS, MAC, LINUX, WEB).
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

  /// اسم الجهاز المقروء للإنسان (مثل: Samsung Galaxy S24 Ultra (Android 14))
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

  /// تهيئة الخدمة واستخراج بيانات العتاد وتثبيت معرّف الجهاز
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
        '⚠️ [DeviceService] Failed to extract device info: $e',
        stackTrace: stack,
      );
      _fallbackDeviceInfo();
    }

    // تثبيت واستعادة معرّف الجهاز السيادي
    _resolveDeviceUuid();

    // حفظ المعرف في التخزين الموضعي لضمان حقنه في ترويسات [X-Device-Uuid]
    final storage = StorageService.instance;
    if (storage.deviceUuid != _deviceUuid) {
      await storage.saveDeviceUuid(_deviceUuid);
    }

    log(
      '📱 [DeviceService] Ready: Name="$_deviceName", Type=$_deviceType, UUID=$_deviceUuid',
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
    _hardwareFingerprint = android.id;

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

  /// وضع الاحتياط في حال تعذر الوصول لمنفذ المنصة
  void _fallbackDeviceInfo() {
    _deviceType = 'UNKNOWN';
    _brand = 'Generic';
    _model = 'Terminal';
    _osVersion = 'Unknown';
    _hardwareFingerprint = '';
    _deviceName = 'NetSales Client Device';
  }

  /// حل وتثبيت معرّف الجهاز السيادي الدائم
  void _resolveDeviceUuid() {
    // 1. الأولوية للمعرف المحفوظ مسبقاً في التخزين الموضعي
    final cached = StorageService.instance.deviceUuid;
    if (cached != null && cached.trim().isNotEmpty) {
      _deviceUuid = cached.trim();
      return;
    }

    // 2. استخدام البصمة العتادية إن وُجدت
    if (_hardwareFingerprint.isNotEmpty) {
      _deviceUuid =
          'dev-${_hardwareFingerprint.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}';
      if (_deviceUuid.length > 64) {
        _deviceUuid = _deviceUuid.substring(0, 64);
      }
      return;
    }

    // 3. التوليد السيبراني الفريد والمحصن ضد التصادم
    _deviceUuid = IdempotencyHelper.generate('dev');
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
