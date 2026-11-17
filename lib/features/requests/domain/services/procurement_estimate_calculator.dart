import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/requests/domain/entities/procurement_cart_line_entity.dart';

/// Calculates non-binding POS procurement display estimates from current API snapshots.
class ProcurementEstimateCalculator {
  const ProcurementEstimateCalculator();

  bool hasCurrentSnapshots(Iterable<PackageEntity> packages, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    var foundPackage = false;
    for (final package in packages) {
      foundPackage = true;
      if (!_hasCurrentSnapshot(package, currentTime)) return false;
    }
    return foundPackage;
  }

  int? calculateLineTotalMinor(
    PackageEntity package,
    int quantity,
    SaleType saleType, {
    DateTime? now,
  }) {
    if (quantity <= 0 || !_hasCurrentSnapshot(package, now ?? DateTime.now())) {
      return null;
    }
    final basePriceMinor = package.procurementBaseUnitPriceMinor!;
    final discountBasisPoints = saleType == SaleType.cash
        ? package.procurementCashDiscountBasisPoints!
        : package.procurementCreditDiscountBasisPoints!;
    final grossMinor = basePriceMinor * quantity;
    final discountMinor = (grossMinor * discountBasisPoints + 5000) ~/ 10000;
    return grossMinor - discountMinor;
  }

  (int, int, int)? calculateCartTotalsMinor(
    Iterable<ProcurementCartLineEntity> lines,
    SaleType saleType, {
    DateTime? now,
  }) {
    final cartLines = lines.toList(growable: false);
    if (cartLines.isEmpty ||
        !hasCurrentSnapshots(cartLines.map((line) => line.package), now: now)) {
      return null;
    }

    var grossTotalMinor = 0;
    var discountTotalMinor = 0;
    var netTotalMinor = 0;

    for (final line in cartLines) {
      final basePriceMinor = line.package.procurementBaseUnitPriceMinor!;
      final discountBasisPoints = saleType == SaleType.cash
          ? line.package.procurementCashDiscountBasisPoints!
          : line.package.procurementCreditDiscountBasisPoints!;
      final lineGrossMinor = basePriceMinor * line.voucherCount;
      final lineDiscountMinor =
          (lineGrossMinor * discountBasisPoints + 5000) ~/ 10000;
      grossTotalMinor += lineGrossMinor;
      discountTotalMinor += lineDiscountMinor;
      netTotalMinor += lineGrossMinor - lineDiscountMinor;
    }

    return (grossTotalMinor, discountTotalMinor, netTotalMinor);
  }

  bool _hasCurrentSnapshot(PackageEntity package, DateTime now) {
    final token = package.procurementPricingSnapshotToken;
    final expiresAt = package.procurementPricingSnapshotExpiresAt;
    return package.procurementBaseUnitPriceMinor != null &&
        package.procurementCashDiscountBasisPoints != null &&
        package.procurementCreditDiscountBasisPoints != null &&
        token != null &&
        token.isNotEmpty &&
        expiresAt != null &&
        now.isBefore(expiresAt);
  }
}
