import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/workspace/presentation/models/pos_network_package_view_model.dart';

class PosNetworkPackageMapper {
  const PosNetworkPackageMapper._();

  static List<PosNetworkPackageViewModel> map(
    Iterable<PackageEntity> packages,
  ) {
    return List.unmodifiable(packages.map((package) {
      final discount = package.packageDefaultCashDiscount > 0
          ? '${package.packageDefaultCashDiscount.toStringAsFixed(0)}%'
          : '';
      final specifications = [
        if (package.uptimeDisplay.isNotEmpty) package.uptimeDisplay,
        if (package.validityDisplay.isNotEmpty) package.validityDisplay,
      ].join(' • ');

      return PosNetworkPackageViewModel(
        packageId: package.packageId,
        name: package.packageName,
        discountLabel: discount,
        specifications: specifications,
        supplyPrice: AmountFormatter.formatValue(package.effectiveCashPrice),
        retailPrice: AmountFormatter.formatValue(package.packageVoucherPrice),
      );
    }));
  }
}
