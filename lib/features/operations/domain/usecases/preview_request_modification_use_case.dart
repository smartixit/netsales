import 'package:netsales/features/operations/domain/entities/request_pricing_preview_entity.dart';
import 'package:netsales/features/operations/domain/repositories/operations_repository.dart';

/// ============================================================================
/// حالة استخدام معاينة التعديلات والتسعير السيادي لطلب التوريد
/// ============================================================================
class PreviewRequestModificationUseCase {
  final OperationsRepository _repository;

  const PreviewRequestModificationUseCase(this._repository);

  Future<RequestPricingPreviewEntity> call(
    int id, {
    required List<Map<String, dynamic>> items,
    String? saleType,
    String? requestNote,
  }) {
    return _repository.previewRequestModification(
      id,
      items: items,
      saleType: saleType,
      requestNote: requestNote,
    );
  }
}

