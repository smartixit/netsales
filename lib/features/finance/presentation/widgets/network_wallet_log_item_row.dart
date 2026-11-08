import 'package:flutter/material.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/features/finance/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/finance/presentation/widgets/wallet_log_entry_row.dart';

class NetworkWalletLogItemRow extends StatelessWidget {
  final NetworkWalletLogEntity log;
  final int index;

  const NetworkWalletLogItemRow({
    super.key,
    required this.log,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final presentation =
        EnumPresentationRegistry.resolveWalletOperationType(
      log.typedLogOperation,
      serverLabel: log.logOperationLabel,
    );

    return WalletLogEntryRow(
      operation: presentation,
      operationType: log.typedLogOperation,
      amount: log.logAmount,
      statement: log.logStatement,
      date: log.logDate,
      index: index,
    );
  }
}
