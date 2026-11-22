import 'package:netsales/core/enums/wallet_operation_type.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/wallet/data/datasources/network_wallet_remote_data_source.dart';
import 'package:netsales/features/wallet/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/wallet/domain/entities/network_wallet_log_entity.dart';
import 'package:netsales/features/wallet/domain/repositories/network_wallet_repository.dart';

/// تطبيق مستودع محفظة مزود الشبكة ودفتر الأستاذ
class NetworkWalletRepositoryImpl implements NetworkWalletRepository {
  final NetworkWalletRemoteDataSource _remoteDataSource;

  const NetworkWalletRepositoryImpl(this._remoteDataSource);

  @override
  Future<NetworkWalletEntity> getWalletByNetworkId(int networkId) async {
    final response = await _remoteDataSource.getWalletByNetworkId(networkId);
    return response.data!;
  }

  @override
  Future<NetworkWalletEntity> getWalletById(int walletId) async {
    final response = await _remoteDataSource.getWalletById(walletId);
    return response.data!;
  }

  @override
  Future<PaginatedList<NetworkWalletLogEntity>> getWalletLogs({
    required int walletId,
    WalletOperationType? operationType,
    String? fromDate,
    String? toDate,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    final query = <String, dynamic>{
      if (operationType != null && operationType.isKnown)
        'log_operation': operationType.wireValue,
      if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
      if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
      if (search != null && search.isNotEmpty) 'search': search,
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      'per_page': ?perPage,
    };

    final response = await _remoteDataSource.getWalletLogs(
      walletId,
      query: query.isNotEmpty ? query : null,
    );

    final items = response.data ?? [];

    return PaginatedList<NetworkWalletLogEntity>(
      items: items,
      nextCursor: response.nextCursor,
      prevCursor: response.prevCursor,
    );
  }
}
