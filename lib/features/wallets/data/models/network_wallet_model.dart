import 'package:netsales/features/wallets/domain/entities/network_wallet_entity.dart';

/// ============================================================================
/// نموذج بيانات محفظة مزود الشبكة (NetworkWalletModel)
/// ============================================================================
/// يرث بالضرورة من الكيان الدوميني [NetworkWalletEntity] طبقاً لقواعد Clean Architecture.
class NetworkWalletModel extends NetworkWalletEntity {
  const NetworkWalletModel({
    required super.walletId,
    required super.networkId,
    required super.walletUuid,
    required super.walletBalance,
    required super.status,
    super.networkName,
    super.createdAt,
    super.updatedAt,
  });

  factory NetworkWalletModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      try {
        return DateTime.tryParse(value.toString());
      } catch (_) {
        return null;
      }
    }

    final rawBalance = json['wallet_balance'];
    final double balance = (rawBalance is num)
        ? rawBalance.toDouble()
        : double.tryParse(rawBalance?.toString() ?? '') ?? 0.0;

    final network = json['network'] is Map ? json['network'] as Map<String, dynamic> : null;

    return NetworkWalletModel(
      walletId: (json['wallet_id'] as num?)?.toInt() ?? 0,
      networkId: (json['network_id'] as num?)?.toInt() ?? 0,
      walletUuid: json['wallet_uuid']?.toString() ?? '',
      walletBalance: balance,
      status: json['status'] == true || json['status'] == 1,
      networkName: network?['network_name']?.toString() ?? json['network_name']?.toString(),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet_id': walletId,
      'network_id': networkId,
      'wallet_uuid': walletUuid,
      'wallet_balance': walletBalance,
      'status': status,
      'network_name': networkName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

