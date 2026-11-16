import 'package:netsales/features/requests/domain/entities/request_entity.dart';

class PosActiveSupplyOrderViewModel {
  const PosActiveSupplyOrderViewModel({
    required this.request,
    required this.reference,
    required this.statusLabel,
    required this.formattedAmount,
    required this.isReviewActive,
    required this.isReviewComplete,
    required this.isDeliveryActive,
    required this.isDeliveryComplete,
  });

  final RequestEntity request;
  final String reference;
  final String statusLabel;
  final String formattedAmount;
  final bool isReviewActive;
  final bool isReviewComplete;
  final bool isDeliveryActive;
  final bool isDeliveryComplete;
}
