import 'package:flutter/material.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_partner_card_actions.dart';
import 'package:netsales/widgets/cards/custom_executive_transaction_card.dart';

/// بطاقة الشريك التجاري المتطورة بنظام الأكورديون التنفيذي (Commercial Partner Card - Executive Edition)
///
/// تجسد المعمارية الموحدة لبطاقات النظام المعتمدة في [ProcurementOrderCard] و[InvoiceCard]
/// عبر استهلاك المكون القيادي الموحد [CustomExecutiveTransactionCard]:
/// - حواف فاخرة 24.r وظلال مزدوجة بمسحة زمردية.
/// - ترويسة بهوية الشريك وشعاره الرسمي، الهاتف، وشارات الحالة والنوع المعتمدة عبر [EnumPresentationRegistry].
/// - سكة قياسات ثلاثية محمية بـ FittedBox (الموقع الجغرافي، المسؤول، حالة الارتباط).
/// - أزرار إجراءات ذكية تتكيف مع مساحة العمل (شبكة التوزيع أو نقطة البيع).
/// - النقر المباشر على الكرت يوجه تلقائياً إلى دفتر أستاذ محفظة نقطة البيع في سياق مساحة عمل الشبكة.
class CommercialPartnerCard extends StatelessWidget {
  const CommercialPartnerCard({
    super.key,
    required this.link,
    required this.onDetails,
    required this.onTap,
    this.isNetworkView = true,
    this.isExpanded = false,
    this.onToggleExpand,
    this.onToggleStatus,
    this.onDelete,
    this.onMoreActions,
    this.actions,
  });

  final NetworkPosLinkEntity link;
  final VoidCallback onDetails;
  final VoidCallback onTap;
  final bool isNetworkView;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;
  final VoidCallback? onMoreActions;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // تمثيل حالة الارتباط التجاري عبر المحرك المركزي الموحد
    final statusPres = EnumPresentationRegistry.resolveLinkStatus(
      link.isActive,
    );

    // تمثيل حالة الكيان الشريك (نقطة البيع أو الشبكة)
    final partnerTypePres = isNetworkView
        ? (link.pos != null
              ? EnumPresentationRegistry.resolvePosStatus(
                  link.pos!.typedStatus,
                  serverLabel: link.pos!.statusLabel,
                )
              : null)
        : (link.network != null
              ? EnumPresentationRegistry.resolveNetworkStatus(
                  link.network!.typedStatus,
                  serverLabel: link.network!.statusLabel,
                )
              : null);

    final reference = isNetworkView
        ? link.displayPosReference
        : link.displayNetworkReference;
    final partyName = isNetworkView
        ? link.displayPosName
        : link.displayNetworkName;
    final partyPhone = isNetworkView ? link.posPhone : link.networkPhone;
    final partyLogo = isNetworkView
        ? link.pos?.posProfileLogoUrl
        : link.network?.networkProfileLogoUrl;
    final actorLabel = isNetworkView ? 'نقطة بيع مرتبطة' : 'مزود شبكة معتمد';
    final location = isNetworkView ? link.posLocation : link.networkLocation;
    final owner = isNetworkView ? link.posOwnerName : link.networkOwnerName;

    return CustomExecutiveTransactionCard(
      reference: reference,
      dateLabel: link.formattedLinkedDate,
      partyName: partyName,
      partyLogoUrl: partyLogo,
      partyPhone: partyPhone,
      isPartyVerified: link.isActive,
      actorLabel: actorLabel,
      statusPresentation: statusPres,
      typePresentation: partnerTypePres,
      secondaryReference: 'ارتباط #${link.networkPosId}',
      items: const [],
      metrics: [
        ExecutiveCardMetricData(label: 'الموقع الجغرافي', value: location),
        ExecutiveCardMetricData(label: 'المسؤول المباشر', value: owner),
        ExecutiveCardMetricData(
          label: 'حالة الارتباط',
          value: statusPres.label,
          isEmphasized: true,
          textColor: link.isActive ? colors.primary : colors.onSurfaceVariant,
        ),
      ],
      actions:
          actions ??
          CommercialPartnerCardActions(
            link: link,
            isNetworkView: isNetworkView,
            onViewDetails: onDetails,
            onToggleStatus: onToggleStatus,
            onDelete: onDelete,
            onMoreActions: onMoreActions ?? onDetails,
          ),
      onTap: onTap,
      isExpanded: isExpanded,
      onToggleExpand: onToggleExpand,
    );
  }
}
