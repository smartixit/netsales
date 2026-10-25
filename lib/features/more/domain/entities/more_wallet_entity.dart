/// ============================================================================
/// كائن محفظة الحساب الدوميني النقي (MoreWalletEntity)
/// ============================================================================
/// كائن دوميني نقي خالٍ تماماً من أي اعتماديات خارجية أو منطق تسلسل JSON.
/// يمثل رصيد وحالة المحفظة المالية للمستخدم الحالي (شبكة أو نقطة بيع).
class MoreWalletEntity {
  final int walletId;
  final double balance;
  final bool status;
  final String currency;
  final double debitAmount;
  final double creditAmount;
  final bool isOverdrawn;
  final DateTime? updatedAt;

  const MoreWalletEntity({
    required this.walletId,
    required this.balance,
    required this.status,
    this.currency = 'ر.ي',
    this.debitAmount = 0.0,
    this.creditAmount = 0.0,
    this.isOverdrawn = false,
    this.updatedAt,
  });

  bool get isActive => status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoreWalletEntity &&
          runtimeType == other.runtimeType &&
          walletId == other.walletId &&
          balance == other.balance;

  @override
  int get hashCode => walletId.hashCode ^ balance.hashCode;

  @override
  String toString() =>
      'MoreWalletEntity(walletId: $walletId, balance: $balance, status: $status)';
}
