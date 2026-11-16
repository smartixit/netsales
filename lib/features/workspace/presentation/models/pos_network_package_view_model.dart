class PosNetworkPackageViewModel {
  const PosNetworkPackageViewModel({
    required this.packageId,
    required this.name,
    required this.discountLabel,
    required this.specifications,
    required this.supplyPrice,
    required this.retailPrice,
  });

  final int packageId;
  final String name;
  final String discountLabel;
  final String specifications;
  final String supplyPrice;
  final String retailPrice;
}
