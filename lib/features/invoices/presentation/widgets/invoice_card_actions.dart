import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// شريط أزرار الإجراءات التفاعلية لبطاقة الفاتورة (Invoice Card Actions)
class InvoiceCardActions extends StatelessWidget {
  const InvoiceCardActions({
    super.key,
    required this.invoice,
    required this.onDetails,
    this.isNetworkPerspective = false,
    this.onPrint,
    this.onShare,
  });

  final InvoiceEntity invoice;
  final VoidCallback onDetails;
  final bool isNetworkPerspective;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        // زر التفاصيل الرئيسي
        Expanded(
          child: CustomButton.secondary(
            text: 'تفاصيل الفاتورة',
            icon: Icons.receipt_long_rounded,
            size: AppButtonSize.small,
            shape: AppButtonShape.pill,
            onPressed: onDetails,
          ),
        ),

        // زر الطباعة السريعة الموحد
        if (onPrint != null) ...[
          const SizedBox(width: 8),
          CustomButton.icon(
            icon: Icons.print_outlined,
            size: AppButtonSize.small,
            shape: AppButtonShape.circle,
            backgroundColor: colors.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            foregroundColor: colors.onSurfaceVariant,
            tooltip: 'طباعة الفاتورة',
            onPressed: onPrint,
          ),
        ],

        // زر المشاركة السريعة الموحد
        if (onShare != null) ...[
          const SizedBox(width: 6),
          CustomButton.icon(
            icon: Icons.share_outlined,
            size: AppButtonSize.small,
            shape: AppButtonShape.circle,
            backgroundColor: colors.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            foregroundColor: colors.onSurfaceVariant,
            tooltip: 'مشاركة الفاتورة',
            onPressed: onShare,
          ),
        ],
      ],
    );
  }
}
