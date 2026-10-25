import 'package:netsales/features/partners/domain/entities/network_entity.dart';
import 'package:netsales/features/partners/domain/repositories/partners_repository.dart';

/// ============================================================================
/// حالة استخدام جلب قائمة مزودي الشبكات (GetNetworksUseCase)
/// ============================================================================
class GetNetworksUseCase {
  final PartnersRepository _repository;

  const GetNetworksUseCase(this._repository);

  Future<List<NetworkEntity>> call({
    int page = 1,
    int perPage = 20,
    String? search,
    String? status,
    int? governorateId,
    int? directorateId,
  }) {
    return _repository.getNetworks(
      page: page,
      perPage: perPage,
      search: search,
      status: status,
      governorateId: governorateId,
      directorateId: directorateId,
    );
  }
}
