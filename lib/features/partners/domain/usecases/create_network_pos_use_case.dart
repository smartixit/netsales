import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';
import 'package:netsales/features/partners/domain/repositories/partners_repository.dart';

/// ============================================================================
/// حالة استخدام إنشاء وتوثيق عقد ارتباط وتوزيع (CreateNetworkPosUseCase)
/// ============================================================================
/// تنشئ علاقة ربط بين شبكة ونقطة بيع، وتوثق الشراكة في النظام تلقائياً.
class CreateNetworkPosUseCase {
  final PartnersRepository _repository;

  const CreateNetworkPosUseCase(this._repository);

  Future<NetworkPosEntity?> call({
    required int networkId,
    required String posUuid,
    bool status = true,
  }) {
    return _repository.createNetworkPos(
      networkId: networkId,
      posUuid: posUuid,
      status: status,
    );
  }
}

