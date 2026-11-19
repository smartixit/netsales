import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_card/invoice_card_accordion.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_card/invoice_card_actions.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_card/invoice_card_header.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_card/invoice_card_metrics_bar.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// بطاقة الفاتورة المالية المتطورة بنظام الأكورديون الأنيق (Invoice Card - Executive Edition)
///
/// تجسد المعمارية الموحدة للفواتير في مساحة نقطة البيع ومساحة شبكة التزويد:
/// - حواف 24.r، ظلال مزدوجة بمسحة زمردية وحماية تامة ضد التجاوز.
/// - ترويسة بهوية الفاتورة وشعار واسم الطرف التجاري الآخر مع زر النسخ وشارة الحالة ونوع البيع.
/// - سكة قياسات موحدة للمبالغ والكميات ونسبة السداد مع شريط تقدم ملون.
/// - أكورديون تفاعلي يعرض الباقات والكميات الموحدة.
/// - خلو كامل من المنطق، دوال المساعدة، أو خيارات السداد الملغاة.
class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.onTap,
    this.isExpanded = false,
    this.onToggleExpansion,
    this.isNetworkView = true,
    this.onPrint,
    this.onRequestTap,
  });

  final InvoiceEntity invoice;
  final VoidCallback onTap;
  final bool isExpanded;
  final VoidCallback? onToggleExpansion;
  final bool isNetworkView;
  final VoidCallback? onPrint;
  final VoidCallback? onRequestTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final paymentPresentation =
        EnumPresentationRegistry.resolveInvoicePaymentStatus(
          invoice.paymentStatus,
          serverLabel: invoice.paymentStatusLabel,
        );

    final saleTypePresentation = EnumPresentationRegistry.resolveSaleType(
      invoice.saleType,
      serverLabel: invoice.saleTypeLabel,
    );

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: colors.primary.withValues(alpha: .15),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.emeraldDeep.withValues(alpha: .065),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: .025),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. ترويسة هوية الفاتورة والطرف المقابل وشارات الحالة
            InvoiceCardHeader(
              invoice: invoice,
              paymentPresentation: paymentPresentation,
              saleTypePresentation: saleTypePresentation,
              isNetworkView: isNetworkView,
              onRequestTap: onRequestTap,
            ),

            // 2. المحتوى الداخلي للبطاقة
            Padding(
              padding: EdgeInsets.fromLTRB(14.r, 12.r, 14.r, 14.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // لوحة الباقات المضمنة بنظام الأكورديون الأنيق
                  InvoiceCardAccordion(
                    invoice: invoice,
                    isExpanded: isExpanded,
                    onToggle: onToggleExpansion,
                  ),
                  AppSpacing.vSm,

                  // سكة القياسات المالية ونسبة السداد
                  InvoiceCardMetricsBar(invoice: invoice),
                  AppSpacing.vSm,

                  // شريط الإجراءات السريعة
                  InvoiceCardActions(
                    onTap: onTap,
                    onPrint: onPrint,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
