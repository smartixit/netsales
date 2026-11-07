import 'package:netsales/features/catalog/domain/entities/package_entity.dart';

/// كيان بند طلب الكروت (Voucher Request Item Entity)
class RequestItemEntity {
  final int itemId;
  final int requestId;
  final int packageId;
  final double voucherPrice;
  final int voucherCount;
  final double itemDiscount;
  final double itemTotalAmount;
  final String? createdAt;
  final String? updatedAt;
  final PackageEntity? voucherPackage;

  const RequestItemEntity({
    required this.itemId,
    required this.requestId,
    required this.packageId,
    required this.voucherPrice,
    required this.voucherCount,
    this.itemDiscount = 0.0,
    required this.itemTotalAmount,
    this.createdAt,
    this.updatedAt,
    this.voucherPackage,
  });
}

