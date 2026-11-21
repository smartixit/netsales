class PosLinkedNetworkOptionViewModel {
  const PosLinkedNetworkOptionViewModel({
    required this.networkPosId,
    required this.networkId,
    required this.displayName,
    required this.isSelected,
  });

  final int networkPosId;
  final int networkId;
  final String displayName;
  final bool isSelected;
}
