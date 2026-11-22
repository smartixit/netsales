import 'package:equatable/equatable.dart';

/// الكيان النقي لمحفظة مزود الشبكة (Network Wallet Entity)
///
/// يمثل رصيد الخزينة التشغيلية لمزود الشبكة المعتمد من netsales_api.
class NetworkWalletEntity extends Equatable {
  final int walletId;
  final int networkId;
  final String walletUuid;
  final double walletBalance;
  final double openingBalance;
  final String? openingBalanceSource;
  final String currencyCode;
  final bool status;
  final String? createdAt;
  final String? updatedAt;
  final String? networkName;

  const NetworkWalletEntity({
    required this.walletId,
    required this.networkId,
    required this.walletUuid,
    required this.walletBalance,
    required this.openingBalance,
    this.openingBalanceSource,
    required this.currencyCode,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.networkName,
  });

  @override
  List<Object?> get props => [
    walletId,
    networkId,
    walletUuid,
    walletBalance,
    openingBalance,
    openingBalanceSource,
    currencyCode,
    status,
    createdAt,
    updatedAt,
    networkName,
  ];
}
