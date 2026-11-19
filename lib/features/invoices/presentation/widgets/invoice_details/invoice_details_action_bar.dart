import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/invoices/presentation/controllers/invoice_details_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// شريط الإجراءات والعمليات المستندية الثابت أسفل شاشة تفاصيل الفاتورة
class InvoiceDetailsActionBar extends StatelessWidget {
  const InvoiceDetailsActionBar({super.key, required this.controller});

  final InvoiceDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant.withValues(alpha: .35),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // زر التصدير كـ PDF الرئيسي
            Expanded(
              child: CustomButton.primary(
                text: 'تصدير PDF',
                icon: Icons.picture_as_pdf_outlined,
                onPressed: controller.exportPdf,
              ),
            ),
            AppSpacing.hSm,

            // زر الطباعة
            CustomButton.outline(
              text: 'طباعة',
              icon: Icons.print_outlined,
              onPressed: controller.printInvoice,
            ),
            AppSpacing.hSm,

            // زر المشاركة
            CustomButton.outline(
              text: 'مشاركة',
              icon: Icons.share_outlined,
              onPressed: controller.shareInvoice,
            ),
          ],
        ),
      ),
    );
  }
}
