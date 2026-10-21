import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/dialogs/widgets/dialog_icon_header.dart';

/// شريط أزرار وإجراءات الحوار (DialogActionBar)
///
/// يدعم أزرار التأكيد والإلغاء الموحدة عبر فئات CustomButton السبع
/// دون أي استخدام لأزرار فلاتر الخام نهائياً.
class DialogActionBar extends StatelessWidget {
  final DialogType type;
  final String? confirmLabel;
  final String? cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const DialogActionBar({
    super.key,
    required this.type,
    this.confirmLabel,
    this.cancelLabel,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final hasConfirm = confirmLabel != null;
    final hasCancel = cancelLabel != null ||
        (!hasConfirm &&
            (type == DialogType.success ||
                type == DialogType.info ||
                type == DialogType.pending));

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. زر التأكيد الرئيسي أو التدميري
          if (hasConfirm)
            type == DialogType.danger
                ? CustomButton.danger(
                    text: confirmLabel,
                    width: double.infinity,
                    onPressed: () {
                      Get.back(result: true);
                      onConfirm?.call();
                    },
                  )
                : CustomButton.primary(
                    text: confirmLabel,
                    width: double.infinity,
                    onPressed: () {
                      Get.back(result: true);
                      onConfirm?.call();
                    },
                  ),

          if (hasConfirm && hasCancel) AppSpacing.vSm,

          // 2. زر الإلغاء أو التأكيد الثانوي الخفيف
          if (hasCancel)
            CustomButton.text(
              text: cancelLabel ??
                  (type == DialogType.success ||
                          type == DialogType.info ||
                          type == DialogType.pending
                      ? 'حسناً'
                      : 'إلغاء'),
              width: double.infinity,
              onPressed: () {
                Get.back(result: false);
                onCancel?.call();
              },
            ),
        ],
      ),
    );
  }
}
