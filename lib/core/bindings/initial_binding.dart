import 'package:get/get.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/core/services/internet_connection_service.dart';
import 'package:netsales/core/services/app_exit_service.dart';
import 'package:netsales/core/services/public_settings_service.dart';
import 'package:netsales/core/services/push_notification_service.dart';
import 'package:netsales/core/services/sound_service.dart';

/// ============================================================================
/// حقن الاعتماديات العام الموحد للتطبيق (Global Application Bindings)
/// ============================================================================
/// مخصص حصرياً للخدمات العامة المشتركة عبر التطبيق التي لا تعيق الإقلاع الأولي
/// في main()، مع منع تكرار حقن الخدمات السيادية المحقونة مسبقاً (Zero Duplication).
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 1. عميل الاتصال الشبكي الموحد
    Get.lazyPut<ApiService>(() => ApiService.instance, fenix: true);

    // 2. خدمة مراقبة الاتصال بالإنترنت
    Get.lazyPut<InternetConnectionService>(
      () => InternetConnectionService.instance,
      fenix: true,
    );

    // 3. خدمة المؤثرات الصوتية والتنبيهات
    Get.lazyPut<SoundService>(() => SoundService.instance, fenix: true);

    // 4. خدمة الإشعارات المركزية المؤسسية (FCM & Local Notifications)
    Get.lazyPut<PushNotificationService>(
      () => PushNotificationService.instance,
      fenix: true,
    );

    // 5. خدمة إعدادات النظام العامة وقنوات الدعم
    Get.lazyPut<PublicSettingsService>(
      () => PublicSettingsService.instance,
      fenix: true,
    );

    // 6. خدمة الخروج الآمن بالنقر المزدوج المستقلة
    Get.lazyPut<AppExitService>(
      () => AppExitService.instance,
      fenix: true,
    );
  }
}
