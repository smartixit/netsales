import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
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

  /// التوصيف اللغوي الفصيح لكمية الأوراق المعادل للكروت
  String get sheetDescription {
    final sheetSize = package.packageVoucherCount;
    if (sheetSize <= 0) return '$voucherCount كرت';
    return VoucherSheetCalculator.describe(voucherCount, sheetSize);
  }

  /// التوصيف المزدوج الكامل للبند (الأوراق والكروت)
  String get fullQuantityLabel {
    final desc = sheetDescription;
    return '$desc  •  $voucherCount كرت';
  }
}
