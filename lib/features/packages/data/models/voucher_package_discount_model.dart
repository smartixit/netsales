import 'package:netsales/features/packages/domain/entities/voucher_package_discount_entity.dart';

/// ============================================================================
/// نموذج بيانات خصم باقة الكروت المخصص (VoucherPackageDiscountModel)
/// ============================================================================
/// يرث بالضرورة من الكيان النقي VoucherPackageDiscountEntity وفق قاعدة:
/// (Model extends Entity)، وهو المسؤول الحصري عن تسلسل JSON.
class VoucherPackageDiscountModel extends VoucherPackageDiscountEntity {
  const VoucherPackageDiscountModel({
    required super.discountId,
    required super.networkId,
    required super.posId,
    required super.packageId,
    required super.discountCash,
    required super.discountCredit,
    required super.status,
    super.createdBy,
    super.createdAt,
    super.updatedAt,
    super.networkName,
    super.posName,
    super.packageName,
    super.originalPackagePrice,
    super.effectiveCashPrice,
    super.effectiveCreditPrice,
    super.cashSavings,
    super.creditSavings,
  });

  /// تحويل كائن JSON إلى VoucherPackageDiscountModel
  factory VoucherPackageDiscountModel.fromJson(Map<String, dynamic> json) {
    String? netName;
    if (json['network'] is Map<String, dynamic>) {
      netName =
          (json['network'] as Map<String, dynamic>)['network_name'] as String?;
    }

    String? pName;
    if (json['pos'] is Map<String, dynamic>) {
      pName = (json['pos'] as Map<String, dynamic>)['pos_name'] as String?;
    }

    String? pkgName;
    if (json['voucher_package'] is Map<String, dynamic>) {
      final pkgMap = json['voucher_package'] as Map<String, dynamic>;
      pkgName = pkgMap['package_name'] as String?;
    }

    return VoucherPackageDiscountModel(
      discountId: json['discount_id'] as int? ?? 0,
      networkId: json['network_id'] as int? ?? 0,
      posId: json['pos_id'] as int? ?? 0,
      packageId: json['package_id'] as int? ?? 0,
      discountCash: (json['discount_cash'] as num?)?.toDouble() ?? 0.0,
      discountCredit: (json['discount_credit'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as bool? ?? true,
      createdBy: json['created_by'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      networkName: netName,
      posName: pName,
      packageName: pkgName,
      // Server-authoritative derived monetary values (Display-Only, AGENTS.md §34)
      originalPackagePrice:
          (json['original_package_price'] as num?)?.toDouble(),
      effectiveCashPrice: (json['effective_cash_price'] as num?)?.toDouble(),
      effectiveCreditPrice:
          (json['effective_credit_price'] as num?)?.toDouble(),
      cashSavings: (json['cash_savings'] as num?)?.toDouble(),
      creditSavings: (json['credit_savings'] as num?)?.toDouble(),
    );
  }

  /// تحويل الموديل إلى Map لطلبات الإرسال
  Map<String, dynamic> toJson() {
    return {
      'discount_id': discountId,
      'network_id': networkId,
      'pos_id': posId,
      'package_id': packageId,
      'discount_cash': discountCash,
      'discount_credit': discountCredit,
      'status': status,
    };
  }
}
