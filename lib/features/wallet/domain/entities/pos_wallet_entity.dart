import 'package:equatable/equatable.dart';
import 'package:netsales/core/enums/accounting_status.dart';

/// الكيان النقي لمحفظة نقطة البيع (POS Wallet Entity)
///
/// يمثل بيانات المحفظة المالية المعتمدة رسمياً من الواجهة الخلفية netsales_api.
class PosWalletEntity extends Equatable {
  final int walletId;
  final int networkId;
  final int posId;
  final String walletUuid;
  final double walletBalance;
  final double openingBalance;
  final String? openingBalanceSource;
  final String currencyCode;
  final double? creditLimit;
  final double availableOverdraftCapacity;
  final double totalPurchasingPower;
  final bool status;
  final String? accountingStatus;
  final String? accountingStatusLabel;
  final bool isOverdrawn;
  final double debitAmount;
  final double creditAmount;
  final String? createdAt;
  final String? updatedAt;
  final String? networkName;
  final String? posName;

  const PosWalletEntity({
    required this.walletId,
    required this.networkId,
    required this.posId,
    required this.walletUuid,
    required this.walletBalance,
    required this.openingBalance,
    this.openingBalanceSource,
    required this.currencyCode,
    this.creditLimit,
    required this.availableOverdraftCapacity,
    required this.totalPurchasingPower,
    required this.status,
    this.accountingStatus,
    this.accountingStatusLabel,
    required this.isOverdrawn,
    required this.debitAmount,
    required this.creditAmount,
    this.createdAt,
    this.updatedAt,
    this.networkName,
    this.posName,
  });

  /// التمثيل النوعي للمركز المحاسبي المعتمد
  AccountingStatus get typedAccountingStatus =>
      AccountingStatus.fromWire(accountingStatus);


  /// هل المحفظة دائنة (تحتوي على رصيد متاح إيجابي)
  bool get isCredit => typedAccountingStatus == AccountingStatus.credit;

  /// هل المحفظة مدينة (مسحوبة على المكشوف وبها مديونية للشبكة)
  bool get isDebit => typedAccountingStatus == AccountingStatus.debit;

  /// هل المحفظة متزنة برصيد صفري
  bool get isZero => typedAccountingStatus == AccountingStatus.zero;

  /// هل المحفظة تمتلك سقفاً ائتمانياً معتمداً
  bool get hasCreditFacility => creditLimit != null && creditLimit! > 0;

  @override
  List<Object?> get props => [
    walletId,
    networkId,
    posId,
    walletUuid,
    walletBalance,
    openingBalance,
    openingBalanceSource,
    currencyCode,
    creditLimit,
    availableOverdraftCapacity,
    totalPurchasingPower,
    status,
    accountingStatus,
    accountingStatusLabel,
    isOverdrawn,
    debitAmount,
    creditAmount,
    createdAt,
    updatedAt,
    networkName,
    posName,
  ];
}
