import 'package:flutter/material.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';

/// حوار تأكيد التفعيل المبكر للخطة المجدولة
class EarlyActivationDialog {
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) async {
    await CustomDialog.show(
      type: DialogType.warning,
      title: 'التفعيل المبكر للاشتراك',
      message: 'سيتم إنهاء دورة الاشتراك الحالية فوراً وتفعيل الباقة المجدولة التالية في طابور الانتظار وتجديد الحصص بالكامل. هل ترغب بالمتابعة؟',
      confirmLabel: 'نعم، فعّل الآن',
      cancelLabel: 'إلغاء',
      onConfirm: onConfirm,
    );
  }
}
