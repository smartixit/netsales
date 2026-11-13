import 'package:netsales/features/finance/data/services/wallet_statement_document_service.dart';
import 'package:netsales/features/finance/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/finance/domain/repositories/wallet_statement_document_repository.dart';

/// Infrastructure adapter for branded wallet statement documents.
class WalletStatementDocumentRepositoryImpl implements WalletStatementDocumentRepository {
  const WalletStatementDocumentRepositoryImpl({required this.documentService});
  final WalletStatementDocumentService documentService;

  @override
  Future<bool> exportNetworkStatement(NetworkWalletEntity wallet, List<NetworkWalletLogEntity> logs) async =>
      (await documentService.exportNetworkStatement(wallet, logs)).isSuccess;

  @override
  Future<bool> exportPosStatement(PosWalletEntity wallet, List<PosWalletLogEntity> logs) async =>
      (await documentService.exportPosStatement(wallet, logs)).isSuccess;
}
