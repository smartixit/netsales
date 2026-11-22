import 'package:equatable/equatable.dart';
import 'package:netsales/core/enums/wallet_operation_type.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/features/wallet/domain/entities/wallet_log_entry.dart';

/// الكيان النقي لقيد دفتر أستاذ محفظة مزود الشبكة (Network Wallet Log Entity)
///
/// يمثل قيد حركة مالية في خزينة الشبكة يوثق التدفقات النقدية الداخلة والخارجة.
class NetworkWalletLogEntity extends Equatable implements WalletLogEntry {
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

  const NetworkWalletLogEntity({
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

  @override
  WalletOperationType get typedOperationType =>
      WalletOperationType.fromWire(operationTypeRaw);

  @override
  EnumPresentation get operationPresentation =>
      EnumPresentationRegistry.resolveWalletOperationType(
        typedOperationType,
        serverLabel: operationTypeLabel,
      );

  @override
  bool get isDeposit => typedOperationType == WalletOperationType.deposit;

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
