import 'package:netsales/features/catalog/domain/entities/package_entity.dart';

/// سطر باقة في سلة إنشاء الفاتورة المباشرة
///
/// يربط كيان الباقة المعروضة بالكمية المحددة من الكروت دون حسابات أسعار محلية.
class DirectInvoiceCartLineEntity {
  final PackageEntity package;
  final int voucherCount;

  const DirectInvoiceCartLineEntity({
    required this.package,
    required this.voucherCount,
  });

  DirectInvoiceCartLineEntity copyWith({
    PackageEntity? package,
    int? voucherCount,
  }) {
    return DirectInvoiceCartLineEntity(
      package: package ?? this.package,
      voucherCount: voucherCount ?? this.voucherCount,
    );
  }
}
