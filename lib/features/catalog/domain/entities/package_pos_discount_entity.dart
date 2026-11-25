import 'package:netsales/core/enums/package_discount_activation_status.dart';
import 'package:netsales/core/enums/package_discount_validity_state.dart';

class PackagePosDiscountEntity {
  const PackagePosDiscountEntity({
    required this.discountId, required this.posId, this.packageId, required this.discountCash,
    required this.discountCredit, required this.isEnabled,
    required this.validityState, this.posName, this.startDate, this.endDate,
    this.displayEndDate, this.cashPrice, this.creditPrice,
  });
  final int discountId, posId;
  final int? packageId;
  final String? posName, displayEndDate;
  final double discountCash, discountCredit;
  final bool isEnabled;
  PackageDiscountActivationStatus get activationStatus =>
      PackageDiscountActivationStatus.fromValue(isEnabled);
  final PackageDiscountValidityState validityState;
  final DateTime? startDate, endDate;
  /// Final prices are supplied by Laravel; Flutter must never recalculate them.
  final double? cashPrice, creditPrice;
}
