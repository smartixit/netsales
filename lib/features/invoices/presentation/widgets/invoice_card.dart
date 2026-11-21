import 'package:flutter/material.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_card_actions.dart';
import 'package:netsales/widgets/cards/custom_executive_transaction_card.dart';

/// بطاقة الفاتورة المتطورة بنظام الأكورديون الأنيق (Invoice Card - Executive Edition)
///
/// تجسد المعمارية الموحدة للفواتير عبر استهلاك المكون القيادي الموحد [CustomExecutiveTransactionCard]:
/// حواف 24.r، ظلال مزدوجة بمسحة زمردية، شريط ترويسة بهوية الفاتورة وشعار واسم الطرف الآخر
/// مع معرّف الـ UUID كاملاً، شريط شارات أفقي مقاوم للتجاوز، أكورديون تفاعلي أنيق للبنود،
/// وسكة قياس مالية ثلاثية المبالغ (الإجمالي، المدفوع، المتبقي)، وأزرار إجراءات ذكية.
class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.onDetails,
    this.isNetworkPerspective = false,
    this.isExpanded = false,
    this.onToggleExpand,
    this.onLinkedRequestTap,
    this.onPrint,
    this.onShare,
    this.actions,
  });

  final InvoiceEntity invoice;
  final VoidCallback onDetails;
  final bool isNetworkPerspective;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;
  final VoidCallback? onLinkedRequestTap;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final status = EnumPresentationRegistry.resolveInvoicePaymentStatus(
      invoice.paymentStatus,
      serverLabel: invoice.paymentStatusLabel,
    );
    final saleType = EnumPresentationRegistry.resolveSaleType(
      invoice.saleType,
      serverLabel: invoice.saleTypeLabel,
    );

    // final actorLabel =
    //     invoice.createdByName != null &&
    //         invoice.createdByName!.trim().isNotEmpty
    //     ? 'أُصدرت بواسطة: ${invoice.createdByName}'
    //     : null;

    return CustomExecutiveTransactionCard(
      reference: invoice.displayReference,
      dateLabel: invoice.formattedInvoiceDate,
      partyName: isNetworkPerspective
          ? invoice.displayPosName
          : invoice.displayNetworkName,
      partyLogoUrl: isNetworkPerspective
          ? invoice.posLogo
          : invoice.networkLogo,
      // partyPhone: isNetworkPerspective
      //     ? invoice.posPhoneNumber
      //     : invoice.networkPhoneNumber,
      isPartyVerified: false,
      // actorLabel: actorLabel,
      statusPresentation: status,
      typePresentation: saleType,
      secondaryReference: invoice.hasLinkedRequest
          ? 'طلب #${invoice.requestId}'
          : null,
      onSecondaryReferenceTap: onLinkedRequestTap,
      items: invoice.items
          .map(
            (item) => ExecutiveCardItemData(
              title: item.packageName,
              subtitle:
                  '${item.voucherCount} كرت (${item.formattedSheetsCount} ورقة)',
              colorHex: item.packageColor,
              totalAmount: item.itemTotalAmount,
              discountAmount: item.itemDiscount,
            ),
          )
          .toList(),
      itemsHeaderTitle: 'الباقات والكميات (${invoice.items.length})',
      visibleItemNames: invoice.items.map((item) => item.packageName).toList(),
      metrics: [
        ExecutiveCardMetricData(
          label: 'إجمالي الفاتورة',
          value: AmountFormatter.formatValue(invoice.invoiceTotalAmount),
        ),
        ExecutiveCardMetricData(
          label: 'المدفوع',
          value: AmountFormatter.formatValue(invoice.paidAmount),
          textColor: colors.primary,
        ),
        ExecutiveCardMetricData(
          label: 'المتبقي',
          value: AmountFormatter.formatValue(invoice.remainingAmount),
          isEmphasized: invoice.remainingAmount > 0,
          textColor: invoice.remainingAmount > 0
              ? colors.error
              : colors.onSurfaceVariant,
        ),
      ],
      actions:
          actions ??
          InvoiceCardActions(
            invoice: invoice,
            isNetworkPerspective: isNetworkPerspective,
            onDetails: onDetails,
            onPrint: onPrint,
            onShare: onShare,
          ),
      isExpanded: isExpanded,
      onToggleExpand: onToggleExpand,
      onTap: onDetails,
    );
  }
}
