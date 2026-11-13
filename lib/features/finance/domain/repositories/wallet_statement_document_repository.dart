import 'package:netsales/features/finance/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';

/// Domain boundary for rendering a complete wallet ledger statement.
abstract interface class WalletStatementDocumentRepository {
  Future<bool> exportNetworkStatement(NetworkWalletEntity wallet, List<NetworkWalletLogEntity> logs);
  Future<bool> exportPosStatement(PosWalletEntity wallet, List<PosWalletLogEntity> logs);
}
