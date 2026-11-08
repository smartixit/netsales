import 'package:netsales/features/requests/domain/entities/request_modification_line_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';

class PreviewRequestModificationUseCase {
  final RequestRepository _repository;

  const PreviewRequestModificationUseCase(this._repository);

  Future<RequestModificationPreviewEntity> call(
    int requestId,
    List<RequestModificationLineEntity> items,
  ) {
    return _repository.previewRequestModification(requestId, items);
  }
}
