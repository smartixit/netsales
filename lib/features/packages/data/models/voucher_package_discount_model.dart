import 'package:netsales/features/packages/domain/entities/voucher_package_discount_entity.dart';

class VoucherPackageDiscountModel extends VoucherPackageDiscountEntity {
  const VoucherPackageDiscountModel({
    required super.discountId,
    required super.networkId,
    required super.posId,
    required super.packageId,
    required super.discountCash,
    required super.discountCredit,
    required super.status,
    super.discountStartDate,
    super.discountEndDate,
    super.displayEndDate,
    required super.validityState,
    required super.isEffectiveNow,
    super.originalPackagePrice,
    super.effectiveCashPrice,
    super.effectiveCreditPrice,
    super.cashSavings,
    super.creditSavings,
    super.networkName,
    super.posName,
    super.packageName,
    super.createdAt,
    super.updatedAt,
  });

  factory VoucherPackageDiscountModel.fromJson(Map<String, dynamic> json) {
    String? netName;
    if (json['network'] is Map<String, dynamic>) {
      netName = json['network']['network_name'] as String?;
    }

    String? pointName;
    if (json['pos'] is Map<String, dynamic>) {
      pointName = json['pos']['pos_name'] as String?;
    }

    String? pkgName;
    if (json['voucher_package'] is Map<String, dynamic>) {
      pkgName = json['voucher_package']['package_name'] as String?;
    } else if (json['package'] is Map<String, dynamic>) {
      pkgName = json['package']['package_name'] as String?;
    }

    final rawStart = json['discount_start_date']?.toString();
    final rawEnd = json['discount_end_date']?.toString();
    final rawCreatedAt = json['created_at']?.toString();
    final rawUpdatedAt = json['updated_at']?.toString();

    return VoucherPackageDiscountModel(
      discountId: (json['discount_id'] as num?)?.toInt() ?? 0,
      networkId: (json['network_id'] as num?)?.toInt() ?? 0,
      posId: (json['pos_id'] as num?)?.toInt() ?? 0,
      packageId: (json['package_id'] as num?)?.toInt() ?? 0,
      discountCash: (json['discount_cash'] as num?)?.toDouble() ?? 0.0,
      discountCredit: (json['discount_credit'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] is bool
          ? json['status'] as bool
          : (json['status'] == 1 || json['status'] == '1'),
      discountStartDate: rawStart != null ? DateTime.tryParse(rawStart) : null,
      discountEndDate: rawEnd != null ? DateTime.tryParse(rawEnd) : null,
      displayEndDate: json['display_end_date']?.toString(),
      validityState: json['validity_state']?.toString() ?? 'ACTIVE',
      isEffectiveNow: json['is_effective_now'] is bool
          ? json['is_effective_now'] as bool
          : (json['is_effective_now'] == 1 ||
              json['is_effective_now'] == '1' ||
              json['is_effective_now'] == 'true'),
      originalPackagePrice:
          (json['original_package_price'] as num?)?.toDouble(),
      effectiveCashPrice: (json['effective_cash_price'] as num?)?.toDouble(),
      effectiveCreditPrice:
          (json['effective_credit_price'] as num?)?.toDouble(),
      cashSavings: (json['cash_savings'] as num?)?.toDouble(),
      creditSavings: (json['credit_savings'] as num?)?.toDouble(),
      networkName: netName,
      posName: pointName,
      packageName: pkgName,
      createdAt: rawCreatedAt != null ? DateTime.tryParse(rawCreatedAt) : null,
      updatedAt: rawUpdatedAt != null ? DateTime.tryParse(rawUpdatedAt) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'discount_id': discountId,
      'network_id': networkId,
      'pos_id': posId,
      'package_id': packageId,
      'discount_cash': discountCash,
      'discount_credit': discountCredit,
      'status': status,
      'discount_start_date': discountStartDate?.toIso8601String(),
      'discount_end_date': discountEndDate?.toIso8601String(),
    };
  }
}

