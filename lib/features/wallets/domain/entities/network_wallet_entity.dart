/// ============================================================================
/// كائن محفظة مزود الشبكة الدوميني النقي (NetworkWalletEntity)
/// ============================================================================
/// يمثل الحساب المالي المركزي والسيولة النقدية لمزود الشبكة في النظام.
/// خالي تماماً من أي تبعيات خارجية أو دوال تحويل JSON طبقاً لـ Clean Architecture.
class NetworkWalletEntity {
  final int walletId;
  final int networkId;
  final String walletUuid;
  final double walletBalance;
  final bool status;
  final String? networkName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NetworkWalletEntity({
    required this.walletId,
    required this.networkId,
    required this.walletUuid,
    required this.walletBalance,
    required this.status,
    this.networkName,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkWalletEntity &&
          runtimeType == other.runtimeType &&
          walletId == other.walletId;

  @override
  int get hashCode => walletId.hashCode;

  @override
  String toString() =>
      'NetworkWalletEntity(id: $walletId, balance: $walletBalance, status: $status)';
}

