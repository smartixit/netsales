import 'package:netsales/features/catalog/domain/entities/package_entity.dart';

/// Presentation-only line in the direct invoice draft cart.
class DirectInvoiceCartLine {
  final PackageEntity package;
  final int voucherCount;

  const DirectInvoiceCartLine({
    required this.package,
    required this.voucherCount,
  });

  DirectInvoiceCartLine copyWith({int? voucherCount}) {
    return DirectInvoiceCartLine(
      package: package,
      voucherCount: voucherCount ?? this.voucherCount,
    );
  }
}
