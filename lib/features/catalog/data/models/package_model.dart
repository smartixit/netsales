import 'package:netsales/features/catalog/domain/entities/package_entity.dart';

/// نموذج بيانات باقة الكروت والتحويل الدقيق من وإلى JSON (Package Data Model)
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
    super.procurementBaseUnitPriceMinor,
    super.procurementCashUnitPriceMinor,
    super.procurementCreditUnitPriceMinor,
    super.procurementCashDiscountBasisPoints,
    super.procurementCreditDiscountBasisPoints,
    super.procurementPricingSnapshotToken,
    super.procurementPricingSnapshotExpiresAt,
    super.procurementIsCustomDiscount,
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

    // قراءة القيم المالية المعتمدة سيادياً والمحسوبة على الخادم حصراً
    final cashDiscountAmt =
        (json['cash_discount_amount'] as num?)?.toDouble() ?? 0.0;
    final creditDiscountAmt =
        (json['credit_discount_amount'] as num?)?.toDouble() ?? 0.0;
    final effCash = (json['effective_cash_price'] as num?)?.toDouble() ?? price;
    final effCredit =
        (json['effective_credit_price'] as num?)?.toDouble() ?? price;

    final procurement = json['procurement_pricing'] is Map<String, dynamic>
        ? json['procurement_pricing'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return PackageModel(
      packageId: (json['package_id'] as num?)?.toInt() ?? 0,
      networkId: (json['network_id'] as num?)?.toInt() ?? 0,
      packageName: json['package_name']?.toString() ?? '',
      packageColor: json['package_color']?.toString(),
      packageBalance: (json['package_balance'] as num?)?.toInt() ?? 0,
      packageUptime: (json['package_uptime'] as num?)?.toInt(),
      packageValidity: (json['package_validity'] as num?)?.toInt(),
      packageVoucherCount:
          (json['package_voucher_count'] as num?)?.toInt() ?? 1,
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
      procurementBaseUnitPriceMinor:
          (procurement['base_unit_price_minor'] as num?)?.toInt(),
      procurementCashUnitPriceMinor:
          (procurement['cash_effective_unit_price_minor'] as num?)?.toInt(),
      procurementCreditUnitPriceMinor:
          (procurement['credit_effective_unit_price_minor'] as num?)?.toInt(),
      procurementCashDiscountBasisPoints:
          (procurement['cash_discount_basis_points'] as num?)?.toInt(),
      procurementCreditDiscountBasisPoints:
          (procurement['credit_discount_basis_points'] as num?)?.toInt(),
      procurementPricingSnapshotToken: procurement['pricing_snapshot_token']
          ?.toString(),
      procurementPricingSnapshotExpiresAt: DateTime.tryParse(
        procurement['pricing_snapshot_expires_at']?.toString() ?? '',
      ),
      procurementIsCustomDiscount: procurement['is_custom_discount'] is bool
          ? procurement['is_custom_discount'] as bool
          : (procurement['is_custom'] is bool
              ? procurement['is_custom'] as bool
              : false),
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
