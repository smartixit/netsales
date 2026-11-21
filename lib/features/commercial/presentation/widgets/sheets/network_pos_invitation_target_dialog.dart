import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// Resolves a single POS by its business identifier; it never lists POS records.
class NetworkPosInvitationTargetDialog extends StatefulWidget {
  const NetworkPosInvitationTargetDialog({
    super.key,
    required this.onResolve,
  });

  final Future<PosEntity> Function(String businessCode) onResolve;

  @override
  State<NetworkPosInvitationTargetDialog> createState() =>
      _NetworkPosInvitationTargetDialogState();
}

class _NetworkPosInvitationTargetDialogState
    extends State<NetworkPosInvitationTargetDialog> {
  final TextEditingController _codeController = TextEditingController();
  bool _isResolving = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _resolveTarget() async {
    final code = _codeController.text.trim().toUpperCase();
    if (!RegExp(r'^POS-\d{4}-\d{5}-[A-F0-9]{4}$').hasMatch(code)) {
      CustomSnackbar.show(
        title: 'تحقق من المعرف',
        message: 'أدخل المعرف التجاري لنقطة البيع بالصيغة الموجودة في ملفها.',
        type: SnackType.warning,
      );
      return;
    }

    setState(() => _isResolving = true);
    try {
      final pos = await widget.onResolve(code);
      if (!mounted) return;
      Get.back<PosEntity>(result: pos);
    } catch (error) {
      if (!mounted) return;
      CustomSnackbar.show(
        title: 'لم يتم العثور على جهة مؤهلة',
        message: AppException.sanitizeMessage(error.toString()),
        type: SnackType.error,
      );
    } finally {
      if (mounted) setState(() => _isResolving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AlertDialog(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        'تحديد نقطة البيع المستهدفة',
        style: AppTypography.titleMedium.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      content: SizedBox(
        width: 440,
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
            CustomTextField(
              controller: _codeController,
              label: 'المعرف التجاري لنقطة البيع',
              hint: 'POS-YYMM-00001-AB12',
              prefixIcon: const Icon(Icons.storefront_rounded),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
                LengthLimitingTextInputFormatter(19),
              ],
              onFieldSubmitted: (_) => _resolveTarget(),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'لا يتم عرض دليل عام لنقاط البيع. لن تظهر التفاصيل إلا بعد مطابقة المعرف والتحقق من أهلية الربط.',
              style: AppTypography.labelSmall.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
      actions: [
        CustomButton.text(
          text: 'إلغاء',
          onPressed: _isResolving ? null : () => Get.back<void>(),
        ),
        CustomButton.primary(
          text: 'التحقق والمتابعة',
          icon: Icons.verified_user_rounded,
          loading: _isResolving,
          onPressed: _isResolving ? null : _resolveTarget,
        ),
      ],
    );
  }
}
