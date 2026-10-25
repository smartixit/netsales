import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';
import 'package:netsales/features/partners/domain/repositories/partners_repository.dart';

/// ============================================================================
/// حالة استخدام جلب قائمة عقود ربط الشبكات بنقاط البيع (GetNetworkPosListUseCase)
/// ============================================================================
class GetNetworkPosListUseCase {
  final PartnersRepository _repository;

  const GetNetworkPosListUseCase(this._repository);

  Future<List<NetworkPosEntity>> call({
    int page = 1,
    int perPage = 20,
    int? networkId,
    int? posId,
    bool? status,
    String? search,
  }) {
    return _repository.getNetworkPosList(
      page: page,
      perPage: perPage,
      networkId: networkId,
      posId: posId,
      status: status,
      search: search,
    );
  }
}
