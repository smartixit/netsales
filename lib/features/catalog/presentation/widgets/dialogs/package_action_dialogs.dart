import 'package:netsales/widgets/dialogs/custom_dialog.dart';

/// حوارات التأكيد المركزية لإجراءات باقات الكروت (Package Action Dialogs)
class PackageActionDialogs {
  PackageActionDialogs._();

  /// حوار تأكيد تبديل حالة تفعيل الباقة (تفعيل / تعطيل)
  static Future<void> showToggleStatusDialog({
    required String packageName,
    required bool willDeactivate,
    required Future<void> Function() onConfirm,
  }) async {
    await CustomDialog.show(
      type: willDeactivate ? DialogType.warning : DialogType.confirmation,
      title: willDeactivate ? 'تعطيل باقة الكروت' : 'تفعيل باقة الكروت',
      message: willDeactivate
          ? 'هل أنت متأكد من رغبتك في تعطيل الباقة "$packageName"؟ لن يتمكن الوكلاء من شراء كروت جديدة منها حتى إعادة التفعيل.'
          : 'هل أنت متأكد من رغبتك في إعادة تفعيل الباقة "$packageName"؟ ستصبح متاحة لنقاط البيع المعتمدة فوراً.',
      confirmLabel: willDeactivate ? 'تعطيل الباقة' : 'تفعيل الباقة',
      cancelLabel: 'تراجع',
      onConfirm: () async {
        await onConfirm();
      },
    );
  }

  /// حوار تأكيد حذف باقة الكروت نهائياً أو مؤقتاً
  static Future<void> showDeletePackageDialog({
    required String packageName,
    required Future<void> Function() onConfirm,
  }) async {
    await CustomDialog.show(
      type: DialogType.error,
      title: 'حذف باقة الكروت',
      message:
          'هل أنت متأكد من رغبتك في نقل الباقة "$packageName" إلى سلة المحذوفات؟ يمكنك استعادتها لاحقاً طالما لم يتم حذفها نهائياً.',
      confirmLabel: 'حذف الباقة',
      cancelLabel: 'إلغاء',
      onConfirm: () async {
        await onConfirm();
      },
    );
  }
}
