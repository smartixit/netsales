class NetworkSalesTrendPointEntity {
  const NetworkSalesTrendPointEntity({
    required this.date,
    required this.totalAmount,
    this.invoiceCount,
  });

  final String date;
  final double totalAmount;
  final int? invoiceCount;
}
