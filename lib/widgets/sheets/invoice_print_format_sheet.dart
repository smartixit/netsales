import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/invoice_receipt_pdf_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// ============================================================================
/// نافذة خيارات وتنسيق طباعة ومشاركة السند الرقمي (InvoicePrintFormatSheet)
/// ============================================================================
/// تطبق معايير الـ Twin Architecture: ودجت العرض البصري المرتبط بخدمة [InvoiceReceiptPdfService].
/// تتيح للمستخدم تحديد نمط الطباعة (إيصال حراري 80mm أو سند رسمي A4) مع خيارات الطباعة والمشاركة.
class InvoicePrintFormatSheet extends StatefulWidget {
  final SaleInvoiceEntity? invoice;
  final VoucherRequestEntity? request;

  const InvoicePrintFormatSheet({
    super.key,
    this.invoice,
    this.request,
  }) : assert(invoice != null || request != null, 'يجب تمرير فاتورة أو طلب توريد');

  /// الدالة المصنعية المركزية لفتح النافذة
  static Future<void> show(
    BuildContext context, {
    SaleInvoiceEntity? invoice,
    VoucherRequestEntity? request,
  }) {
    return CustomBottomSheet.show(
      title: invoice != null ? 'خيارات طباعة ومشاركة الفاتورة' : 'خيارات طباعة ومشاركة الطلب',
      subtitle: 'اختر نسق السند المناسب للطباعة الحرارية أو التصدير الرسمي',
      leadingIcon: Icon(
        Icons.print_outlined,
        color: context.colors.primary,
        size: 22.r,
      ),
      child: InvoicePrintFormatSheet(
        invoice: invoice,
        request: request,
      ),
    );
  }

  @override
  State<InvoicePrintFormatSheet> createState() => _InvoicePrintFormatSheetState();
}

class _InvoicePrintFormatSheetState extends State<InvoicePrintFormatSheet> {
  InvoicePrintFormat _selectedFormat = InvoicePrintFormat.thermal80;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. بطاقة خيار الطابعة الحرارية 80mm
        _FormatOptionCard(
          title: 'طابعة إيصالات حرارية (POS 80mm)',
          subtitle: 'تنسيق شريطي مضغوط مناسب لطابعات البلوتوث والمحمولة ونقاط التوزيع',
          icon: Icons.receipt_long_rounded,
          isSelected: _selectedFormat == InvoicePrintFormat.thermal80,
          onTap: () => setState(() => _selectedFormat = InvoicePrintFormat.thermal80),
        ),

        AppSpacing.vSm,

        // 2. بطاقة خيار السند المالي الرسمي A4
        _FormatOptionCard(
          title: 'سند رسمي مؤسسي (A4 قياسي)',
          subtitle: 'تنسيق متكامل بكامل التفاصيل والبيانات المالية مناسب للأرشفة ومشاركة الـ PDF',
          icon: Icons.description_outlined,
          isSelected: _selectedFormat == InvoicePrintFormat.standardA4,
          onTap: () => setState(() => _selectedFormat = InvoicePrintFormat.standardA4),
        ),

        AppSpacing.vLg,

        // 3. أزرار الإجراءات (طباعة فورية / مشاركة)
        Row(
          children: [
            Expanded(
              child: CustomButton.outline(
                text: 'مشاركة PDF',
                icon: Icons.share_rounded,
                loading: _isProcessing,
                onPressed: _handleShare,
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              child: CustomButton.primary(
                text: 'طباعة فورية',
                icon: Icons.print_rounded,
                loading: _isProcessing,
                onPressed: _handlePrint,
              ),
            ),
          ],
        ),

        AppSpacing.vSm,

        // 4. خيار حفظ المستند محلياً في مجلد التنزيلات
        CustomButton.text(
          text: 'حفظ نسخة في مجلد التنزيلات بالجهاز',
          icon: Icons.download_rounded,
          onPressed: _handleSave,
        ),

        AppSpacing.vSm,
      ],
    );
  }

  Future<void> _handlePrint() async {
    setState(() => _isProcessing = true);
    Get.back();

    try {
      if (widget.invoice != null) {
        await InvoiceReceiptPdfService.instance.printSaleInvoice(
          context,
          widget.invoice!,
          format: _selectedFormat,
        );
      } else if (widget.request != null) {
        await InvoiceReceiptPdfService.instance.printVoucherRequest(
          context,
          widget.request!,
          format: _selectedFormat,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleShare() async {
    setState(() => _isProcessing = true);
    Get.back();

    try {
      if (widget.invoice != null) {
        await InvoiceReceiptPdfService.instance.shareSaleInvoice(
          context,
          widget.invoice!,
          format: _selectedFormat,
        );
      } else if (widget.request != null) {
        await InvoiceReceiptPdfService.instance.shareVoucherRequest(
          context,
          widget.request!,
          format: _selectedFormat,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isProcessing = true);
    Get.back();

    try {
      if (widget.invoice != null) {
        await InvoiceReceiptPdfService.instance.saveSaleInvoiceLocally(
          context,
          widget.invoice!,
          format: _selectedFormat,
        );
      } else if (widget.request != null) {
        await InvoiceReceiptPdfService.instance.saveVoucherRequestLocally(
          context,
          widget.request!,
          format: _selectedFormat,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

/// بطاقة تفاعلية لاختيار نمط السند المالي
class _FormatOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final borderColor = isSelected ? colors.primary : colors.outlineVariant.withValues(alpha: 0.4);
    final bgColor = isSelected ? colors.primaryContainer.withValues(alpha: 0.25) : colors.surface;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.mdRadius,
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary.withValues(alpha: 0.12)
                    : colors.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? colors.primary : colors.onSurfaceVariant,
                size: 22.r,
              ),
            ),
            AppSpacing.hMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      color: isSelected ? colors.primary : colors.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  AppSpacing.vXxs,
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.hSm,
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? colors.primary : colors.outlineVariant,
              size: 22.r,
            ),
          ],
        ),
      ),
    );
  }
}
