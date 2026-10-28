import 'package:netsales/features/more/domain/entities/bank_account_entity.dart';

/// ============================================================================
/// نموذج بيانات الحساب المصرفي (BankAccountModel)
/// ============================================================================
class BankAccountModel extends BankAccountEntity {
  const BankAccountModel({
    required super.accountId,
    required super.bankName,
    super.bankLogo,
    required super.accountHolderName,
    required super.accountNumber,
    required super.accountType,
    required super.accountTypeLabel,
    required super.accountCurrency,
    required super.accountBalance,
    required super.status,
    super.createdAt,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      try {
        return DateTime.tryParse(value.toString());
      } catch (_) {
        return null;
      }
    }

    final rawBalance = json['account_balance'];
    final double balance = (rawBalance is num)
        ? rawBalance.toDouble()
        : double.tryParse(rawBalance?.toString() ?? '') ?? 0.0;

    return BankAccountModel(
      accountId: (json['account_id'] as num?)?.toInt() ?? 0,
      bankName: json['bank_name']?.toString() ?? '',
      bankLogo: json['bank_logo']?.toString(),
      accountHolderName: json['account_holder_name']?.toString() ?? '',
      accountNumber: json['account_number']?.toString() ?? '',
      accountType: json['account_type']?.toString() ?? 'CURRENT',
      accountTypeLabel: json['account_type_label']?.toString() ??
          (json['account_type']?.toString() == 'SAVINGS'
              ? 'حساب توفير'
              : 'حساب جاري'),
      accountCurrency: json['account_currency']?.toString() ?? 'YER',
      accountBalance: balance,
      status: json['status'] == true || json['status'] == 1,
      createdAt: parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
      'bank_name': bankName,
      'bank_logo': bankLogo,
      'account_holder_name': accountHolderName,
      'account_number': accountNumber,
      'account_type': accountType,
      'account_type_label': accountTypeLabel,
      'account_currency': accountCurrency,
      'account_balance': accountBalance,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
