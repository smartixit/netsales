import 'package:netsales/features/more/domain/entities/more_wallet_entity.dart';

/// ============================================================================
/// نموذج بيانات المحفظة المالية (MoreWalletModel)
/// ============================================================================
/// يرث بالضرورة من الكيان الدوميني [MoreWalletEntity] طبقاً لقواعد Clean Architecture.
class MoreWalletModel extends MoreWalletEntity {
  const MoreWalletModel({
    required super.walletId,
    required super.balance,
    required super.status,
    super.currency = 'ر.ي',
    super.debitAmount = 0.0,
    super.creditAmount = 0.0,
    super.isOverdrawn = false,
    super.updatedAt,
  });

  factory MoreWalletModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      try {
        return DateTime.tryParse(value.toString());
      } catch (_) {
        return null;
      }
    }

    final rawBalance = json['wallet_balance'] ?? json['balance'] ?? 0.0;
    final balance = (rawBalance is num) ? rawBalance.toDouble() : double.tryParse(rawBalance.toString()) ?? 0.0;

    final rawDebit = json['debit_amount'] ?? 0.0;
    final debit = (rawDebit is num) ? rawDebit.toDouble() : double.tryParse(rawDebit.toString()) ?? 0.0;

    final rawCredit = json['credit_amount'] ?? 0.0;
    final credit = (rawCredit is num) ? rawCredit.toDouble() : double.tryParse(rawCredit.toString()) ?? 0.0;

    final rawStatus = json['status'];
    final bool status = rawStatus is bool
        ? rawStatus
        : (rawStatus == 1 || rawStatus == '1' || rawStatus == 'true');

    final bool isOverdrawn = json['is_overdrawn'] == true || (balance < 0);

    return MoreWalletModel(
      walletId: (json['wallet_id'] ?? json['id'] ?? 0) as int,
      balance: balance,
      status: status,
      currency: json['currency']?.toString() ?? 'ر.ي',
      debitAmount: debit,
      creditAmount: credit,
      isOverdrawn: isOverdrawn,
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet_id': walletId,
      'wallet_balance': balance,
      'status': status,
      'currency': currency,
      'debit_amount': debitAmount,
      'credit_amount': creditAmount,
      'is_overdrawn': isOverdrawn,
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
