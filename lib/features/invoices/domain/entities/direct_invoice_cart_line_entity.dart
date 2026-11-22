import 'package:equatable/equatable.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';

/// سطر سلة الفاتورة المباشرة: يربط الباقة بعدد الكروت المختارة وحساباتها المالية التقديرية
class DirectInvoiceCartLineEntity extends Equatable {
  const DirectInvoiceCartLineEntity({
    required this.package,
    required this.voucherCount,
  });

  final PackageEntity package;
  final int voucherCount;

  int get packageId => package.packageId;

  /// إجمالي السطر قبل الخصم
  double get lineGrossTotal => package.resolvedBasePrice * voucherCount;

  /// إجمالي الخصم للسطر حسب نوع البيع (نقدي أو آجل)
  double lineDiscountTotal(bool isCash) {
    final unitDiscount = isCash
        ? package.resolvedCashDiscount
        : package.resolvedCreditDiscount;
    return unitDiscount * voucherCount;
  }

  /// صافي السطر بعد الخصم
  double lineNetTotal(bool isCash) {
    final net = lineGrossTotal - lineDiscountTotal(isCash);
    return net > 0 ? net : 0.0;
  }

  DirectInvoiceCartLineEntity copyWith({
    PackageEntity? package,
    int? voucherCount,
  }) {
    return DirectInvoiceCartLineEntity(
      package: package ?? this.package,
      voucherCount: voucherCount ?? this.voucherCount,
    );
  }

  @override
  List<Object?> get props => [package, voucherCount];
}
