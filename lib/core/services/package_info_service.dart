import 'dart:developer';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// ============================================================================
/// خدمة معلومات حزمة التطبيق والإصدار السيادية (Enterprise Package Info Service)
/// ============================================================================
/// تمثل المصدر الأوحد لاستخراج بيانات حزمة التطبيق وإصداره ومعرفاته الرقمية
/// وفق أعلى معايير الشركات الكبرى (Enterprise App Architecture):
///
/// 1. استخراج فوري متزامن من الذاكرة لبيانات الحزمة (AppName, PackageId, Version, BuildNumber).
/// 2. صياغة مخرجات منسقة وجاهزة للعرض في الواجهات (UI Display Versions).
/// 3. محرك مدمج للمقارنة الدلالية للإصدارات (SemVer Comparison Engine) للتحقق من التحديثات الإجبارية.
/// 4. ترويسات موحدة لشبكة الواجهة الخلفية (API Client Headers).
/// 5. متانة فائقة وحماية من الانهيار بقيم افتراضية آمنة (Graceful Degradation).
class PackageInfoService extends GetxService {
  PackageInfoService._();

  static final PackageInfoService instance = PackageInfoService._();

  static PackageInfoService get to =>
      Get.isRegistered<PackageInfoService>()
          ? Get.find<PackageInfoService>()
          : instance;

  // ─── البيانات السيادية للحزمة ───
  String _appName = 'NetSales';
  String _packageName = 'com.smartix.netsales';
  String _version = '1.0.0';
  String _buildNumberStr = '1';
  int _buildNumber = 1;
  String _buildSignature = '';
  String? _installerStore;
  bool _isInitialized = false;

  /// اسم التطبيق المقروء للإنسان
  String get appName => _appName;

  /// معرّف الحزمة البرمجية (Application ID / Bundle Identifier)
  String get packageName => _packageName;

  /// رقم الإصدار الدلالي الأساسي (مثل: 1.2.0)
  String get version => _version;

  /// رقم البناء الداخلي كنص (مثل: "42")
  String get buildNumberStr => _buildNumberStr;

  /// رقم البناء الداخلي كعدد صحيح (مثل: 42)
  int get buildNumber => _buildNumber;

  /// بصمة التوقيع الرقمية للشهادة (SHA-256) لحماية التطبيق من التعديل (Anti-Tampering)
  String get buildSignature => _buildSignature;

  /// متجر التثبيت الأصلي إن توفر (مثل: Google Play, Apple App Store, SideLoad)
  String? get installerStore => _installerStore;

  /// هل تم إكمال تهيئة بيانات الحزمة بنجاح
  bool get isInitialized => _isInitialized;

  // ─── خصائص التنسيق والعرض للواجهات (Presentation Ready) ───

  /// نص الإصدار الكامل المنسق باللغة العربية للواجهات (مثل: "الإصدار 1.2.0 (42)")
  String get displayVersion => 'الإصدار $_version ($_buildNumberStr)';

  /// الإصدار بصيغة SemVer القياسية المدمجة (مثل: "1.2.0+42")
  String get fullVersion => '$_version+$_buildNumberStr';

  /// نص الإصدار المختصر للتذييل والشاشات الضيقة (مثل: "v1.2.0")
  String get shortVersion => 'v$_version';

  // ─── مؤشرات بيئة التشغيل والتشخيص (Environment Diagnostics) ───

  /// هل يعمل التطبيق في وضع الإنتاج النهائي (Release Mode)
  bool get isRelease => kReleaseMode;

  /// هل يعمل التطبيق في وضع التطوير والتنقيح (Debug Mode)
  bool get isDebug => kDebugMode;

  /// هل يعمل التطبيق في وضع التحليل وقياس الأداء (Profile Mode)
  bool get isProfile => kProfileMode;

  /// هل يعمل التطبيق داخل بيئة المتصفح (Web)
  bool get isWeb => kIsWeb;

  /// اسم المنصة المشغلة للتطبيق الحالية
  String get platformName {
    if (kIsWeb) return 'WEB';
    if (Platform.isAndroid) return 'ANDROID';
    if (Platform.isIOS) return 'IOS';
    if (Platform.isWindows) return 'WINDOWS';
    if (Platform.isMacOS) return 'MACOS';
    if (Platform.isLinux) return 'LINUX';
    return 'UNKNOWN';
  }

