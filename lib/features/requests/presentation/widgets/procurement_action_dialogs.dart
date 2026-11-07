import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// نوافذ الحوار التفاعلية لقرارات اعتماد، رفض، وإلغاء طلبات التوريد
class ProcurementActionDialogs {
  ProcurementActionDialogs._();

  /// نافذة حوار اعتماد طلب التوريد مع ملاحظة اختيارية
  static Future<void> showApprovalDialog({
    required int requestId,
    required Future<void> Function(String? note) onConfirm,
  }) async {
    final noteController = TextEditingController();

    await CustomDialog.show(
      type: DialogType.confirmation,
      title: 'اعتماد طلب التوريد #$requestId',
      message:
          'سيتم احتساب وتوليد فاتورة المبيعات آلياً عبر الخادم وتسوية الرصيد المالي.',
      confirmLabel: 'تأكيد الاعتماد',
      cancelLabel: 'تراجع',
      content: Padding(
        padding: EdgeInsets.only(top: AppSpacing.sm),
        child: CustomTextField(
          controller: noteController,
          label: 'ملاحظات الاعتماد (اختياري)',
          hint: 'أضف أي ملاحظات للوكيل بخصوص الفاتورة...',
          maxLines: 2,
          isRequired: false,
        ),
      ),
      onConfirm: () async {
        Get.back<void>();
        final note = noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim();
        await onConfirm(note);
      },
    );
  }

  /// نافذة حوار رفض طلب التوريد مع بيان السبب الإلزامي
  static Future<void> showRejectionDialog({
    required int requestId,
    required Future<void> Function(String reason) onConfirm,
  }) async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await CustomDialog.show(
      type: DialogType.custom,
      title: 'رفض طلب التوريد #$requestId',
      message: 'يرجى كتابة سبب الرفض المعتمد لتوثيقه في السجل وإشعار الوكيل.',
      confirmLabel: 'تأكيد الرفض',
      cancelLabel: 'إلغاء',
      content: Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.only(top: AppSpacing.sm),
          child: CustomTextField(
            controller: reasonController,
            label: 'سبب الرفض الإلزامي',
            hint: 'مثال: الرصيد الائتماني غير كافٍ أو الكمية غير متوفرة...',
            maxLines: 3,
            isRequired: true,
            validator: (val) {
              if (val == null || val.trim().length < 3) {
                return 'سبب الرفض يجب ألا يقل عن 3 أحرف';
              }
              return null;
            },
          ),
        ),
      ),
      onConfirm: () async {
        if (!formKey.currentState!.validate()) return;
        Get.back<void>();
        await onConfirm(reasonController.text.trim());
      },
    );
  }

  /// نافذة حوار إلغاء طلب التوريد من قبل نقطة البيع
  static Future<void> showCancelDialog({
    required int requestId,
    required Future<void> Function() onConfirm,
  }) async {
    await CustomDialog.show(
      type: DialogType.warning,
      title: 'إلغاء طلب التوريد #$requestId',
      message:
          'هل أنت متأكد من رغبتك في إلغاء هذا الطلب قبل مراجعته من الشبكة؟',
      confirmLabel: 'نعم، إلغاء الطلب',
      cancelLabel: 'تراجع',
      onConfirm: () async {
        Get.back<void>();
        await onConfirm();
      },
    );
  }
}
