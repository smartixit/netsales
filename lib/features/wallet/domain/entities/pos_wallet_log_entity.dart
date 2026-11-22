import 'package:equatable/equatable.dart';
import 'package:netsales/core/enums/wallet_operation_type.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/features/wallet/domain/entities/wallet_log_entry.dart';

/// الكيان النقي لقيد دفتر أستاذ محفظة نقطة البيع (POS Wallet Log Entity)
///
/// يمثل حركة مالية موثقة في دفتر أستاذ المحفظة مع لقطات الرصيد قبل وبعد.
class PosWalletLogEntity extends Equatable implements WalletLogEntry {
  @override
  final int logId;
  @override
  final int walletId;
  @override
  final String? operationTypeRaw;
  @override
  final String? operationTypeLabel;
  @override
  final double amount;
  @override
  final double balanceBefore;
  @override
  final double balanceAfter;
  @override
  final String balanceSnapshotSource;
  @override
  final String currencyCode;
  @override
  final String statement;
  @override
  final String? logDate;
  @override
  final int? createdBy;
  @override
  final String? createdByName;
  @override
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
  @override
  WalletOperationType get typedOperationType =>
      WalletOperationType.fromWire(operationTypeRaw);

  /// كائن العرض الدلالي الموحد لنوع الحركة عبر EnumPresentationRegistry
  @override
  EnumPresentation get operationPresentation =>
      EnumPresentationRegistry.resolveWalletOperationType(
        typedOperationType,
        serverLabel: operationTypeLabel,
      );

  /// هل الحركة إيداع / تغذية
  @override
  bool get isDeposit => typedOperationType == WalletOperationType.deposit;

  /// هل الحركة سحب / خصم
  @override
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