  /// ترويسات العميل المعيارية الموجهة للواجهة الخلفية (API Client Headers)
  Map<String, String> get apiHeaders => {
        'X-App-Name': _appName,
        'X-App-Package': _packageName,
        'X-App-Version': _version,
        'X-App-Build': _buildNumberStr,
        'X-App-Platform': platformName,
      };

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. التهيئة واستخراج البيانات (Initialization)
  // ═══════════════════════════════════════════════════════════════════════════

  /// تهيئة الخدمة واستخراج بيانات الحزمة من المنصة مع ضمان عدم الانهيار (Fault-Tolerant)
  Future<PackageInfoService> init() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _appName = info.appName.isNotEmpty ? info.appName : _appName;
      _packageName =
          info.packageName.isNotEmpty ? info.packageName : _packageName;
      _version = info.version.isNotEmpty ? info.version : _version;
      _buildNumberStr =
          info.buildNumber.isNotEmpty ? info.buildNumber : _buildNumberStr;
      _buildNumber = int.tryParse(_buildNumberStr) ?? 1;
      _buildSignature = info.buildSignature;
      _installerStore = info.installerStore;
      _isInitialized = true;

      log(
        '📦 [PackageInfoService] Enterprise Ready: App="$_appName", Version="$fullVersion", Store="${_installerStore ?? 'Native'}"',
      );
    } catch (e, stack) {
      log(
        '⚠️ [PackageInfoService] Failed to read package info from platform, using safe fallbacks: $e',
        stackTrace: stack,
      );
      _isInitialized = true;
    }

    return this;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. محرك مقارنة الإصدارات الدلالي (Semantic Versioning Engine)
  // ═══════════════════════════════════════════════════════════════════════════

  /// التحقق مما إذا كان إصدار التطبيق الحالي أقل من الإصدار المستهدف (مفيد للتحديث الإجباري)
  bool isLowerThan(String targetVersion) {
    return compareVersions(_version, targetVersion) < 0;
  }

  /// التحقق مما إذا كان إصدار التطبيق الحالي مساوياً للإصدار المستهدف
  bool isSameVersion(String targetVersion) {
    return compareVersions(_version, targetVersion) == 0;
  }

  /// التحقق مما إذا كان إصدار التطبيق الحالي أكبر من الإصدار المستهدف
  bool isGreaterThan(String targetVersion) {
    return compareVersions(_version, targetVersion) > 0;
  }

  /// التحقق مما إذا كان التطبيق بحاجة إلى تحديث مقارنة بالحد الأدنى المطلوب
  bool needsUpdate({required String minimumRequiredVersion}) {
    return isLowerThan(minimumRequiredVersion);
  }

  /// دالة مقارنة دلالية معيارية بين إصدارين (ترجع -1 إذا كان v1 < v2، و 1 إذا كان v1 > v2، و 0 إذا تساويا)
  static int compareVersions(String v1, String v2) {
    final segs1 = _parseVersionSegments(v1);
    final segs2 = _parseVersionSegments(v2);
    final maxLength = math.max(segs1.length, segs2.length);

    for (int i = 0; i < maxLength; i++) {
      final s1 = i < segs1.length ? segs1[i] : 0;
      final s2 = i < segs2.length ? segs2[i] : 0;

      if (s1 < s2) return -1;
      if (s1 > s2) return 1;
    }

    return 0;
  }

  /// تجزئة وتطهير مقاطع الإصدار إلى مصفوفة أعداد صحيحة
  static List<int> _parseVersionSegments(String rawVersion) {
    if (rawVersion.isEmpty) return const [0];

    // إزالة البادئات غير الرقمية الشائعة مثل 'v' أو 'V' وتجاهل بيانات البناء '+build' أو الوسوم '-beta'
    final clean = rawVersion.trim().replaceAll(RegExp(r'^[vV]'), '');
    final core = clean.split('+').first.split('-').first;
    final parts = core.split('.');

    return parts.map((part) => int.tryParse(part.trim()) ?? 0).toList();
  }
}

