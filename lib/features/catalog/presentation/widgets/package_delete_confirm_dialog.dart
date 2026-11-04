import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';

/// حوار تأكيد حذف باقة الكروت
class PackageDeleteConfirmDialog {
  const PackageDeleteConfirmDialog._();

  static Future<void> show({
    required String packageName,
    required VoidCallback onConfirm,
  }) {
    return CustomDialog.showDanger(
      title: 'حذف باقة الكروت',
      message:
          'هل أنت متأكد من رغبتك في نقل باقة "$packageName" إلى سلة المحذوفات؟ لن يتمكن الوكلاء من طلبها بعد الحذف.',
      confirmLabel: 'تأكيد الحذف',
      cancelLabel: 'تراجع',
      onConfirm: () {
        Get.back<void>();
        onConfirm();
      },
    );
  }
}
