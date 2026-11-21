import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// نوافذ الحوار التفاعلية لقرارات إدارة وتعديل عضويات مساحات العمل
class MembershipActionDialogs {
  MembershipActionDialogs._();

  /// نافذة حوار تأكيد تعديل حالة تفعيل العضو (تجميد / إعادة تنشيط)
  static Future<void> showToggleStatusDialog({
    required String memberName,
    required bool willSuspend,
    required Future<void> Function(String? reason) onConfirm,
  }) async {
    final reasonController = TextEditingController();

    await CustomDialog.show(
      type: willSuspend ? DialogType.warning : DialogType.confirmation,
      title: willSuspend ? 'إيقاف عضوية $memberName' : 'إعادة تفعيل عضوية $memberName',
      message: willSuspend
          ? 'سيتم إيقاف صلاحيات هذا العضو مؤقتاً ومنعه من الوصول إلى مساحة العمل.'
          : 'سيتم إعادة تفعيل صلاحيات العضو والسماح له بالوصول إلى مساحة العمل مجدداً.',
      confirmLabel: willSuspend ? 'تأكيد الإيقاف' : 'تأكيد التفعيل',
      cancelLabel: 'تراجع',
      content: Padding(
        padding: EdgeInsets.only(top: AppSpacing.sm),
        child: CustomTextField(
          controller: reasonController,
          label: 'سبب التعديل (اختياري)',
          hint: 'أدخل ملاحظة أو سبب التعديل لتوثيقها في سجل التدقيق...',
          maxLines: 2,
          isRequired: false,
          validator: FormValidators.descriptionValidator(isRequired: false),
        ),
      ),
      onConfirm: () async {
        final reason = reasonController.text.trim().isEmpty
            ? null
            : reasonController.text.trim();
        await onConfirm(reason);
      },
    );
  }

  /// نافذة حوار تأكيد إنهاء وإزالة عضوية المستخدم
  static Future<void> showRemoveMemberDialog({
    required String memberName,
    required Future<void> Function(String? reason) onConfirm,
  }) async {
    final reasonController = TextEditingController();

    await CustomDialog.show(
      type: DialogType.error,
      title: 'إنهاء عضوية $memberName',
      message:
          'هل أنت متأكد من إنهاء عضوية "$memberName" نهائياً؟\nسيتم سحب كافة الصلاحيات وإزالة حسابه من قائمة العاملين بمساحة العمل.',
      confirmLabel: 'تأكيد إنهاء العضوية',
      cancelLabel: 'إلغاء',
      content: Padding(
        padding: EdgeInsets.only(top: AppSpacing.sm),
        child: CustomTextField(
          controller: reasonController,
          label: 'سبب الإنهاء (اختياري)',
          hint: 'أدخل سبب إنهاء العضوية لتوثيقه في السجل الأمني...',
          maxLines: 2,
          isRequired: false,
          validator: FormValidators.descriptionValidator(isRequired: false),
        ),
      ),
      onConfirm: () async {
        final reason = reasonController.text.trim().isEmpty
            ? null
            : reasonController.text.trim();
        await onConfirm(reason);
      },
    );
  }
}
