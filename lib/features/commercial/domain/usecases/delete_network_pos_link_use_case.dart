import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام فك ارتباط نقطة بيع بشبكة
class DeleteNetworkPosLinkUseCase {
  const DeleteNetworkPosLinkUseCase(this._repository);

  final CommercialRepository _repository;

  Future<void> execute(int linkId) {
    return _repository.deleteNetworkPosLink(linkId);
  }

  Future<void> call(int linkId) => execute(linkId);
}

