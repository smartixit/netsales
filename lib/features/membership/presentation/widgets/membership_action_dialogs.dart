import 'package:netsales/core/enums/membership_status.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';

/// نوافذ الحوار التفاعلية لقرارات إدارة أعضاء مساحة العمل (MembershipActionDialogs)
///
/// تلتزم كلياً بنظام [CustomDialog] الموحد في `lib/widgets/dialogs/`
/// وتستهلك محرك الحالات [EnumPresentationRegistry] للحصول على المسميات الدلالية الموحدة.
class MembershipActionDialogs {
  MembershipActionDialogs._();

  /// نافذة تأكيد تغيير حالة العضوية (تجميد أو إعادة تفعيل)
  static Future<void> showToggleStatusDialog({
    required String memberName,
    required bool isCurrentlyActive,
    required Future<void> Function() onConfirm,
  }) async {
    final targetStatus = isCurrentlyActive
        ? MembershipStatus.suspended
        : MembershipStatus.active;
    final presentation = EnumPresentationRegistry.resolveMembershipStatus(
      targetStatus,
    );

    final title = isCurrentlyActive ? 'تجميد عضوية' : 'إعادة تفعيل عضوية';
    final actionText = isCurrentlyActive
        ? 'تأكيد ${presentation.label}'
        : 'تأكيد ${presentation.label}';
    final message = isCurrentlyActive
        ? 'هل أنت متأكد من رغبتك في تجميد عضوية "$memberName"؟ لن يتمكن من الوصول أو تنفيذ أي عمليات حتى يُعاد تنشيطه.'
        : 'هل أنت متأكد من رغبتك في إعادة تفعيل عضوية "$memberName" واستعادة صلاحياته التشغيلية؟';

    if (isCurrentlyActive) {
      final confirmed = await CustomDialog.showWarning(
        title: title,
        message: message,
        confirmLabel: actionText,
        cancelLabel: 'تراجع',
      );
      if (confirmed == true) {
        await onConfirm();
      }
    } else {
      final confirmed = await CustomDialog.showConfirmation(
        title: title,
        message: message,
        confirmLabel: actionText,
        cancelLabel: 'تراجع',
      );
      if (confirmed == true) {
        await onConfirm();
      }
    }
  }

  /// نافذة تأكيد حذف أو استبعاد العضو من المنشأة
  static Future<void> showRemoveMemberDialog({
    required String memberName,
    required Future<void> Function() onConfirm,
  }) async {
    final confirmed = await CustomDialog.showDanger(
      title: 'استبعاد العضو نهائياً',
      message:
          'هل أنت متأكد من رغبتك في حذف "$memberName" من فريق العمل؟ سيتم إلغاء كافة صلاحيات الوصول المرتبطة بهذه المنشأة.',
      confirmLabel: 'تأكيد الحذف',
      cancelLabel: 'إلغاء',
    );

    if (confirmed == true) {
      await onConfirm();
    }
  }
}
