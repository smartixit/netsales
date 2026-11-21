import 'package:netsales/core/enums/request_status.dart';

/// A pending procurement request included in the network workspace overview.
class NetworkPendingRequestEntity {
  const NetworkPendingRequestEntity({
    required this.requestId,
    required this.requestUuid,
    required this.posId,
    required this.posName,
    this.saleTypeLabel,
    required this.requestDate,
    required this.requestTotalAmount,
    required this.statusRaw,
    required this.statusLabel,
  });

  final int requestId;
  final String requestUuid;
  final int posId;
  final String posName;
  final String? saleTypeLabel;
  final String requestDate;
  final String requestTotalAmount;
  final String statusRaw;
  final String statusLabel;

  RequestStatus get status => RequestStatus.fromWire(statusRaw);
}
