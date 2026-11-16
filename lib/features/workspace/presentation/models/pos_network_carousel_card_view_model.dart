class PosNetworkCarouselCardViewModel {
  const PosNetworkCarouselCardViewModel({
    required this.networkId,
    required this.networkName,
    required this.logoUrl,
    required this.locationLabel,
    required this.currency,
    required this.formattedBalance,
    required this.formattedCredit,
    required this.cardNumber,
    required this.statusText,
    required this.isStatusActive,
    required this.metricText,
    required this.isSelected,
    required this.cardIndex,
  });

  final int networkId;
  final String networkName;
  final String? logoUrl;
  final String locationLabel;
  final String currency;
  final String formattedBalance;
  final String formattedCredit;
  final String cardNumber;
  final String statusText;
  final bool isStatusActive;
  final String metricText;
  final bool isSelected;
  final int cardIndex;
}
