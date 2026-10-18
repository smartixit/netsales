import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// طقم أزرار الحفظ الثلاثية في شاشات النماذج:
/// «حفظ وإضافة» و«حفظ وطباعة» و«حفظ وإغلاق».
class CustomFormActionButtons extends StatelessWidget {
  const CustomFormActionButtons({
    super.key,
    required this.onSaveAndAdd,
    required this.onSaveAndPrint,
    required this.onSaveAndClose,
    this.loading = false,
  });

  final VoidCallback onSaveAndAdd;
  final VoidCallback onSaveAndPrint;
  final VoidCallback onSaveAndClose;

  /// يمنع كل الأزرار ويُظهر مؤشر تحميل على زر «حفظ وطباعة».
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomButton.secondary(
                size: AppButtonSize.medium,
                text: 'حفظ وإضافة',
                icon: Icons.playlist_add_rounded,
                onPressed: onSaveAndAdd,
                loading: loading,
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              child: CustomButton.secondary(
                size: AppButtonSize.medium,
                text: 'حفظ وإغلاق',
                icon: Icons.save_rounded,
                onPressed: onSaveAndClose,
                loading: loading,
              ),
            ),
          ],
        ),
        AppSpacing.vMd,
        CustomButton.primary(
          text: 'حفظ وطباعة',
          icon: Icons.print_rounded,
          loading: loading,
          enabled: !loading,
          onPressed: onSaveAndPrint,
        ),
      ],
    );
  }
}
