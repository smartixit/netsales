import 'package:netsales/features/catalog/data/models/package_model.dart';
import 'package:netsales/features/requests/domain/entities/request_item_entity.dart';

/// نموذج بيانات بند طلب الكروت للتحويل من وإلى JSON
class RequestItemModel extends RequestItemEntity {
  const RequestItemModel({
    required super.itemId,
    required super.requestId,
    required super.packageId,
    required super.voucherPrice,
    required super.voucherCount,
    super.itemDiscount = 0.0,
    required super.itemTotalAmount,
    super.createdAt,
    super.updatedAt,
    super.voucherPackage,
  });

  factory RequestItemModel.fromJson(Map<String, dynamic> json) {
    return RequestItemModel(
      itemId: json['item_id'] as int? ?? 0,
      requestId: json['request_id'] as int? ?? 0,
      packageId: json['package_id'] as int? ?? 0,
      voucherPrice: (json['voucher_price'] as num?)?.toDouble() ?? 0.0,
      voucherCount: json['voucher_count'] as int? ?? 1,
      itemDiscount: (json['item_discount'] as num?)?.toDouble() ?? 0.0,
      itemTotalAmount: (json['item_total_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      voucherPackage: json['voucher_package'] is Map<String, dynamic>
          ? PackageModel.fromJson(
              json['voucher_package'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'package_id': packageId,
      'voucher_count': voucherCount,
    };
  }
}

