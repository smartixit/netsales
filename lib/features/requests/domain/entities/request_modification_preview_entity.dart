import 'package:netsales/features/requests/domain/entities/request_modification_line_entity.dart';

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

class RequestModificationPreviewItemEntity {
  final int packageId;
  final String packageName;
  final String? packageCategory;
  final int voucherCount;
  final double voucherPrice;
  final double itemDiscount;
  final double itemTotalAmount;
  final double grossTotalAmount;
  final double discountAmount;
  final String source;
  final String? pricingToken;
  final String changeType;
  final int? originalVoucherCount;

  const RequestModificationPreviewItemEntity({
    required this.packageId,
    required this.packageName,
    this.packageCategory,
    required this.voucherCount,
    required this.voucherPrice,
    required this.itemDiscount,
    required this.itemTotalAmount,
    required this.grossTotalAmount,
    required this.discountAmount,
    required this.source,
    this.pricingToken,
    required this.changeType,
    this.originalVoucherCount,
  });
}

class RequestModificationRemovedItemEntity {
  final int packageId;
  final String packageName;
  final int originalVoucherCount;
  final double voucherPrice;
  final double itemDiscount;
  final double originalItemTotal;

  const RequestModificationRemovedItemEntity({
    required this.packageId,
    required this.packageName,
    required this.originalVoucherCount,
    required this.voucherPrice,
    required this.itemDiscount,
    required this.originalItemTotal,
  });
}
