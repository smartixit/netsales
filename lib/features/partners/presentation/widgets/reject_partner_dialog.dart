import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/partners/presentation/controllers/partners_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// ============================================================================
/// نافذة تسجيل سبب رفض الشريك (RejectPartnerDialog)
/// ============================================================================
/// نافذة منبثقة معيارية تعتمد [CustomDialog] لإدخال سبب رفض طلب الشبكة أو نقطة البيع.
class RejectPartnerDialog extends StatefulWidget {
  final bool isNetwork;
  final int id;
  final String name;
  final PartnersController controller;

  const RejectPartnerDialog({
    super.key,
    required this.isNetwork,
    required this.id,
    required this.name,
    required this.controller,
  });

  static Future<void> show(
    BuildContext context, {
    required bool isNetwork,
    required int id,
    required String name,
    required PartnersController controller,
  }) {
    return Get.generalDialog<void>(
      barrierDismissible: true,
      barrierLabel: 'إغلاق',
      pageBuilder: (context, anim1, anim2) {
        return RejectPartnerDialog(
          isNetwork: isNetwork,
          id: id,
          name: name,
          controller: controller,
        );
      },
    );
  }

  @override
  State<RejectPartnerDialog> createState() => _RejectPartnerDialogState();
}

class _RejectPartnerDialogState extends State<RejectPartnerDialog> {
  final TextEditingController _reasonController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (_formKey.currentState?.validate() ?? false) {
      final reason = _reasonController.text.trim();
      Get.back();
      widget.controller.executeReject(
        isNetwork: widget.isNetwork,
        id: widget.id,
        name: widget.name,
        reason: reason,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final partnerType = widget.isNetwork ? 'مزود الشبكة' : 'نقطة البيع';

    return Center(
      child: Material(
        color: Colors.transparent,
        child: CustomDialog(
          type: DialogType.danger,
          title: 'رفض طلب $partnerType',
          message: 'يرجى توضيح سبب رفض طلب "${widget.name}"، حيث سيتم إرساله في إشعار رسمي لصاحب الطلب.',
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.vSm,
                CustomTextField(
                  controller: _reasonController,
                  label: 'سبب الرفض الإلزامي',
                  hint: 'اكتب سبب الرفض بالتفصيل (مثل: البيانات غير مطابقة للسجل التجاري)...',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى كتابة سبب الرفض';
                    }
                    if (value.trim().length < 5) {
                      return 'يجب أن يكون سبب الرفض 5 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                AppSpacing.vMd,
                Row(
                  children: [
                    Expanded(
                      child: CustomButton.danger(
                        text: 'تأكيد الرفض',
                        onPressed: _onConfirm,
                        height: 44.h,
                      ),
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: CustomButton.outline(
                        text: 'تراجع',
                        onPressed: () => Get.back(),
                        height: 44.h,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
