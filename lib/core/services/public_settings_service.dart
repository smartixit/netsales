import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/constants/app_constants.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/models/public_settings_model.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/core/services/storage_service.dart';

/// ============================================================================
/// خدمة إعدادات النظام العامة (Public Settings Service)
/// ============================================================================
/// توفر قراءة حية ومحدثة من جدول system_settings في الباكيند لبيانات التواصل
/// والهوية، مع دعم كامل للعمل دون اتصال (Offline-First) عبر التخزين المؤقت المحلي.
class PublicSettingsService extends GetxService {
  PublicSettingsService._();

  static final PublicSettingsService instance = PublicSettingsService._();

  static PublicSettingsService get to => Get.find<PublicSettingsService>();

  final Rx<PublicSettingsModel> _settings = const PublicSettingsModel(
    appName: AppConstants.appName,
    appCompanyName: 'Smartix Technology Solutions',
    appSupportPhone: AppConstants.supportPhone,
    appSupportWhatsApp: AppConstants.supportWhatsApp,
    appSupportEmail: AppConstants.supportEmail,
    defaultLocale: 'ar',
  ).obs;

  /// اسم التطبيق العام
  String get appName =>
      _settings.value.appName.isNotEmpty ? _settings.value.appName : AppConstants.appName;

  /// رقم هاتف الدعم الفني
  String get supportPhone => _settings.value.appSupportPhone.isNotEmpty
      ? _settings.value.appSupportPhone
      : AppConstants.supportPhone;

  /// رقم واتساب الدعم الفني
  String get supportWhatsApp => _settings.value.appSupportWhatsApp.isNotEmpty
      ? _settings.value.appSupportWhatsApp
      : AppConstants.supportWhatsApp;

  /// البريد الإلكتروني للدعم الفني
  String get supportEmail => _settings.value.appSupportEmail.isNotEmpty
      ? _settings.value.appSupportEmail
      : AppConstants.supportEmail;

  /// تهيئة الخدمة مع القراءة الفورية من التخزين المحلي ثم التحديث من الخادم
  Future<void> init() async {
    _loadFromLocalCache();
    // جلب أحدث الإعدادات من الخادم في الخلفية دون تعطيل الإقلاع
    unawaited(fetchSettings());
  }

  /// تحميل الإعدادات من التخزين المحلي إن وجدت
  void _loadFromLocalCache() {
    try {
      final cached = StorageService.instance.getJson(StorageKeys.publicSettings);
      if (cached != null) {
        _settings.value = PublicSettingsModel.fromJson(cached);
      }
    } catch (e) {
      log('⚠️ [PublicSettingsService] Error loading cached settings: $e');
    }
  }

  /// جلب أحدث إعدادات عامة من الخادم وتحديث التخزين المحلي
  Future<void> fetchSettings() async {
    try {
      final response = await ApiService.instance.get<PublicSettingsModel>(
        ApiConstants.systemSettingsPublic,
        fromJson: (json) => PublicSettingsModel.fromJson(json as Map<String, dynamic>),
      );

      if (response.success && response.data != null) {
        _settings.value = response.data!;
        await StorageService.instance.setJson(
          StorageKeys.publicSettings,
          response.data!.toJson(),
        );
      }
    } catch (e) {
      log('⚠️ [PublicSettingsService] Failed to fetch remote settings, using cache/defaults: $e');
    }
  }
}
