import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:netsales/widgets/toasts/custom_toast.dart';

/// ============================================================================
/// خدمة الخروج الآمن بالنقر المزدوج (AppExitService)
/// ============================================================================
/// خدمة معيارية نظيفة، مستقلة تماماً وقابلة لإعادة الاستخدام في أي مشروع Flutter.
/// تدير مهلة النقر المزدوج على زر الرجوع الفيزيائي أو الإيماءات، وتطلق
/// التنبيه العائم الأنيق (Toast) والتغذية اللمسية لحماية المستخدم من الخروج العرضي.
class AppExitService extends GetxService {
  AppExitService._();
  static final AppExitService instance = AppExitService._();

  static AppExitService get to =>
      Get.isRegistered<AppExitService>() ? Get.find<AppExitService>() : instance;

  DateTime? _lastBackPressTime;

  /// المهلة الافتراضية المسموح بها للنقرة الثانية
  static const Duration defaultTimeWindow = Duration(seconds: 2);

  /// معالجة طلب الخروج
  ///
  /// ترجع [true] إذا كانت هذه النقرة الثانية خلال [timeWindow] (مما يعني السماح بالخروج).
  /// وترجع [false] إذا كانت هذه النقرة الأولى، مع عرض Toast عائم وأنيق للمستخدم.
  Future<bool> handleExitRequest({
    String message = 'اضغط مرة أخرى للخروج من التطبيق',
    IconData icon = Icons.exit_to_app_rounded,
    Duration timeWindow = defaultTimeWindow,
    bool showToast = true,
    bool triggerHaptic = true,
    void Function()? onFirstTap,
  }) async {
    final now = DateTime.now();

    if (_lastBackPressTime != null &&
        now.difference(_lastBackPressTime!) <= timeWindow) {
      _lastBackPressTime = null;
      if (triggerHaptic) {
        await HapticFeedback.mediumImpact();
      }
      return true;
    }

    _lastBackPressTime = now;

    if (triggerHaptic) {
      await HapticFeedback.lightImpact();
    }

    if (showToast) {
      CustomToast.show(
        message: message,
        icon: icon,
      );
    }

    onFirstTap?.call();
    return false;
  }

  /// إعادة ضبط وقت النقرة يدوياً (مثلاً عند التنقل بين الصفحات أو إلغاء الخروج)
  void reset() {
    _lastBackPressTime = null;
  }
}
