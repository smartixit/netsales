import 'package:netsales/core/enums/request_status.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/features/requests/domain/entities/request_item_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_summary_entity.dart';

/// كيان دورة حياة طلب الكروت والتوريد (Procurement Request Entity)
class RequestEntity {
  final int requestId;
  final int networkId;
  final int posId;
  final String? requestUuid;
  final String? saleTypeRaw;
  final String? saleTypeLabel;
  final double requestTotalAmount;
  final String? requestDate;
  final String? statusRaw;
  final String? statusLabel;
  final int? createdBy;
  final String? reviewedBy;
  final String? reviewDate;
  final String? requestNote;
  final int? invoiceId;
  final String? invoiceUuid;
  final String? networkName;
  final String? networkPhone;
  final String? networkLogo;
  final String? posName;
  final String? posPhone;
  final String? posLogo;
  final String? createdByName;
  final String? reviewedByName;
  final List<RequestItemEntity> items;
  final RequestModificationSummaryEntity? modificationSummary;
  final String? createdAt;
  final String? updatedAt;

  const RequestEntity({
    required this.requestId,
    required this.networkId,
    required this.posId,
    this.requestUuid,
    this.saleTypeRaw,
    this.saleTypeLabel,
    required this.requestTotalAmount,
    this.requestDate,
    this.statusRaw,
    this.statusLabel,
    this.createdBy,
    this.reviewedBy,
    this.reviewDate,
    this.requestNote,
    this.invoiceId,
    this.invoiceUuid,
    this.networkName,
    this.networkPhone,
    this.networkLogo,
    this.posName,
    this.posPhone,
    this.posLogo,
    this.createdByName,
    this.reviewedByName,
    this.items = const [],
    this.modificationSummary,
    this.createdAt,
    this.updatedAt,
  });

  RequestStatus get status => RequestStatus.fromWire(statusRaw);
  SaleType get saleType => SaleType.fromWire(saleTypeRaw);

  bool get isPending => status == RequestStatus.pending;
  bool get isApproved => status == RequestStatus.approved;
  bool get isRejected => status == RequestStatus.rejected;
  bool get isCancelled => status == RequestStatus.cancelled;

  /// إجمالي عدد الكروت لكافة بنود الطلب
  int get totalVouchers =>
      items.fold<int>(0, (sum, item) => sum + item.voucherCount);

  /// إجمالي عدد الأوراق المقابلة لكافة بنود الطلب
  double get totalSheets => items.fold<double>(0.0, (sum, item) {
    final sheetSize = item.voucherPackage?.packageVoucherCount ?? 100;
    return sum + (sheetSize > 0 ? item.voucherCount / sheetSize : 0.0);
  });
}
