import 'package:flutter/material.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';

/// مربعات حوار تأكيد إجراءات باقات الكروت (Package Action Dialogs)
class PackageActionDialogs {
  const PackageActionDialogs._();

  /// إظهار مربع حوار تأكيد تبديل حالة التفعيل
  static Future<void> showToggleStatusConfirmation(
    BuildContext context, {
    required PackageEntity package,
    required Future<void> Function() onConfirm,
  }) async {
    final willActivate = !package.isActive;
    await CustomDialog.confirmation(
      title: willActivate ? 'تفعيل باقة الكروت' : 'تعطيل باقة الكروت',
      message: willActivate
          ? 'هل أنت متأكد من رغبتك في تفعيل باقة "${package.packageName}"؟ ستصبح متاحة لطلبات الشراء لنقاط البيع المرتبطة.'
          : 'هل أنت متأكد من رغبتك في تعطيل باقة "${package.packageName}"؟ لن تتمكن نقاط البيع من تقديم طلبات شراء جديدة عليها.',
      confirmLabel: willActivate ? 'تأكيد التفعيل' : 'تأكيد التعطيل',
      cancelLabel: 'تراجع',
      onConfirm: onConfirm,
    ).showDialog(context);
  }

  /// إظهار مربع حوار تأكيد حذف الباقة
  static Future<void> showDeleteConfirmation(
    BuildContext context, {
    required PackageEntity package,
    required Future<void> Function() onConfirm,
  }) async {
    await CustomDialog.danger(
      title: 'حذف باقة الكروت',
      message:
          'هل أنت متأكد من رغبتك في حذف باقة "${package.packageName}"؟ سيتم نقل الباقة إلى سلة المحذوفات ولن تظهر في الكتالوج النشط.',
      confirmLabel: 'تأكيد الحذف',
      cancelLabel: 'إلغاء',
      onConfirm: onConfirm,
    ).showDialog(context);
  }
}
