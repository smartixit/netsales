import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';

class VoucherPackageModel extends VoucherPackageEntity {
  const VoucherPackageModel({
    required super.packageId,
    required super.networkId,
    required super.packageName,
    super.packageColor,
    required super.packageBalance,
    super.packageUptime,
    super.packageValidity,
    required super.packageVoucherCount,
    required super.packageVoucherPrice,
    required super.packageDefaultCashDiscount,
    required super.packageDefaultCreditDiscount,
    required super.cashDiscountAmount,
    required super.creditDiscountAmount,
    required super.effectiveCashPrice,
    required super.effectiveCreditPrice,
    required super.status,
    super.createdBy,
    super.createdAt,
    super.updatedAt,
    super.networkName,
  });

  factory VoucherPackageModel.fromJson(Map<String, dynamic> json) {
    String? netName;
    if (json['network'] is Map<String, dynamic>) {
      netName = json['network']['network_name'] as String?;
    }

    final rawCreatedAt = json['created_at']?.toString();
    final rawUpdatedAt = json['updated_at']?.toString();

    return VoucherPackageModel(
      packageId: (json['package_id'] as num?)?.toInt() ?? 0,
      networkId: (json['network_id'] as num?)?.toInt() ?? 0,
      packageName: json['package_name']?.toString() ?? '',
      packageColor: json['package_color']?.toString(),
      packageBalance: (json['package_balance'] as num?)?.toDouble() ?? 0.0,
      packageUptime: (json['package_uptime'] as num?)?.toInt(),
      packageValidity: (json['package_validity'] as num?)?.toInt(),
      packageVoucherCount: (json['package_voucher_count'] as num?)?.toInt() ?? 1,
      packageVoucherPrice:
          (json['package_voucher_price'] as num?)?.toDouble() ?? 0.0,
      packageDefaultCashDiscount:
          (json['package_default_cash_discount'] as num?)?.toDouble() ?? 0.0,
      packageDefaultCreditDiscount:
          (json['package_default_credit_discount'] as num?)?.toDouble() ?? 0.0,
      cashDiscountAmount:
          (json['cash_discount_amount'] as num?)?.toDouble() ?? 0.0,
      creditDiscountAmount:
          (json['credit_discount_amount'] as num?)?.toDouble() ?? 0.0,
      effectiveCashPrice:
          (json['effective_cash_price'] as num?)?.toDouble() ??
          ((json['package_voucher_price'] as num?)?.toDouble() ?? 0.0),
      effectiveCreditPrice:
          (json['effective_credit_price'] as num?)?.toDouble() ??
          ((json['package_voucher_price'] as num?)?.toDouble() ?? 0.0),
      status: json['status'] is bool
          ? json['status'] as bool
          : (json['status'] == 1 || json['status'] == '1'),
      createdBy: (json['created_by'] as num?)?.toInt(),
      createdAt: rawCreatedAt != null ? DateTime.tryParse(rawCreatedAt) : null,
      updatedAt: rawUpdatedAt != null ? DateTime.tryParse(rawUpdatedAt) : null,
      networkName: netName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'package_id': packageId,
      'network_id': networkId,
      'package_name': packageName,
      'package_color': packageColor,
      'package_balance': packageBalance,
      'package_uptime': packageUptime,
      'package_validity': packageValidity,
      'package_voucher_count': packageVoucherCount,
      'package_voucher_price': packageVoucherPrice,
      'package_default_cash_discount': packageDefaultCashDiscount,
      'package_default_credit_discount': packageDefaultCreditDiscount,
      'status': status,
    };
  }
}

