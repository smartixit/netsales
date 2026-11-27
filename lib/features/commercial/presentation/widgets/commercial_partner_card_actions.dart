import 'package:flutter/material.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_partner_action_bar.dart';

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
    this.onViewLifecycle,
    required this.onMoreActions,
    this.isNetworkView = true,
  });

  final NetworkPosLinkEntity link;
  final VoidCallback onViewDetails;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;
  final VoidCallback? onViewWallet;
  final VoidCallback? onViewLifecycle;
  final VoidCallback onMoreActions;
  final bool isNetworkView;

  @override
  Widget build(BuildContext context) {
    return CommercialPartnerActionBar(
      isNetworkView: isNetworkView,
      isActive: link.isActive,
      onViewDetails: onViewDetails,
      onToggleStatus: onToggleStatus,
      onDelete: onDelete,
      onMoreActions: onMoreActions,
    );
  }
}
