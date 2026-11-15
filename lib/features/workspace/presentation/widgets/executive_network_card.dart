import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/widgets/carousels/custom_carousel_card.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';

/// مهايئ بطاقة الشبكة التنفيذية المربوط بالنموذج (ExecutiveNetworkCard)
/// يقوم بتمرير بيانات NetworkEntity إلى ودجت الكاروسيل العامة CustomCarouselCard
class ExecutiveNetworkCard extends StatelessWidget {
  final NetworkEntity network;
  final bool isSelected;
  final int cardIndex;
  final String salesValue;
  final String posCountText;
  final VoidCallback onTap;

  const ExecutiveNetworkCard({
    super.key,
    required this.network,
    required this.isSelected,
    required this.cardIndex,
    required this.salesValue,
    required this.posCountText,
    required this.onTap,
  });

  CustomCarouselCardTheme _resolveTheme(int index, bool selected) {
    if (selected) {
      return CustomCarouselCardTheme.emerald;
    }
    final variant = index % 3;
    if (variant == 0) {
      return CustomCarouselCardTheme.sapphire;
    } else if (variant == 1) {
      return CustomCarouselCardTheme.amethyst;
    } else {
      return CustomCarouselCardTheme.titanium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtitleParts = [
      if (network.governorateName != null &&
          network.governorateName!.isNotEmpty)
        network.governorateName!,
      if (network.directorateName != null &&
          network.directorateName!.isNotEmpty)
        network.directorateName!,
    ];
    final subtitle = subtitleParts.isNotEmpty
        ? subtitleParts.join(' • ')
        : 'شبكة مصرحة ومعتمدة';

    final networkCode = network.networkUuid != null &&
            network.networkUuid!.isNotEmpty
        ? (network.networkUuid!.length > 16
            ? network.networkUuid!.substring(0, 16)
            : network.networkUuid!)
        : 'NET-${network.networkId.toString().padLeft(4, '0')}';

    final ownerDisplay = network.ownerName != null &&
            network.ownerName!.isNotEmpty
        ? network.ownerName!
        : 'المزود المعتمد';

    final logoWidget = network.networkProfileLogoUrl != null &&
            network.networkProfileLogoUrl!.isNotEmpty
        ? CustomCachedImage.avatar(
            url: network.networkProfileLogoUrl,
            radius: 17.r,
          )
        : Text(
            network.networkName.isNotEmpty
                ? network.networkName.substring(0, 1)
                : 'ش',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14.sp,
            ),
          );

    return CustomCarouselCard(
      title: network.networkName,
      subtitle: subtitle,
      logo: logoWidget,
      cardNumber: networkCode,
      primaryLabel: 'إجمالي المبيعات المحصلة',
      primaryValue: salesValue,
      currencyTag: 'YER',
      secondaryLabel: 'الكيان التجاري',
      secondaryValue: ownerDisplay,
      statusText: network.isActive ? 'مرخصة ونشطة' : 'معلقة',
      isStatusActive: network.isActive,
      metricText: posCountText,
      metricIcon: Icons.storefront_rounded,
      theme: _resolveTheme(cardIndex, isSelected),
      isSelected: isSelected,
      onTap: onTap,
    );
  }
}
