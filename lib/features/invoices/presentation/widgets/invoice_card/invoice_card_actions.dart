import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// شريط أزرار الإجراءات السريعة لبطاقة الفاتورة
class InvoiceCardActions extends StatelessWidget {
  const InvoiceCardActions({
    super.key,
    required this.onTap,
    this.onPrint,
  });

  final VoidCallback onTap;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onPrint != null) ...[
          CustomButton.outline(
            text: 'طباعة',
            size: AppButtonSize.small,
            icon: Icons.print_outlined,
            onPressed: onPrint,
          ),
          AppSpacing.hSm,
        ],
        CustomButton.outline(
          text: 'تفاصيل كاملة',
          size: AppButtonSize.small,
          icon: Icons.arrow_back_ios_new_rounded,
          onPressed: onTap,
        ),
      ],
    );
  }
}
