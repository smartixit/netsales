/// ============================================================================
/// كائن سجل حركة محفظة الشبكة الدوميني النقي (NetworkWalletLogEntity)
/// ============================================================================
/// يمثل حركة مالية مقيدة في دفتر الأستاذ لمحفظة مزود الشبكة.
class NetworkWalletLogEntity {
  final int logId;
  final int walletId;
  final String logOperation;
  final String logOperationLabel;
  final double logAmount;
  final String? logStatement;
  final DateTime? logDate;
  final int? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NetworkWalletLogEntity({
    required this.logId,
    required this.walletId,
    required this.logOperation,
    required this.logOperationLabel,
    required this.logAmount,
    this.logStatement,
    this.logDate,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  /// التحقق مما إذا كانت الحركة إضافة نقدية موجبة إلى المحفظة (إيداع / تحصيل)
  bool get isCredit {
    final op = logOperation.toUpperCase();
    return op == 'DEPOSIT' ||
        op == 'CREDIT' ||
        op == 'INVOICE_PAYMENT' ||
        op == 'TRANSFER_FROM_POS';
  }

  /// التحقق مما إذا كانت الحركة سحباً أو نقصاً من رصيد المحفظة (سحب / مصروفات / تحويل للوكيل)
  bool get isDebit => !isCredit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkWalletLogEntity &&
          runtimeType == other.runtimeType &&
          logId == other.logId;

  @override
  int get hashCode => logId.hashCode;

  @override
  String toString() =>
      'NetworkWalletLogEntity(id: $logId, operation: $logOperation, amount: $logAmount)';
}

