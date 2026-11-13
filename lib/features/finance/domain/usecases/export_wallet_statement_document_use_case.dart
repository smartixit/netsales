import 'package:netsales/features/finance/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/finance/domain/repositories/wallet_statement_document_repository.dart';

/// Coordinates complete network and POS wallet statement PDF exports.
class ExportWalletStatementDocumentUseCase {
  const ExportWalletStatementDocumentUseCase(this.repository);
  final WalletStatementDocumentRepository repository;

  Future<bool> exportNetwork(NetworkWalletEntity wallet, List<NetworkWalletLogEntity> logs) =>
      repository.exportNetworkStatement(wallet, logs);

  Future<bool> exportPos(PosWalletEntity wallet, List<PosWalletLogEntity> logs) =>
      repository.exportPosStatement(wallet, logs);
}
