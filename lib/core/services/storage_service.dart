import 'dart:convert';

import 'package:netsales/core/constants/storage_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  SharedPreferences? _prefs;

  /// يجب استدعاؤها مرة واحدة في main() قبل runApp
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// إعادة تحميل البيانات من القرص (مفيدة عند التعديل من مكان آخر)
  Future<void> reload() => _prefs!.reload();

  /// وصول آمن مع رسالة خطأ واضحة إذا نسيت init()
  SharedPreferences get _p {
    final p = _prefs;
    if (p == null) {
      throw StateError(
        'StorageService غير مُهيّأة. استدعِ '
        'await StorageService.instance.init() في main()',
      );
    }
    return p;
  }

  // ==================== String ====================
  Future<bool> setString(String key, String value) => _p.setString(key, value);

  String? getString(String key) => _p.getString(key);

  String getStringOr(String key, String fallback) =>
      _p.getString(key) ?? fallback;

  // ==================== int ====================
  Future<bool> setInt(String key, int value) => _p.setInt(key, value);

  int? getInt(String key) => _p.getInt(key);

  int getIntOr(String key, int fallback) => _p.getInt(key) ?? fallback;

  // ==================== double ====================
  Future<bool> setDouble(String key, double value) => _p.setDouble(key, value);

  double? getDouble(String key) => _p.getDouble(key);

  double getDoubleOr(String key, double fallback) =>
      _p.getDouble(key) ?? fallback;

  // ==================== bool ====================
  Future<bool> setBool(String key, bool value) => _p.setBool(key, value);

  bool? getBool(String key) => _p.getBool(key);

  bool getBoolOr(String key, bool fallback) => _p.getBool(key) ?? fallback;

  // ==================== StringList ====================
  Future<bool> setStringList(String key, List<String> value) =>
      _p.setStringList(key, value);

  List<String> getStringList(String key) => _p.getStringList(key) ?? [];

  // ==================== JSON (Map) ====================
  /// حفظ أي Map كـ JSON
  Future<bool> setJson(String key, Map<String, dynamic> value) =>
      _p.setString(key, jsonEncode(value));

  /// قراءة Map محفوظ كـ JSON
  Map<String, dynamic>? getJson(String key) {
    final raw = _p.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ==================== Model ====================
  /// حفظ أي Model عبر دالة toJson الخاصة به
  /// مثال: setModel(StorageKeys.userData, user, (u) => u.toJson());
  Future<bool> setModel<T>(
    String key,
    T model,
    Map<String, dynamic> Function(T model) toJson,
  ) => setJson(key, toJson(model));

  /// قراءة Model عبر دالة fromJson الخاصة به
  /// مثال: getModel(StorageKeys.userData, UserModel.fromJson);
  T? getModel<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final json = getJson(key);
    if (json == null) return null;
    try {
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }

  // ==================== إدارة عامة ====================
  bool containsKey(String key) => _p.containsKey(key);

  Future<bool> remove(String key) => _p.remove(key);

  Future<bool> clear() => _p.clear();
  Set<String> getKeys() => _p.getKeys();

  // ============ اختصارات مساعدة للجلسة والتطبيق ============

  /// معرف الجلسة الحالية
  Future<bool> saveSession(String session) =>
      setString(StorageKeys.session, session);
  String? get sessionId => getString(StorageKeys.session);
  Future<bool> clearSession() => remove(StorageKeys.session);


  /// حالة تسجيل الدخول
  Future<bool> setLoggedIn(bool value) =>
      setBool(StorageKeys.isLoggedIn, value);
  bool get isLoggedIn => getBoolOr(StorageKeys.isLoggedIn, false);

  /// أول تشغيل (شاشات Onboarding)
  bool get isFirstLaunch => getBoolOr(StorageKeys.isFirstLaunch, true);
  Future<bool> setFirstLaunchDone() =>
      setBool(StorageKeys.isFirstLaunch, false);

  /// الثيم: light | dark | system
  Future<bool> saveThemeMode(String mode) =>
      setString(StorageKeys.themeMode, mode);
  String get themeMode => getStringOr(StorageKeys.themeMode, 'system');

  /// اللغة: ar | en
  Future<bool> saveLocale(String code) => setString(StorageKeys.locale, code);
  String get locale => getStringOr(StorageKeys.locale, 'ar');

  /// مسح بيانات الجلسة والمستخدم فقط عند تسجيل الخروج
  Future<void> logout() async {
    await remove(StorageKeys.session);
    await remove(StorageKeys.userId);
    await remove(StorageKeys.userData);
    await setLoggedIn(false);
  }
}

