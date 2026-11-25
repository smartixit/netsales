import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_partner_card_network_actions.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_partner_card_pos_actions.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// شريط أزرار الإجراءات التفاعلية لبطاقة الشريك التجاري (Partner Card Actions Bar)
///
/// يتبع المعمارية الموحدة المعتمدة في [ProcurementOrderCardActions]:
/// يتكيف تلقائياً مع سياق مساحة العمل (شبكة التوزيع أو نقطة البيع):
/// - مساحة الشبكة (Network): استعراض ملف نقطة البيع، تجميد/تنشيط الارتباط، فك الارتباط.
/// - مساحة نقطة البيع (POS): استعراض ملف مزود الشبكة، فك الارتباط.
class CommercialPartnerCardActions extends StatelessWidget {
  const CommercialPartnerCardActions({
    super.key,
    required this.link,
    required this.onViewDetails,
    this.onToggleStatus,
    this.onDelete,
    this.onViewWallet,
    this.isNetworkView = true,
  });

  final NetworkPosLinkEntity link;
  final VoidCallback onViewDetails;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;
  final VoidCallback? onViewWallet;
  final bool isNetworkView;

  Future<void> _showMoreActions() async {
    final partnerName = isNetworkView
        ? link.displayPosName
        : link.displayNetworkName;

    final actions = <CustomBottomSheetActionItem>[
      CustomBottomSheetActionItem(
        title: isNetworkView
            ? 'عرض ملف نقطة البيع المعتمد'
            : 'عرض ملف مزود الشبكة المعتمد',
        icon: isNetworkView ? Icons.storefront_outlined : Icons.hub_outlined,
        onTap: onViewDetails,
      ),
      if (isNetworkView) ...[
        if (onViewWallet != null)
          CustomBottomSheetActionItem(
            title: 'دفتر أستاذ المحفظة',
            subtitle: 'عرض الحركات المالية والعمليات لنقطة البيع',
            icon: Icons.account_balance_wallet_outlined,
            onTap: onViewWallet!,
          ),
        if (onToggleStatus != null)
          CustomBottomSheetActionItem(
            title: link.isActive
                ? 'تجميد الارتباط التجاري'
                : 'تنشيط الارتباط التجاري',
            icon: link.isActive
                ? Icons.pause_circle_outline_rounded
                : Icons.play_circle_outline_rounded,
            onTap: onToggleStatus!,
          ),
        if (onDelete != null)
          CustomBottomSheetActionItem(
            title: 'فك الارتباط التجاري',
            icon: Icons.link_off_rounded,
            isDestructive: true,
            onTap: onDelete!,
          ),
      ] else ...[
        if (onViewWallet != null)
          CustomBottomSheetActionItem(
            title: 'دفتر أستاذ المحفظة',
            subtitle: 'عرض الرصيد والحركات المالية ضمن هذه العلاقة',
            icon: Icons.account_balance_wallet_outlined,
            onTap: onViewWallet!,
          ),
        if (onDelete != null)
          CustomBottomSheetActionItem(
            title: 'فك الارتباط بمزود الشبكة',
            icon: Icons.link_off_rounded,
            isDestructive: true,
            onTap: onDelete!,
          ),
      ],
    ];

    await CustomBottomSheet.showActions<void>(
      title: 'إجراءات الشريك: $partnerName',
      leadingIcon: isNetworkView ? Icons.storefront_rounded : Icons.hub_rounded,
      items: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isNetworkView) {
      return CommercialPartnerCardNetworkActions(
        isActive: link.isActive,
        onViewDetails: onViewDetails,
        onToggleStatus: onToggleStatus,
        onDelete: onDelete,
        onMoreActions: _showMoreActions,
      );
    }

    return CommercialPartnerCardPosActions(
      onViewDetails: onViewDetails,
      onDelete: onDelete,
      onMoreActions: _showMoreActions,
    );
  }
}
