import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/utils/system_ui_style_resolver.dart';

/// ============================================================================
/// خدمة إدارة المظهر التفاعلية (Enterprise Reactive Theme Service)
/// ============================================================================
/// تدير التبديل اللحظي بين الوضعين الفاتح والداكن بنقرة واحدة (One-Click Toggle)،
/// مع الحفظ التلقائي في التخزين المحلي ومزامنة أشرطة النظام والاهتزاز اللمسي.
/// - تُراقب دورة حياة التطبيق (WidgetsBindingObserver) لإعادة تطبيق أشرطة
///   النظام بعد background/foreground (Guaranteed).
class ThemeService extends GetxService with WidgetsBindingObserver {
  ThemeService._();

  static final ThemeService instance = ThemeService._();

  static ThemeService get to => Get.find<ThemeService>();

  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;

  /// وضع المظهر الحالي المسجل
  ThemeMode get themeMode => _themeMode.value;

  /// هل التطبيق حالياً في الوضع الداكن (مع مراعاة وضع النظام التلقائي)
  bool get isDarkMode {
    if (_themeMode.value == ThemeMode.system) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode.value == ThemeMode.dark;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  /// إعادة تطبيق أشرطة النظام بعد العودة من الخلفية (Guaranteed)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      syncSystemOverlay(isDarkMode);
    }
  }

  /// تهيئة الخدمة وقراءة الوضع المخزن مسبقاً عند إقلاع التطبيق
  Future<ThemeService> init() async {
    final saved = StorageService.instance.themeMode;
    final mode = switch (saved) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };

    _themeMode.value = mode;
    syncSystemOverlay(isDarkMode);
    return this;
  }

  /// التبديل الفوري بين الفاتح والداكن بنقرة واحدة
  void toggleTheme() {
    // 1. تغذية حسية لمسية ناعمة
    HapticFeedback.lightImpact();

    // 2. حساب الوضع التالي
    final nextMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    final isNextDark = nextMode == ThemeMode.dark;

    // 3. التحديث التفاعلي في الذاكرة
    _themeMode.value = nextMode;

    // 4. تطبيق التغيير الفوري في GetX
    Get.changeThemeMode(nextMode);

    // 5. مزامنة أشرطة النظام (Status Bar & Navigation Bar)
    syncSystemOverlay(isNextDark);

    // 6. حفظ التفضيل في الخلفية
    StorageService.instance.saveThemeMode(isNextDark ? 'dark' : 'light');
  }

  /// ضبط وضع محدد صراحة (فاتح / داكن / نظام)
  void setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    Get.changeThemeMode(mode);

    final isDark = mode == ThemeMode.system
        ? (WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark)
        : mode == ThemeMode.dark;

    syncSystemOverlay(isDark);

    final stringValue = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
    StorageService.instance.saveThemeMode(stringValue);
  }

  /// مزامنة ألوان/أنماط أشرطة النظام (Single Source: SystemUiStyleResolver)
  void syncSystemOverlay(bool isDark) {
    final ctx = Get.context;
    if (ctx != null) {
      SystemUiStyleResolver.apply(ctx);
    } else {
      // Fallback (bootstrap safety)
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        ),
      );
    }
  }
}
