import 'package:netsales/core/enums/wallet_operation_type.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';

/// واجهة موحدة لقيد أي حركة في دفاتر الأستاذ المالية (POS أو Network)
abstract interface class WalletLogEntry {
  int get logId;
  int get walletId;
  String? get operationTypeRaw;
  String? get operationTypeLabel;
  double get amount;
  double get balanceBefore;
  double get balanceAfter;
  String get balanceSnapshotSource;
  String get currencyCode;
  String get statement;
  String? get logDate;
  int? get createdBy;
  String? get createdByName;
  String? get createdAt;

  WalletOperationType get typedOperationType;
  EnumPresentation get operationPresentation;
  bool get isDeposit;
  bool get isWithdraw;
}
