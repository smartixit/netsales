import 'package:flutter/material.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/finance/presentation/widgets/wallet_log_entry_row.dart';

class PosWalletLogItemRow extends StatelessWidget {
  final PosWalletLogEntity log;
  final int index;

  const PosWalletLogItemRow({
    super.key,
    required this.log,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final presentation = EnumPresentationRegistry.resolveWalletOperationType(
      log.typedLogOperationType,
      serverLabel: log.logOperationTypeLabel,
    );

    return WalletLogEntryRow(
      operation: presentation,
      operationType: log.typedLogOperationType,
      amount: log.logAmount,
      statement: log.logStatement,
      date: log.logDate,
      index: index,
    );
  }
}
