import 'package:netsales/core/enums/package_discount_validity_state.dart';
import 'package:netsales/features/catalog/domain/entities/package_pos_discount_entity.dart';

class PackagePosDiscountModel extends PackagePosDiscountEntity {
  const PackagePosDiscountModel({
    required super.discountId, required super.posId,
    required super.discountCash, required super.discountCredit,
    required super.isEnabled, required super.validityState,
    super.posName, super.startDate, super.endDate, super.displayEndDate,
    super.cashPrice, super.creditPrice,
  });
  factory PackagePosDiscountModel.fromJson(Map<String,dynamic> json) {
    final pos = json['pos'] is Map
        ? Map<String,dynamic>.from(json['pos'] as Map) : <String,dynamic>{};
    int requiredInt(String key) {
      final value=json[key];
      if (value is num) return value.toInt();
      final parsed=int.tryParse(value?.toString() ?? '');
      if (parsed == null) throw FormatException('Invalid $key in discount resource');
      return parsed;
    }
    double number(dynamic value) => value is num
        ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0;
    double? optionalNumber(dynamic value) => value == null ? null
        : value is num ? value.toDouble() : double.tryParse(value.toString());
    DateTime? date(dynamic value) => value == null ? null : DateTime.tryParse(value.toString());
    final status=json['status'];
    return PackagePosDiscountModel(
      discountId: requiredInt('discount_id'), posId: requiredInt('pos_id'),
      discountCash: number(json['discount_cash']),
      discountCredit: number(json['discount_credit']),
      isEnabled: status == true || status == 1 || status == '1',
      validityState: PackageDiscountValidityState.fromWire(json['validity_state']?.toString()),
      posName: pos['pos_name']?.toString(),
      startDate: date(json['discount_start_date']),
      endDate: date(json['discount_end_date']),
      displayEndDate: json['display_end_date']?.toString(),
      cashPrice: optionalNumber(json['effective_cash_price']),
      creditPrice: optionalNumber(json['effective_credit_price']),
    );
  }
}
