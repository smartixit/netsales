import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/workspace/presentation/models/pos_active_supply_order_view_model.dart';

class PosActiveSupplyOrderMapper {
  const PosActiveSupplyOrderMapper._();

  static PosActiveSupplyOrderViewModel? map(Iterable<RequestEntity> requests) {
    for (final request in requests) {
      final status = request.statusRaw?.toUpperCase() ?? 'PENDING';
      if (!_activeStatuses.contains(status)) continue;

      final uuid = request.requestUuid;
      final reference = uuid == null || uuid.isEmpty
          ? 'طلب توريد'
          : uuid.length > 8
          ? uuid.substring(0, 8)
          : uuid;

      return PosActiveSupplyOrderViewModel(
        request: request,
        reference: reference,
        statusLabel: request.statusLabel ?? 'نشط',
        formattedAmount: AmountFormatter.formatValue(
          request.requestTotalAmount,
        ),
        isReviewActive: status == 'PENDING' || status == 'UNDER_REVIEW',
        isReviewComplete: const {'APPROVED', 'PROCESSING', 'DELIVERED'}
            .contains(status),
        isDeliveryActive: status == 'PROCESSING',
        isDeliveryComplete: status == 'DELIVERED',
      );
    }
    return null;
  }

  static const Set<String> _activeStatuses = {
    'PENDING',
    'UNDER_REVIEW',
    'APPROVED',
    'PROCESSING',
  };
}
