import 'package:flutter/material.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/widgets/carousels/custom_carousel_card.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';

/// بطاقة مصرفية فاخرة تعبر عن حساب الوكيل لدى الشبكة المزودة المختارة.
/// مطبقة عبر CustomCarouselCard الموحدة لتعزيز الجاذبية البصرية والموثوقية المؤسسية.
class PosNetworkCarouselCard extends StatelessWidget {
  const PosNetworkCarouselCard({
    super.key,
    required this.link,
    required this.isSelected,
    required this.onTap,
    this.wallet,
  });

  final NetworkPosLinkEntity link;
  final bool isSelected;
  final VoidCallback onTap;
  final PosWalletEntity? wallet;

  @override
  Widget build(BuildContext context) {
    final network = link.network;
    final name = network?.networkName ?? 'شبكة #${link.networkId}';
    final logoUrl = network?.networkProfileLogoUrl;
    final currency = wallet?.currencyCode ?? 'YER';

    final locationParts = [
      if (network?.governorateName != null &&
          network!.governorateName!.isNotEmpty)
        network.governorateName!,
      if (network?.directorateName != null &&
          network!.directorateName!.isNotEmpty)
        network.directorateName!,
    ].join(' • ');

    final formattedBalance = wallet != null
        ? '${AmountFormatter.formatValue(wallet!.walletBalance, decimalPlaces: 0)} $currency'
        : '••••';

    final formattedCredit = wallet?.creditLimit != null
        ? '${AmountFormatter.formatValue(wallet!.creditLimit!, decimalPlaces: 0)} $currency'
        : (wallet != null ? 'غير محدد' : '••••');

    final logoWidget = CustomAvatarBadge(
      imageUrl: logoUrl,
      initials: name,
      size: AvatarBadgeSize.sm,
      hasPulse: false,
    );

    return CustomCarouselCard(
      title: name,
      subtitle: locationParts.isNotEmpty ? locationParts : 'المزود المعتمد',
      logo: logoWidget,
      cardNumber: wallet?.walletUuid,
      primaryLabel: 'رصيد نقطة البيع المتاح',
      primaryValue: formattedBalance,
      currencyTag: currency,
      secondaryLabel: 'سقف الائتمان الممنوح',
      secondaryValue: formattedCredit,
      statusText: link.isActive ? 'مرتبط ونشط' : 'معلّق',
      isStatusActive: link.isActive,
      metricText: link.pos?.posName ?? 'نقطة البيع',
      metricIcon: Icons.storefront_rounded,
      theme: isSelected
          ? CustomCarouselCardTheme.emerald
          : CustomCarouselCardTheme.sapphire,
      isSelected: isSelected,
      onTap: onTap,
    );
  }
}
