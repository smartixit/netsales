/// ============================================================================
/// كائن الحساب المصرفي للمنشأة الدوميني النقي (BankAccountEntity)
/// ============================================================================
/// يمثل الحساب البنكي المعتمد للتحويلات والإيداعات المصرفية.
class BankAccountEntity {
  final int accountId;
  final String bankName;
  final String? bankLogo;
  final String accountHolderName;
  final String accountNumber;
  final String accountType;
  final String accountTypeLabel;
  final String accountCurrency;
  final double accountBalance;
  final bool status;
  final DateTime? createdAt;

  const BankAccountEntity({
    required this.accountId,
    required this.bankName,
    this.bankLogo,
    required this.accountHolderName,
    required this.accountNumber,
    required this.accountType,
    required this.accountTypeLabel,
    required this.accountCurrency,
    required this.accountBalance,
    required this.status,
    this.createdAt,
  });

  bool get isActive => status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BankAccountEntity &&
          runtimeType == other.runtimeType &&
          accountId == other.accountId;

  @override
  int get hashCode => accountId.hashCode;

  @override
  String toString() =>
      'BankAccountEntity(id: $accountId, bank: $bankName, number: $accountNumber, status: $status)';
}
