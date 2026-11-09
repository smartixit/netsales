import 'package:netsales/features/catalog/domain/entities/package_entity.dart';

/// Presentation-only line in the direct invoice draft cart.
class DirectInvoiceCartLineEntity {
  final PackageEntity package;
  final int voucherCount;

  const DirectInvoiceCartLineEntity({
    required this.package,
    required this.voucherCount,
  });

  DirectInvoiceCartLineEntity copyWith({int? voucherCount}) {
    return DirectInvoiceCartLineEntity(
      package: package,
      voucherCount: voucherCount ?? this.voucherCount,
    );
  }
}
