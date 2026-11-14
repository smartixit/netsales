import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';
import 'package:premium_carousel_slider/premium_carousel_slider.dart';

/// بطاقة مصرفية فاخرة تعبر عن حساب الوكيل لدى الشبكة المزودة المختارة.
/// مطبقة وفق معمارية VIP Bank Card لتعزيز الجاذبية البصرية والموثوقية المؤسسية.
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
      if (network?.governorateName != null && network!.governorateName!.isNotEmpty)
        network.governorateName!,
      if (network?.directorateName != null && network!.directorateName!.isNotEmpty)
        network.directorateName!,
    ].join(' • ');

    final formattedBalance = wallet != null
        ? '${AmountFormatter.formatValue(wallet!.walletBalance, decimalPlaces: 0)} $currency'
        : '•••• $currency';

    final formattedCredit = wallet?.creditLimit != null
        ? '${AmountFormatter.formatValue(wallet!.creditLimit!, decimalPlaces: 0)} $currency'
        : (wallet != null ? 'غير محدد' : '••••');

    return PremiumBankCard(
      title: name,
      subtitle: locationParts.isNotEmpty ? locationParts : 'المزود المعتمد',
      logo: logoUrl != null && logoUrl.trim().isNotEmpty
          ? CachedNetworkImage(
              imageUrl: logoUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Icon(
                Icons.hub_rounded,
                size: 20,
                color: Colors.white70,
              ),
              errorWidget: (context, url, error) => const Icon(
                Icons.hub_rounded,
                size: 20,
                color: Colors.white70,
              ),
            )
          : const Icon(
              Icons.hub_rounded,
              size: 20,
              color: Colors.white70,
            ),
      cardUuidLabel: 'Wallet UUID',
      cardNumber: wallet?.walletUuid,
      primaryLabel: 'رصيد نقطة البيع المتاح',
      primaryValue: formattedBalance,
      secondaryLabel: 'سقف الائتمان الممنوح',
      secondaryValue: formattedCredit,
      cardholderName: link.pos?.posName ?? 'نقطة البيع المعتمدة',
      statusText: link.isActive ? 'مرتبط ونشط' : 'معلّق',
      theme: isSelected
          ? PremiumBankCardTheme.emerald
          : PremiumBankCardTheme.obsidian,
      isSelected: isSelected,
      onTap: onTap,
    );
  }
}
