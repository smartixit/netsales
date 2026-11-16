import 'package:flutter/material.dart';
import 'package:netsales/features/workspace/presentation/utils/workspace_carousel_theme.dart';
import 'package:netsales/features/workspace/presentation/models/network_provider_card_view_model.dart';
import 'package:netsales/widgets/carousels/custom_carousel_card.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';

/// مهايئ بطاقة الشبكة التنفيذية المربوط بالنموذج (ExecutiveNetworkCard)
/// يعرض نموذج بطاقة الشبكة المحوّل عبر مكوّن الكاروسيل المشترك CustomCarouselCard
class ExecutiveNetworkCard extends StatelessWidget {
  final NetworkProviderCardViewModel item;
  final bool isSelected;
  final int cardIndex;
  final VoidCallback onTap;

  const ExecutiveNetworkCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.cardIndex,
    
    
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {
    final logoWidget = CustomAvatarBadge(
      imageUrl: item.logoUrl,
      initials: item.networkName,
      size: AvatarBadgeSize.sm,
      hasPulse: false,
    );

    return CustomCarouselCard(
      title: item.networkName,
      subtitle: item.subtitle,
      logo: logoWidget,
      cardNumber: item.networkCode,
      primaryLabel: 'إجمالي المبيعات المحصلة',
      primaryValue: item.salesValue,
      currencyTag: 'YER',
      secondaryLabel: 'الكيان التجاري',
      secondaryValue: item.ownerDisplay,
      statusText: item.isActive ? 'مرخصة ونشطة' : 'معلقة',
      isStatusActive: item.isActive,
      metricText: item.posCountText,
      metricIcon: Icons.storefront_rounded,
      theme: WorkspaceCarouselTheme.resolve(
        index: item.cardIndex,
        selected: item.isSelected,
      ),
      isSelected: item.isSelected,
      onTap: onTap,
    );
  }
}
