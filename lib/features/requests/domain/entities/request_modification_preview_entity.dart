import 'package:netsales/features/requests/domain/entities/request_modification_line_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_item_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_removed_item_entity.dart';

class RequestModificationPreviewEntity {
  final int requestId;
  final String? requestUuid;
  final double originalTotalAmount;
  final double previewTotalAmount;
  final double grossTotalAmount;
  final double totalDiscountAmount;
  final String saleType;
  final String saleTypeLabel;
  final bool hasModifications;
  final List<RequestModificationPreviewItemEntity> items;
  final List<RequestModificationRemovedItemEntity> removedItems;

  const RequestModificationPreviewEntity({
    required this.requestId,
    this.requestUuid,
    required this.originalTotalAmount,
    required this.previewTotalAmount,
    required this.grossTotalAmount,
    required this.totalDiscountAmount,
    required this.saleType,
    required this.saleTypeLabel,
    required this.hasModifications,
    required this.items,
    required this.removedItems,
  });

  List<RequestModificationLineEntity> get approvalItems => items
      .map(
        (item) => RequestModificationLineEntity(
          packageId: item.packageId,
          voucherCount: item.voucherCount,
          pricingToken: item.pricingToken,
        ),
      )
      .toList(growable: false);
}
