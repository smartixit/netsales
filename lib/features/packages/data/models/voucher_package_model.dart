import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';

/// ============================================================================
/// نموذج بيانات باقة الكروت (VoucherPackageModel)
/// ============================================================================
/// يرث بالضرورة من الكيان النقي VoucherPackageEntity وفق قاعدة:
/// (Model extends Entity)، وهو المسؤول الحصري عن تسلسل JSON.
class VoucherPackageModel extends VoucherPackageEntity {
  const VoucherPackageModel({
    required super.packageId,
    required super.networkId,
    required super.packageName,
    super.packageColor,
    super.packageBalance,
    super.packageUptime,
    super.packageValidity,
    super.packageVoucherCount = 51,
    required super.packageVoucherPrice,
    required super.packageDefaultCashDiscount,
    required super.packageDefaultCreditDiscount,
    required super.status,
    super.createdBy,
    super.createdAt,
    super.updatedAt,
    super.networkName,
  });

  /// تحويل كائن JSON إلى VoucherPackageModel
  factory VoucherPackageModel.fromJson(Map<String, dynamic> json) {
    return VoucherPackageModel(
      packageId: json['package_id'] as int? ?? 0,
      networkId: json['network_id'] as int? ?? 0,
      packageName: json['package_name'] as String? ?? '',
      packageColor: json['package_color'] as String?,
      packageBalance: (json['package_balance'] as num?)?.toDouble(),
      packageUptime: json['package_uptime']?.toString(),
      packageValidity: json['package_validity']?.toString(),
      packageVoucherCount: json['package_voucher_count'] as int? ?? 51,
      packageVoucherPrice:
          (json['package_voucher_price'] as num?)?.toDouble() ?? 0.0,
      packageDefaultCashDiscount:
          (json['package_default_cash_discount'] as num?)?.toDouble() ?? 0.0,
      packageDefaultCreditDiscount:
          (json['package_default_credit_discount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as bool? ?? true,
      createdBy: json['created_by'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      networkName: json['network'] is Map<String, dynamic>
          ? (json['network'] as Map<String, dynamic>)['network_name'] as String?
          : null,
    );
  }

  /// تحويل الموديل إلى Map لطلبات الإرسال
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
