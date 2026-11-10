import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';

/// مسودة بند داخل سلة طلب التوريد قبل إرسالها إلى Laravel.
class ProcurementCartLineEntity {
  final PackageEntity package;
  final double sheets;
  final int voucherCount;

  const ProcurementCartLineEntity({
    required this.package,
    required this.sheets,
    required this.voucherCount,
  });

  /// توصيف لغوي عربي دقيق ومطابق لقواعد قص وتوزيع الأوراق
  /// مثال: "ورقة واحدة"، "ورقتان ونصف"، "ورقة و 10 كروت"
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

  @Deprecated('استخدم sheetDescription أو fullQuantityLabel لضمان الدقة اللغوية وتجنب الكسور العشرية غير المنطقية')
  String get sheetsLabel => sheetDescription;
}
