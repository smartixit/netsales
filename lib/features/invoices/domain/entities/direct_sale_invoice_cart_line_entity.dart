import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';

/// مسودة بند داخل سلة الفاتورة المباشرة قبل إرسالها إلى الخادم.
class DirectSaleInvoiceCartLineEntity {
  final PackageEntity package;
  final double sheets;
  final int voucherCount;

  const DirectSaleInvoiceCartLineEntity({
    required this.package,
    required this.sheets,
    required this.voucherCount,
  });

  /// توصيف لغوي عربي دقيق ومطابق لقواعد قص وتوزيع الأوراق
  String get sheetDescription {
    final sheetSize = package.packageVoucherCount;
    if (sheetSize <= 0) return '$voucherCount كرت';
    return VoucherSheetCalculator.describe(voucherCount, sheetSize);
  }

  /// التوصيف الكامل المزدوج للبند (الأوراق والكروت)
  String get fullQuantityLabel {
    final desc = sheetDescription;
    return '$desc  •  $voucherCount كرت';
  }
}
