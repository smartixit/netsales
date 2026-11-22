import 'package:netsales/features/wallet/domain/entities/network_wallet_entity.dart';

/// نموذج بيانات محفظة مزود الشبكة (Network Wallet Model)
class NetworkWalletModel extends NetworkWalletEntity {
  const NetworkWalletModel({
    required super.walletId,
    required super.networkId,
    required super.walletUuid,
    required super.walletBalance,
    required super.openingBalance,
    super.openingBalanceSource,
    required super.currencyCode,
    required super.status,
    super.createdAt,
    super.updatedAt,
    super.networkName,
  });

  factory NetworkWalletModel.fromJson(Map<String, dynamic> json) {
    final networkJson = json['network'] as Map<String, dynamic>?;

    final rawWalletId = json['wallet_id'] ?? json['id'];
    final rawNetworkId = json['network_id'];
    final rawWalletBalance = json['wallet_balance'];
    final rawOpeningBalance = json['opening_balance'];

    return NetworkWalletModel(
      walletId: rawWalletId is num
          ? rawWalletId.toInt()
          : (int.tryParse(rawWalletId?.toString() ?? '') ?? 0),
      networkId: rawNetworkId is num
          ? rawNetworkId.toInt()
          : (int.tryParse(rawNetworkId?.toString() ?? '') ?? 0),
      walletUuid: json['wallet_uuid']?.toString() ?? '',
      walletBalance: rawWalletBalance is num
          ? rawWalletBalance.toDouble()
          : (double.tryParse(rawWalletBalance?.toString() ?? '') ?? 0.0),
      openingBalance: rawOpeningBalance is num
          ? rawOpeningBalance.toDouble()
          : (double.tryParse(rawOpeningBalance?.toString() ?? '') ?? 0.0),
      openingBalanceSource: json['opening_balance_source']?.toString(),
      currencyCode: (json['currency_code']?.toString() ?? 'YER')
          .trim()
          .toUpperCase(),
      status:
          json['status'] == true ||
          json['status'] == 1 ||
          json['status'] == '1',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      networkName: networkJson?['network_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': walletId,
      'wallet_id': walletId,
      'network_id': networkId,
      'wallet_uuid': walletUuid,
      'wallet_balance': walletBalance,
      'opening_balance': openingBalance,
      'opening_balance_source': openingBalanceSource,
      'currency_code': currencyCode,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
