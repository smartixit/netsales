import 'package:netsales/widgets/dialogs/custom_dialog.dart';

/// نوافذ الحوار التفاعلية لقرارات فك الارتباط، تجميد النشاط، وتأكيد الشراكات التجارية
class CommercialActionDialogs {
  CommercialActionDialogs._();

  /// نافذة حوار تأكيد فك الارتباط التجاري
  static Future<void> showUnlinkDialog({
    required String partnerName,
    required Future<void> Function() onConfirm,
  }) async {
    await CustomDialog.show(
      type: DialogType.warning,
      title: 'فك الارتباط التجاري',
      message:
          'هل أنت متأكد من رغبتك في فك الارتباط التجاري مع "$partnerName"؟\nسيؤدي ذلك إلى إيقاف إمكانية إرسال أو استقبال طلبات التوريد المباشرة.',
      confirmLabel: 'تأكيد فك الارتباط',
      cancelLabel: 'تراجع',
      onConfirm: onConfirm,
    );
  }

  /// نافذة حوار تأكيد تجميد / تنشيط الارتباط التجاري
  static Future<void> showToggleStatusDialog({
    required String partnerName,
    required bool willDeactivate,
    required Future<void> Function() onConfirm,
  }) async {
    await CustomDialog.show(
      type: willDeactivate ? DialogType.warning : DialogType.confirmation,
      title: willDeactivate
          ? 'تجميد الارتباط التجاري'
          : 'تنشيط الارتباط التجاري',
      message: willDeactivate
          ? 'سيتم تجميد التعامل التجاري مؤقتاً مع "$partnerName". لن تتمكن نقطة البيع من رفع طلبات جديدة حتى إعادة التفعيل.'
          : 'سيتم إعادة تنشيط التعامل التجاري بالكامل مع "$partnerName".',
      confirmLabel: willDeactivate ? 'تأكيد التجميد' : 'تأكيد التنشيط',
      cancelLabel: 'إلغاء',
      onConfirm: onConfirm,
    );
  }

  /// نافذة حوار تأكيد إلغاء رمز دعوة الارتباط (Challenge)
  static Future<void> showRevokeChallengeDialog({
    required Future<void> Function() onConfirm,
  }) async {
    await CustomDialog.show(
      type: DialogType.warning,
      title: 'إلغاء رمز الدعوة',
      message: 'هل أنت متأكد من إلغاء رمز الدعوة الحالي؟ لن تتمكن أي نقطة بيع من استخدامه بعد الإلغاء.',
      confirmLabel: 'تأكيد الإلغاء',
      cancelLabel: 'تراجع',
      onConfirm: onConfirm,
    );
  }
}
