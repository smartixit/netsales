import 'package:flutter/material.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card_actions.dart';
import 'package:netsales/widgets/cards/custom_executive_transaction_card.dart';

/// بطاقة طلب التوريد المتطورة بنظام الأكورديون الأنيق (Procurement Order Card - Executive Edition)
///
/// تجسد المعمارية الموحدة لطلبات التوريد في مساحة نقطة البيع ومساحة شبكة التوزيع
/// عبر استهلاك المكون القيادي الموحد [CustomExecutiveTransactionCard]:
/// حواف 24.r، ظلال مزدوجة بمسحة زمردية، شريط ترويسة بهوية الطلب وشعار واسم الطرف الآخر
/// مع معرّف الـ UUID كاملاً، شريط شارات أفقي مقاوم للتجاوز، أكورديون تفاعلي أنيق،
/// وسكة قياس ثلاثية المبالغ محمية بـ FittedBox، وأزرار إجراءات ذكية بحسب سياق العمل.
class ProcurementOrderCard extends StatelessWidget {
  const ProcurementOrderCard({
    super.key,
    required this.request,
    required this.onDetails,
    this.isNetworkView = false,
    this.isExpanded = false,
    this.onToggleExpand,
    this.onEdit,
    this.onCancel,
    this.onDelete,
    this.onApprove,
    this.onModify,
    this.onReject,
    this.onInvoiceTap,
    this.actions,
  });

  final RequestEntity request;
  final VoidCallback onDetails;
  final bool isNetworkView;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final VoidCallback? onApprove;
  final VoidCallback? onModify;
  final VoidCallback? onReject;
  final VoidCallback? onInvoiceTap;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final status = EnumPresentationRegistry.resolveRequestStatus(
      request.status,
      serverLabel: request.statusLabel,
    );
    final saleType = EnumPresentationRegistry.resolveSaleType(
      request.saleType,
      serverLabel: request.saleTypeLabel,
    );

    // final actorLabel =
    //     request.isApproved &&
    //         request.reviewedByName != null &&
    //         request.reviewedByName!.isNotEmpty
    //     ? 'اعتمد بواسطة: ${request.reviewedByName}'
    //     : (request.isRejected &&
    //               request.reviewedByName != null &&
    //               request.reviewedByName!.isNotEmpty
    //           ? 'رُفض بواسطة: ${request.reviewedByName}'
    //           : null);

    return CustomExecutiveTransactionCard(
      reference: request.displayReference,
      dateLabel: request.formattedRequestDate,
      partyName: isNetworkView
          ? request.displayPosName
          : request.displayNetworkName,
      partyLogoUrl: isNetworkView ? request.posLogo : request.networkLogo,
      // partyPhone: isNetworkView ? request.posPhone : request.networkPhone,
      isPartyVerified: false,
      // actorLabel: actorLabel,
      statusPresentation: status,
      typePresentation: saleType,
      secondaryReference: request.hasInvoice
          ? 'فاتورة #${request.invoiceId}'
          : null,
      onSecondaryReferenceTap: onInvoiceTap,
      items: request.items
          .map(
            (item) => ExecutiveCardItemData(
              title: item.packageName,
              subtitle:
                  '${item.voucherCount} كرت (${item.formattedSheetsCount} ورقة)',
              colorHex: item.voucherPackage?.packageColor,
              totalAmount: item.itemTotalAmount,
              discountAmount: item.itemDiscount,
            ),
          )
          .toList(),
      itemsHeaderTitle: 'الباقات والكميات (${request.items.length})',
      visibleItemNames: request.items.map((item) => item.packageName).toList(),
      metrics: [
        ExecutiveCardMetricData(
          label: 'الباقات',
          value: '${request.items.length}',
        ),
        ExecutiveCardMetricData(
          label: 'عدد الكروت',
          value: '${request.totalVouchers} كرت',
        ),
        ExecutiveCardMetricData(
          label: 'إجمالي الطلب',
          value: AmountFormatter.formatValue(request.requestTotalAmount),
          isEmphasized: true,
          textColor: colors.primary,
        ),
      ],
      actions:
          actions ??
          ProcurementOrderCardActions(
            request: request,
            onDetails: onDetails,
            isNetworkView: isNetworkView,
            onEdit: onEdit,
            onCancel: onCancel,
            onDelete: onDelete,
            onApprove: onApprove,
            onModify: onModify,
            onReject: onReject,
          ),
      onTap: onDetails,
      isExpanded: isExpanded,
      onToggleExpand: onToggleExpand,
    );
  }
}
