import 'package:netsales/core/enums/request_status.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/workspace/presentation/models/pos_active_supply_order_view_model.dart';

class PosActiveSupplyOrderMapper {
  const PosActiveSupplyOrderMapper._();

  static PosActiveSupplyOrderViewModel? map(Iterable<RequestEntity> requests) {
    for (final request in requests) {
      // Only the API's defined PENDING state is an active, unapproved order.
      // Unknown or future wire values must not be guessed as PENDING.
      if (request.status != RequestStatus.pending) continue;

      return PosActiveSupplyOrderViewModel(
        request: request,
        reference: request.displayReference,
        statusPresentation: EnumPresentationRegistry.resolveRequestStatus(
          request.status,
          serverLabel: request.statusLabel,
        ),
        formattedAmount: AmountFormatter.formatValue(
          request.requestTotalAmount,
        ),
      );
    }
    return null;
  }
}
