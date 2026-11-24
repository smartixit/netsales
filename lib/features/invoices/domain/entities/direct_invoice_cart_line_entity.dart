import 'package:equatable/equatable.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';

/// مسودة بند داخل سلة الفاتورة المباشرة قبل إرسالها إلى الخادم.
///
/// مطابقة بنيوياً ونمطياً لكيان [ProcurementCartLineEntity] في وحدة طلبات التوريد:
/// - تربط كيان الباقة [PackageEntity] بعدد الكروت المختارة [voucherCount].
/// - تحسب المكافئ الورقي [sheets] وتوصيف الأوراق [sheetDescription].
/// - توفر الحسابات المالية التقديرية للسطر (إجمالي، خصم، صافي).
class DirectInvoiceCartLineEntity extends Equatable {
  const DirectInvoiceCartLineEntity({
    required this.package,
    required this.voucherCount,
    required this.sheets,
  });

  final PackageEntity package;
  final int voucherCount;
  final double sheets;

  int get packageId => package.packageId;

  /// إجمالي السطر قبل الخصم
  double get lineGrossTotal => package.packageVoucherPrice * voucherCount;

  /// إجمالي الخصم للسطر حسب نوع البيع (نقدي أو آجل)
  double lineDiscountTotal(bool isCash) {
    final unitDiscount = isCash
        ? package.cashDiscountAmount
        : package.creditDiscountAmount;
    final discount = unitDiscount * voucherCount;
    return discount > 0 ? discount : 0.0;
  }

  /// صافي السطر بعد الخصم
  double lineNetTotal(bool isCash) {
    final net = lineGrossTotal - lineDiscountTotal(isCash);
    return net > 0 ? net : 0.0;
  }

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

  DirectInvoiceCartLineEntity copyWith({
    PackageEntity? package,
    int? voucherCount,
    double? sheets,
  }) {
    return DirectInvoiceCartLineEntity(
      package: package ?? this.package,
      voucherCount: voucherCount ?? this.voucherCount,
      sheets: sheets ?? this.sheets,
    );
  }

  @override
  List<Object?> get props => [package, voucherCount, sheets];
}
