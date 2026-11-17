import 'package:netsales/features/catalog/domain/entities/effective_package_discount_entity.dart';

/// نموذج بيانات الخصم الفعلي والتحويل من استجابة خادم Laravel
class EffectivePackageDiscountModel extends EffectivePackageDiscountEntity {
  const EffectivePackageDiscountModel({
    super.packageId,
    super.isEffectiveNow,
    required super.discountCash,
    required super.discountCredit,
    required super.isCustom,
    required super.originalPackagePrice,
    required super.effectiveCashPrice,
    required super.effectiveCreditPrice,
    required super.cashSavings,
    required super.creditSavings,
  });

  factory EffectivePackageDiscountModel.fromJson(Map<String, dynamic> json) {
    return EffectivePackageDiscountModel(
      packageId: (json['package_id'] as num?)?.toInt(),
      isEffectiveNow: json['is_effective_now'] as bool? ?? true,
      discountCash: (json['discount_cash'] as num?)?.toDouble() ?? 0.0,
      discountCredit: (json['discount_credit'] as num?)?.toDouble() ?? 0.0,
      isCustom: json['is_custom'] as bool? ?? json['discount_id'] != null,
      originalPackagePrice:
          (json['original_package_price'] as num?)?.toDouble() ?? 0.0,
      effectiveCashPrice:
          (json['effective_cash_price'] as num?)?.toDouble() ?? 0.0,
      effectiveCreditPrice:
          (json['effective_credit_price'] as num?)?.toDouble() ?? 0.0,
      cashSavings: (json['cash_savings'] as num?)?.toDouble() ?? 0.0,
      creditSavings: (json['credit_savings'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'package_id': packageId,
      'is_effective_now': isEffectiveNow,
      'discount_cash': discountCash,
      'discount_credit': discountCredit,
      'is_custom': isCustom,
      'original_package_price': originalPackagePrice,
      'effective_cash_price': effectiveCashPrice,
      'effective_credit_price': effectiveCreditPrice,
      'cash_savings': cashSavings,
      'credit_savings': creditSavings,
    };
  }
}

