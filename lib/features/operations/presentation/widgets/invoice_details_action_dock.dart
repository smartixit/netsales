import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/invoice_receipt_pdf_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/sheets/invoice_print_format_sheet.dart';

/// ============================================================================
/// رصيف الإجراءات والطباعة العائم لتفاصيل الفاتورة (InvoiceDetailsActionDock)
/// ============================================================================
/// يوفر وصولاً سريعاً ودائماً لطباعة ومشاركة السند الرقمي دون إرهاق المستخدم بالتمرير.
class InvoiceDetailsActionDock extends StatelessWidget {
  final SaleInvoiceEntity invoice;

  const InvoiceDetailsActionDock({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: 10.h,
      ),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.3),
            width: 0.8.w,
          ),
        ),
        boxShadow: AppElevation.level2(context),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: CustomButton.outline(
                text: 'طباعة السند',
                icon: Icons.print_outlined,
                onPressed: () => InvoicePrintFormatSheet.show(
                  context,
                  invoice: invoice,
                ),
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              flex: 1,
              child: CustomButton.primary(
                text: 'مشاركة PDF',
                icon: Icons.share_rounded,
                onPressed: () => InvoiceReceiptPdfService.instance.shareSaleInvoice(
                  context,
                  invoice,
                  format: InvoicePrintFormat.standardA4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
