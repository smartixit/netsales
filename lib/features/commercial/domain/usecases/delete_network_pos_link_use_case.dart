import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام فك الارتباط التجاري
class DeleteNetworkPosLinkUseCase {
  const DeleteNetworkPosLinkUseCase(this._repository);

  final CommercialRepository _repository;

  Future<void> call(int networkPosId) {
    return _repository.deleteNetworkPosLink(networkPosId);
  }
}
