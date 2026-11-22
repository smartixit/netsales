import 'package:netsales/core/enums/wallet_operation_type.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/wallet/data/datasources/pos_wallet_remote_data_source.dart';
import 'package:netsales/features/wallet/data/models/pos_wallet_model.dart';
import 'package:netsales/features/wallet/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/wallet/domain/entities/pos_wallet_log_entity.dart';
import 'package:netsales/features/wallet/domain/repositories/pos_wallet_repository.dart';

/// تطبيق مستودع محافظ نقاط البيع ودفتر الأستاذ
class PosWalletRepositoryImpl implements PosWalletRepository {
  final PosWalletRemoteDataSource _remoteDataSource;

  const PosWalletRepositoryImpl(this._remoteDataSource);

  @override
  Future<PosWalletEntity> getWalletByNetworkAndPos({
    required int networkId,
    required int posId,
  }) async {
    final response = await _remoteDataSource.getWalletByNetworkAndPos(
      networkId,
      posId,
    );
    return response.data!;
  }

  @override
  Future<PosWalletEntity> getWalletById(int walletId) async {
    final response = await _remoteDataSource.getWalletById(walletId);
    return response.data!;
  }

  @override
  Future<PaginatedList<PosWalletLogEntity>> getWalletLogs({
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
        'log_operation_type': operationType.wireValue,
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

    return PaginatedList<PosWalletLogEntity>(
      items: items,
      nextCursor: response.nextCursor,
      prevCursor: response.prevCursor,
    );
  }

  @override
  Future<PosWalletEntity> transferFromNetwork({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
  }) async {
    final payload = <String, dynamic>{
      'network_id': networkId,
      'pos_id': posId,
      'amount': amount,
      if (statement != null && statement.isNotEmpty) 'statement': statement,
    };

    final response = await _remoteDataSource.transferFromNetwork(payload);
    final data = response.data ?? {};
    final walletJson = data['pos_wallet'] as Map<String, dynamic>? ?? data;
    return PosWalletModel.fromJson(walletJson);
  }

  @override
  Future<PosWalletEntity> deposit({
    required int walletId,
    required double amount,
    required String statement,
    String? logDate,
  }) async {
    final payload = <String, dynamic>{
      'amount': amount,
      'statement': statement,
      if (logDate != null && logDate.isNotEmpty) 'log_date': logDate,
    };

    final response = await _remoteDataSource.deposit(walletId, payload);
    final data = response.data ?? {};
    final walletJson = data['wallet'] as Map<String, dynamic>? ?? data;
    return PosWalletModel.fromJson(walletJson);
  }

  @override
  Future<PosWalletEntity> withdraw({
    required int walletId,
    required double amount,
    required String statement,
    String? logDate,
  }) async {
    final payload = <String, dynamic>{
      'amount': amount,
      'statement': statement,
      if (logDate != null && logDate.isNotEmpty) 'log_date': logDate,
    };

    final response = await _remoteDataSource.withdraw(walletId, payload);
    final data = response.data ?? {};
    final walletJson = data['wallet'] as Map<String, dynamic>? ?? data;
    return PosWalletModel.fromJson(walletJson);
  }

  @override
  Future<PosWalletEntity> updateCreditLimit({
    required int walletId,
    required double? creditLimit,
  }) async {
    final payload = <String, dynamic>{'credit_limit': creditLimit};

    final response = await _remoteDataSource.updateCreditLimit(
      walletId,
      payload,
    );
    return response.data!;
  }
}
