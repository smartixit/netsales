import 'package:netsales/features/catalog/domain/entities/package_entity.dart';

/// كيان الدومين النقي الذي يمثل التغير السعري الحاصل على باقة معينة أثناء تحديث التعرفة (PackagePriceChangeEntity)
///
/// نقي تماماً ومستقل عن أطر العرض وGetX، يُستخدم في المقارنة المالية عند تجديد صلاحية التعرفة.
class PackagePriceChangeEntity {
  const PackagePriceChangeEntity({
    required this.package,
    required this.oldBaseUnitPriceMinor,
    required this.newBaseUnitPriceMinor,
    required this.oldDiscountBasisPoints,
    required this.newDiscountBasisPoints,
    required this.oldLineTotalMinor,
    required this.newLineTotalMinor,
  });

  /// كائن الباقة المحدثة بالتعرفة الجديدة
  final PackageEntity package;

  /// السعر الأساسي للوحدة بالوحدات الصغرى قبل التحديث
  final int oldBaseUnitPriceMinor;

  /// السعر الأساسي للوحدة بالوحدات الصغرى بعد التحديث
  final int newBaseUnitPriceMinor;

  /// نقاط أساس الخصم المعتمدة قبل التحديث (Basis Points)
  final int oldDiscountBasisPoints;

  /// نقاط أساس الخصم المعتمدة بعد التحديث (Basis Points)
  final int newDiscountBasisPoints;

  /// إجمالي قيمة البند التقديري قبل التحديث
  final int oldLineTotalMinor;

  /// إجمالي قيمة البند التقديري بعد التحديث
  final int newLineTotalMinor;

  /// هل تغير السعر الأساسي للوحدة؟
  bool get hasBasePriceChanged =>
      oldBaseUnitPriceMinor != newBaseUnitPriceMinor;

  /// هل تغيرت نسبة الخصم المعتمدة؟
  bool get hasDiscountChanged =>
      oldDiscountBasisPoints != newDiscountBasisPoints;

  /// السعر الأساسي السابق مقسوماً على 100 للعرض
  double get oldBaseUnitPrice => oldBaseUnitPriceMinor / 100.0;

  /// السعر الأساسي الجديد مقسوماً على 100 للعرض
  double get newBaseUnitPrice => newBaseUnitPriceMinor / 100.0;

  /// نسبة الخصم السابقة كنسبة مئوية
  double get oldDiscountPercentage => oldDiscountBasisPoints / 100.0;

  /// نسبة الخصم الجديدة كنسبة مئوية
  double get newDiscountPercentage => newDiscountBasisPoints / 100.0;

  /// إجمالي البند السابق بالريال للعرض
  double get oldLineTotal => oldLineTotalMinor / 100.0;

  /// إجمالي البند الجديد بالريال للعرض
  double get newLineTotal => newLineTotalMinor / 100.0;
}
