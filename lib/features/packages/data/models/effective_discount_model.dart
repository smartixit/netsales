import 'package:netsales/features/packages/domain/entities/effective_discount_entity.dart';

/// ============================================================================
/// نموذج بيانات الخصم الفعلي المحتسب (EffectiveDiscountModel)
/// ============================================================================
/// يرث بالضرورة من الكيان النقي EffectiveDiscountEntity وفق قاعدة:
/// (Model extends Entity)، وهو المسؤول عن تسلسل JSON لخدمة احتساب الخصم الفعلي.
class EffectiveDiscountModel extends EffectiveDiscountEntity {
  const EffectiveDiscountModel({
    required super.discountCash,
    required super.discountCredit,
    required super.isCustom,
  });

  /// تحويل كائن JSON إلى EffectiveDiscountModel
  factory EffectiveDiscountModel.fromJson(Map<String, dynamic> json) {
    return EffectiveDiscountModel(
      discountCash: (json['discount_cash'] as num?)?.toDouble() ?? 0.0,
      discountCredit: (json['discount_credit'] as num?)?.toDouble() ?? 0.0,
      isCustom: json['is_custom'] as bool? ?? false,
    );
  }

  /// تحويل الموديل إلى Map
  Map<String, dynamic> toJson() {
    return {
      'discount_cash': discountCash,
      'discount_credit': discountCredit,
      'is_custom': isCustom,
    };
  }
}
