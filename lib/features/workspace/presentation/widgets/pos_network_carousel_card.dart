import 'package:flutter/material.dart';
import 'package:netsales/features/workspace/presentation/utils/workspace_carousel_theme.dart';
import 'package:netsales/features/workspace/presentation/models/pos_network_carousel_card_view_model.dart';
import 'package:netsales/widgets/carousels/custom_carousel_card.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';

/// بطاقة مصرفية فاخرة تعبر عن حساب الوكيل لدى الشبكة المزودة المختارة.
/// مطبقة عبر CustomCarouselCard الموحدة لتعزيز الجاذبية البصرية والموثوقية المؤسسية.
class PosNetworkCarouselCard extends StatelessWidget {
  const PosNetworkCarouselCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final PosNetworkCarouselCardViewModel item;
  final VoidCallback onTap;


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
      subtitle: item.locationLabel,
      logo: logoWidget,
      cardNumber: item.cardNumber,
      primaryLabel: 'رصيد نقطة البيع المتاح',
      primaryValue: item.formattedBalance,
      currencyTag: item.currency,
      secondaryLabel: 'سقف الائتمان الممنوح',
      secondaryValue: item.formattedCredit,
      statusText: item.statusText,
      isStatusActive: item.isStatusActive,
      metricText: item.metricText,
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
