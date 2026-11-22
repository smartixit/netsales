import 'package:equatable/equatable.dart';
import 'package:netsales/core/enums/wallet_operation_type.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';

/// الكيان النقي لقيد دفتر أستاذ محفظة نقطة البيع (POS Wallet Log Entity)
///
/// يمثل حركة مالية موثقة في دفتر أستاذ المحفظة مع لقطات الرصيد قبل وبعد.
class PosWalletLogEntity extends Equatable {
  final int logId;
  final int walletId;
  final String? operationTypeRaw;
  final String? operationTypeLabel;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String balanceSnapshotSource;
  final String currencyCode;
  final String statement;
  final String? logDate;
  final int? createdBy;
  final String? createdByName;
  final String? createdAt;

  const PosWalletLogEntity({
    required this.logId,
    required this.walletId,
    this.operationTypeRaw,
    this.operationTypeLabel,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.balanceSnapshotSource,
    required this.currencyCode,
    required this.statement,
    this.logDate,
    this.createdBy,
    this.createdByName,
    this.createdAt,
  });

  /// التمثيل النوعي لنوع الحركة المالية المعتمد
  WalletOperationType get typedOperationType =>
      WalletOperationType.fromWire(operationTypeRaw);

  /// كائن العرض الدلالي الموحد لنوع الحركة عبر EnumPresentationRegistry
  EnumPresentation get operationPresentation =>
      EnumPresentationRegistry.resolveWalletOperationType(
        typedOperationType,
        serverLabel: operationTypeLabel,
      );

  /// هل الحركة إيداع / تغذية
  bool get isDeposit => typedOperationType == WalletOperationType.deposit;

  /// هل الحركة سحب / خصم
  bool get isWithdraw => typedOperationType == WalletOperationType.withdraw;

  @override
  List<Object?> get props => [
    logId,
    walletId,
    operationTypeRaw,
    operationTypeLabel,
    amount,
    balanceBefore,
    balanceAfter,
    balanceSnapshotSource,
    currencyCode,
    statement,
    logDate,
    createdBy,
    createdByName,
    createdAt,
  ];
}
