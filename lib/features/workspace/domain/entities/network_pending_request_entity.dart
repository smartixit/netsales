import 'package:netsales/core/enums/request_status.dart';
import 'package:netsales/core/enums/sale_type.dart';

/// كيان طلب التوريد المعلق ضمن ملخص مساحة عمل الشبكة (NetworkPendingRequestEntity)
/// يحقق معايير النمذجة القوية في Clean Architecture بدلاً من تمرير القواميس السائبة (Map)
class NetworkPendingRequestEntity {
  final int requestId;
  final String requestUuid;
  final int posId;
  final String posName;
  final String? saleTypeRaw;
  final String saleTypeLabel;
  final String requestDate;
  final double requestTotalAmount;
  final String statusRaw;
  final String statusLabel;

  const NetworkPendingRequestEntity({
    required this.requestId,
    required this.requestUuid,
    required this.posId,
    required this.posName,
    this.saleTypeRaw,
    required this.saleTypeLabel,
    required this.requestDate,
    required this.requestTotalAmount,
    required this.statusRaw,
    required this.statusLabel,
  });

  RequestStatus get status => RequestStatus.fromWire(statusRaw);
  SaleType get saleType => SaleType.fromWire(saleTypeRaw);
}
