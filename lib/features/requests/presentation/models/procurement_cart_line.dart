import 'package:netsales/features/catalog/domain/entities/package_entity.dart';

/// مسودة بند داخل سلة طلب التوريد قبل إرسالها إلى Laravel.
class ProcurementCartLine {
  final PackageEntity package;
  final double sheets;
  final int voucherCount;

  const ProcurementCartLine({
    required this.package,
    required this.sheets,
    required this.voucherCount,
  });

  String get sheetsLabel => sheets == sheets.roundToDouble()
      ? sheets.toInt().toString()
      : sheets.toString();
}
