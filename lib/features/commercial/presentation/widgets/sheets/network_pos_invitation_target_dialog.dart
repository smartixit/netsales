import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// نافذة عرض فقط؛ الحالة والتحقق والطلبات تظل مملوكة لمتحكم مساحة العمل.
class NetworkPosInvitationTargetDialog extends StatelessWidget {
  const NetworkPosInvitationTargetDialog({
    super.key,
    required this.codeController,
    required this.isResolving,
    required this.onChanged,
    required this.onResolve,
    required this.onCancel,
  });

  final TextEditingController codeController;
  final RxBool isResolving;
  final ValueChanged<String> onChanged;
  final VoidCallback onResolve;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'أدخل المعرف التجاري الذي يظهر في ملف نقطة البيع. سيتم التحقق من الجهة قبل إنشاء الدعوة.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Obx(
            () => CustomTextField(
              controller: codeController,
              label: 'المعرف التجاري لنقطة البيع',
              hint: 'POS-YYMM-00001-AB12',
              prefixIcon: const Icon(Icons.storefront_rounded),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              enabled: !isResolving.value,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
                LengthLimitingTextInputFormatter(19),
              ],
              onChanged: onChanged,
              onFieldSubmitted: (_) => onResolve(),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'لا يتم عرض دليل عام لنقاط البيع. لن تظهر التفاصيل إلا بعد مطابقة المعرف والتحقق من أهلية الربط.',
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Obx(() {
            final resolving = isResolving.value;
            return Row(
              children: [
                Expanded(
                  child: CustomButton.outline(
                    text: 'إلغاء',
                    onPressed: resolving ? null : onCancel,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: CustomButton.primary(
                    text: 'التحقق والمتابعة',
                    icon: Icons.verified_user_rounded,
                    loading: resolving,
                    enabled: !resolving,
                    onPressed: resolving ? null : onResolve,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
