import 'package:netsales/features/catalog/domain/entities/package_entity.dart';

/// نموذج بيانات باقة الكروت والتحويل من وإلى JSON
class PackageModel extends PackageEntity {
  const PackageModel({
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

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    String? netName;
    if (json['network'] is Map<String, dynamic>) {
      netName = json['network']['network_name']?.toString();
    }

    final rawCreatedAt = json['created_at']?.toString();
    final rawUpdatedAt = json['updated_at']?.toString();

    final price = (json['package_voucher_price'] as num?)?.toDouble() ?? 0.0;
    final cashDiscount =
        (json['package_default_cash_discount'] as num?)?.toDouble() ?? 0.0;
    final creditDiscount =
        (json['package_default_credit_discount'] as num?)?.toDouble() ?? 0.0;

    // Use server values if present, otherwise compute fallback display representation
    final cashDiscountAmt =
        (json['cash_discount_amount'] as num?)?.toDouble() ??
        ((price * cashDiscount) / 100);
    final creditDiscountAmt =
        (json['credit_discount_amount'] as num?)?.toDouble() ??
        ((price * creditDiscount) / 100);
    final effCash =
        (json['effective_cash_price'] as num?)?.toDouble() ??
        (price - cashDiscountAmt);
    final effCredit =
        (json['effective_credit_price'] as num?)?.toDouble() ??
        (price - creditDiscountAmt);

    return PackageModel(
      packageId: (json['package_id'] as num?)?.toInt() ?? 0,
      networkId: (json['network_id'] as num?)?.toInt() ?? 0,
      packageName: json['package_name']?.toString() ?? '',
      packageColor: json['package_color']?.toString(),
      packageBalance: (json['package_balance'] as num?)?.toDouble() ?? 0.0,
      packageUptime: (json['package_uptime'] as num?)?.toInt(),
      packageValidity: (json['package_validity'] as num?)?.toInt(),
      packageVoucherCount: (json['package_voucher_count'] as num?)?.toInt() ?? 1,
      packageVoucherPrice: price,
      packageDefaultCashDiscount: cashDiscount,
      packageDefaultCreditDiscount: creditDiscount,
      cashDiscountAmount: cashDiscountAmt,
      creditDiscountAmount: creditDiscountAmt,
      effectiveCashPrice: effCash,
      effectiveCreditPrice: effCredit,
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

