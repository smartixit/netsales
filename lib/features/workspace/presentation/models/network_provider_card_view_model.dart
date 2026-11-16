class NetworkProviderCardViewModel {
  const NetworkProviderCardViewModel({
    required this.networkId,
    required this.networkName,
    required this.logoUrl,
    required this.avatarInitial,
    required this.subtitle,
    required this.networkCode,
    required this.ownerDisplay,
    required this.isActive,
    required this.salesValue,
    required this.posCountText,
    required this.isSelected,
    required this.cardIndex,
  });

  final int networkId;
  final String networkName;
  final String? logoUrl;
  final String avatarInitial;
  final String subtitle;
  final String networkCode;
  final String ownerDisplay;
  final bool isActive;
  final String salesValue;
  final String posCountText;
  final bool isSelected;
  final int cardIndex;
}
