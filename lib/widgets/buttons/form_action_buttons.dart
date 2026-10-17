import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/widgets/buttons/custom_app_button.dart';
import 'package:netsales/widgets/buttons/custom_app_primary_button.dart';
import 'package:netsales/widgets/buttons/custom_app_secondary_button.dart';

/// صفّ أزرار الحفظ الثلاثة في شاشات النماذج:
/// «حفظ وإضافة» و«حفظ وطباعة» و«حفظ وإغلاق».
class FormActionButtons extends StatelessWidget {
  const FormActionButtons({
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
    // final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomAppSecondaryButton(
                size: AppButtonSize.medium,
                text: 'حفظ وإضافة',
                icon: Icons.playlist_add_rounded,
                onPressed: onSaveAndAdd,
                loading: loading,
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              child: CustomAppSecondaryButton(
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
        CustomAppPrimaryButton(
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
