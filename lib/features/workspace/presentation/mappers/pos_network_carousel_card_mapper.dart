import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/workspace/presentation/models/pos_network_carousel_card_view_model.dart';

class PosNetworkCarouselCardMapper {
  const PosNetworkCarouselCardMapper._();

  static List<PosNetworkCarouselCardViewModel> map({
    required Iterable<NetworkPosLinkEntity> links,
    required NetworkPosLinkEntity? selectedLink,
    required PosWalletEntity? selectedWallet,
  }) {
    return List.unmodifiable(links.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final link = entry.value;
      final network = link.network;
      final isSelected = selectedLink?.networkId == link.networkId;
      final wallet = isSelected ? selectedWallet : null;
      final networkName = network?.networkName ?? 'الشبكة المزودة';
      final locationParts = [
        if (network?.governorateName?.isNotEmpty == true)
          network!.governorateName!,
        if (network?.directorateName?.isNotEmpty == true)
          network!.directorateName!,
      ];

      final currency = wallet?.currencyCode ?? 'YER';
      final formattedBalance = wallet == null
          ? '••••'
          : '${AmountFormatter.formatValue(wallet.walletBalance, decimalPlaces: 0)} $currency';
      final formattedCredit = wallet?.creditLimit != null
          ? '${AmountFormatter.formatValue(wallet!.creditLimit!, decimalPlaces: 0)} $currency'
          : (wallet != null ? 'غير محدد' : '••••');

      return PosNetworkCarouselCardViewModel(
        networkId: link.networkId,
        networkName: networkName,
        logoUrl: network?.networkProfileLogoUrl,
        locationLabel: locationParts.isEmpty
            ? 'المزود المعتمد'
            : locationParts.join(' • '),
        currency: currency,
        formattedBalance: formattedBalance,
        formattedCredit: formattedCredit,
        cardNumber: wallet?.walletUuid ??
            network?.networkUuid ??
            link.pos?.posUuid ??
            '',
        statusText: link.isActive ? 'مرتبط ونشط' : 'معلّق',
        isStatusActive: link.isActive,
        metricText: link.pos?.posName ?? 'نقطة البيع',
        isSelected: isSelected,
        cardIndex: index,
      );
    }));
  }
}
