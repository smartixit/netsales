import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/partners/data/datasources/partners_remote_data_source.dart';
import 'package:netsales/features/partners/domain/entities/network_entity.dart';
import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';
import 'package:netsales/features/partners/domain/entities/pos_entity.dart';
import 'package:netsales/features/partners/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/partners/domain/repositories/partners_repository.dart';

/// ============================================================================
/// تطبيق مستودع الشركاء ونقاط التوزيع (PartnersRepositoryImpl)
/// ============================================================================
/// يطبق العقد الدوميني [PartnersRepository] وينسق البيانات مع مصدر البيانات البعيد.
class PartnersRepositoryImpl implements PartnersRepository {
  final PartnersRemoteDataSource _remoteDataSource;

  const PartnersRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<NetworkEntity>> getNetworks({
    int page = 1,
    int perPage = 20,
    String? search,
    String? status,
    int? governorateId,
    int? directorateId,
  }) async {
    final response = await _remoteDataSource.getNetworks(
      page: page,
      perPage: perPage,
      search: search,
      status: status,
      governorateId: governorateId,
      directorateId: directorateId,
    );

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر جلب قائمة مزودي الشبكات',
      );
    }

    return response.data ?? <NetworkEntity>[];
  }

  @override
  Future<List<PosEntity>> getPosList({
    int page = 1,
    int perPage = 20,
    String? search,
    String? status,
    int? governorateId,
    int? directorateId,
  }) async {
    final response = await _remoteDataSource.getPosList(
      page: page,
      perPage: perPage,
      search: search,
      status: status,
      governorateId: governorateId,
      directorateId: directorateId,
    );

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر جلب قائمة نقاط البيع والوكلاء',
      );
    }

    return response.data ?? <PosEntity>[];
  }

  @override
  Future<List<NetworkPosEntity>> getNetworkPosList({
    int page = 1,
    int perPage = 20,
    int? networkId,
    int? posId,
    bool? status,
    String? search,
  }) async {
    final response = await _remoteDataSource.getNetworkPosList(
      page: page,
      perPage: perPage,
      networkId: networkId,
      posId: posId,
      status: status,
      search: search,
    );

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر جلب عقود ربط الشبكات بنقاط البيع',
      );
    }

    return response.data ?? <NetworkPosEntity>[];
  }

  @override
  Future<NetworkPosEntity?> createNetworkPos({
    required int networkId,
    required String posUuid,
    bool status = true,
  }) async {
    final response = await _remoteDataSource.createNetworkPos(
      networkId: networkId,
      posUuid: posUuid,
      status: status,
    );

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر إنشاء عقد الارتباط والتوزيع',
      );
    }

    return response.data;
  }

  @override
  Future<bool> toggleNetworkPosStatus(int networkPosId) async {
    final response = await _remoteDataSource.toggleNetworkPosStatus(networkPosId);

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'فشل تغيير حالة عقد الربط',
      );
    }

    return true;
  }

  @override
  Future<bool> approveNetwork(int networkId) async {
    final response = await _remoteDataSource.approveNetwork(networkId);

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty ? response.message : 'فشل اعتماد طلب مزود الشبكة',
      );
    }

    return true;
  }

  @override
  Future<bool> rejectNetwork(int networkId, String reason) async {
    final response = await _remoteDataSource.rejectNetwork(networkId, reason);

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty ? response.message : 'فشل رفض طلب مزود الشبكة',
      );
    }

    return true;
  }

  @override
  Future<bool> approvePos(int posId) async {
    final response = await _remoteDataSource.approvePos(posId);

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty ? response.message : 'فشل اعتماد طلب نقطة البيع',
      );
    }

    return true;
  }

  @override
  Future<bool> rejectPos(int posId, String reason) async {
    final response = await _remoteDataSource.rejectPos(posId, reason);

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty ? response.message : 'فشل رفض طلب نقطة البيع',
      );
    }

    return true;
  }

  @override
  Future<PosWalletEntity?> getPosWallet({
    required int networkId,
    required int posId,
  }) async {
    final response = await _remoteDataSource.getPosWallet(
      networkId: networkId,
      posId: posId,
    );

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر جلب بيانات محفظة نقطة البيع المشتركة',
      );
    }

    return response.data;
  }

  @override
  Future<bool> transferNetworkToPos({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
  }) async {
    final response = await _remoteDataSource.transferNetworkToPos(
      networkId: networkId,
      posId: posId,
      amount: amount,
      statement: statement,
    );

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'فشل تحويل الرصيد إلى محفظة نقطة البيع',
      );
    }

    return true;
  }

  @override
  Future<bool> transferPosToNetwork({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
  }) async {
    final response = await _remoteDataSource.transferPosToNetwork(
      networkId: networkId,
      posId: posId,
      amount: amount,
      statement: statement,
    );

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'فشل استرجاع الرصيد من نقطة البيع إلى الشبكة',
      );
    }

    return true;
  }

  @override
  Future<List<PosWalletLogEntity>> getPosWalletLogs({
    required int networkId,
    required int posId,
    int page = 1,
    int perPage = 20,
  }) async {
    // First retrieve wallet to get wallet_id directly from backend
    final wallet = await getPosWallet(networkId: networkId, posId: posId);
    if (wallet == null) return <PosWalletLogEntity>[];

    final response = await _remoteDataSource.getPosWalletLogs(
      walletId: wallet.walletId,
      page: page,
      perPage: perPage,
    );

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر جلب سجل دفتر الأستاذ لمحفظة نقطة البيع',
      );
    }

    return response.data ?? <PosWalletLogEntity>[];
  }
}
