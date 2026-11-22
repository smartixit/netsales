import 'package:netsales/features/wallet/domain/entities/pos_wallet_entity.dart';

/// نموذج بيانات محفظة نقطة البيع (POS Wallet Model)
///
/// يتعامل مع تفكيك وتجميع كائن JSON الصادر من PosWalletResource في Laravel.
class PosWalletModel extends PosWalletEntity {
  const PosWalletModel({
    required super.walletId,
    required super.networkId,
    required super.posId,
    required super.walletUuid,
    required super.walletBalance,
    required super.openingBalance,
    super.openingBalanceSource,
    required super.currencyCode,
    super.creditLimit,
    required super.availableOverdraftCapacity,
    required super.totalPurchasingPower,
    required super.status,
    super.accountingStatus,
    super.accountingStatusLabel,
    required super.isOverdrawn,
    required super.debitAmount,
    required super.creditAmount,
    super.createdAt,
    super.updatedAt,
    super.networkName,
    super.posName,
  });

  factory PosWalletModel.fromJson(Map<String, dynamic> json) {
    final networkJson = json['network'] as Map<String, dynamic>?;
    final posJson = json['pos'] as Map<String, dynamic>?;

    final rawWalletId = json['wallet_id'] ?? json['id'];
    final rawNetworkId = json['network_id'];
    final rawPosId = json['pos_id'];

    final rawWalletBalance = json['wallet_balance'];
    final rawOpeningBalance = json['opening_balance'];
    final rawCreditLimit = json['credit_limit'];
    final rawAvailableOverdraft = json['available_overdraft_capacity'];
    final rawPurchasingPower = json['total_purchasing_power'];
    final rawDebitAmount = json['debit_amount'];
    final rawCreditAmount = json['credit_amount'];

    return PosWalletModel(
      walletId: rawWalletId is num
          ? rawWalletId.toInt()
          : (int.tryParse(rawWalletId?.toString() ?? '') ?? 0),
      networkId: rawNetworkId is num
          ? rawNetworkId.toInt()
          : (int.tryParse(rawNetworkId?.toString() ?? '') ?? 0),
      posId: rawPosId is num
          ? rawPosId.toInt()
          : (int.tryParse(rawPosId?.toString() ?? '') ?? 0),
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
      creditLimit: rawCreditLimit == null
          ? null
          : (rawCreditLimit is num
                ? rawCreditLimit.toDouble()
                : double.tryParse(rawCreditLimit.toString())),
      availableOverdraftCapacity: rawAvailableOverdraft is num
          ? rawAvailableOverdraft.toDouble()
          : (double.tryParse(rawAvailableOverdraft?.toString() ?? '') ?? 0.0),
      totalPurchasingPower: rawPurchasingPower is num
          ? rawPurchasingPower.toDouble()
          : (double.tryParse(rawPurchasingPower?.toString() ?? '') ?? 0.0),
      status:
          json['status'] == true ||
          json['status'] == 1 ||
          json['status'] == '1',
      accountingStatus: json['accounting_status']?.toString(),
      accountingStatusLabel: json['accounting_status_label']?.toString(),
      isOverdrawn: json['is_overdrawn'] == true || json['is_overdrawn'] == 1,
      debitAmount: rawDebitAmount is num
          ? rawDebitAmount.toDouble()
          : (double.tryParse(rawDebitAmount?.toString() ?? '') ?? 0.0),
      creditAmount: rawCreditAmount is num
          ? rawCreditAmount.toDouble()
          : (double.tryParse(rawCreditAmount?.toString() ?? '') ?? 0.0),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      networkName: networkJson?['network_name']?.toString(),
      posName: posJson?['pos_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': walletId,
      'wallet_id': walletId,
      'network_id': networkId,
      'pos_id': posId,
      'wallet_uuid': walletUuid,
      'wallet_balance': walletBalance,
      'opening_balance': openingBalance,
      'opening_balance_source': openingBalanceSource,
      'currency_code': currencyCode,
      'credit_limit': creditLimit,
      'available_overdraft_capacity': availableOverdraftCapacity,
      'total_purchasing_power': totalPurchasingPower,
      'status': status,
      'accounting_status': accountingStatus,
      'accounting_status_label': accountingStatusLabel,
      'is_overdrawn': isOverdrawn,
      'debit_amount': debitAmount,
      'credit_amount': creditAmount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
