import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netsales/core/services/app_exit_service.dart';

/// ============================================================================
/// ودجت الخروج الآمن بالنقر المزدوج (DoubleBackExitScope)
/// ============================================================================
/// تغلف أي واجهة في التطبيق بالاعتماد على [PopScope] الحديث من فلاتر لمنع
/// الخروج العرضي وتفعيل النقر المزدوج للخروج بشكل نظيف، معياري، وقابل لإعادة الاستخدام.
class DoubleBackExitScope extends StatelessWidget {
  /// الودجت الفرعية المحمية (مثل Scaffold الشاشة الرئيسية)
  final Widget child;

  /// دالة تراجع اختيارية يتم استدعاؤها أولاً قبل فحص الخروج.
  /// إذا أرجعت [false]، فهذا يعني أن الشاشة تعاملت مع حدث الرجوع داخلياً
  /// (مثلاً: الانتقال من تبويب فرعي إلى التبويب الرئيسي) ولن يتم فحص الخروج.
  /// إذا أرجعت [true]، يستمر المكون في فحص النقر المزدوج للخروج.
  final Future<bool> Function()? onFallback;

  /// أيقونة التنبيه العائم
  final IconData icon;

  /// رسالة التنبيه للمستخدم عند النقرة الأولى
  final String message;

  /// المهلة الزمنية للنقرة الثانية
  final Duration timeWindow;

  /// تفعيل أو تعطيل حماية الخروج
  final bool enabled;

  const DoubleBackExitScope({
    super.key,
    required this.child,
    this.onFallback,
    this.icon = Icons.exit_to_app_rounded,
    this.message = 'اضغط مرة أخرى للخروج من التطبيق',
    this.timeWindow = AppExitService.defaultTimeWindow,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        // 1. فحص دالة التراجع الداخلية للشاشة أولاً إن وجدت
        if (onFallback != null) {
          final shouldProceedToExit = await onFallback!();
          if (!shouldProceedToExit) {
            AppExitService.to.reset();
            return;
          }
        }

        // 2. التحقق من النقر المزدوج عبر الخدمة المستقلة
        final canExit = await AppExitService.to.handleExitRequest(
          message: message,
          icon: icon,
          timeWindow: timeWindow,
        );

        if (canExit) {
          await SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}
