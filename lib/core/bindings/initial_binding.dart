import 'package:get/get.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/core/services/app_exit_service.dart';
import 'package:netsales/core/services/public_settings_service.dart';
import 'package:netsales/core/services/sound_service.dart';
import 'package:netsales/core/services/file_picker_service.dart';
import 'package:netsales/core/services/date_picker_service.dart';
import 'package:netsales/core/services/credential_service.dart';

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

    // 2. تهيئة خدمة إعدادات النظام العامة وقنوات الدعم
    Get.lazyPut<PublicSettingsService>(
      () => PublicSettingsService.instance,
      fenix: true,
    );

    // 2. خدمة المؤثرات الصوتية والتنبيهات
    Get.lazyPut<SoundService>(() => SoundService.instance, fenix: true);

    // 3. خدمة الخروج الآمن بالنقر المزدوج المستقلة
    Get.lazyPut<AppExitService>(() => AppExitService.instance, fenix: true);

    // 4. خدمة منتقي التاريخ والوقت الموحدة
    Get.lazyPut<DatePickerService>(
      () => DatePickerService.instance,
      fenix: true,
    );

    // 5. خدمة اختيار المرفقات والملفات الموحدة
    Get.lazyPut<FilePickerService>(
      () => FilePickerService.instance,
      fenix: true,
    );

    // 6. خدمة إدارة الاعتماد المشفرة والمصادقة الحيوية
    Get.lazyPut<CredentialService>(
      () => CredentialService.instance,
      fenix: true,
    );
  }
}
