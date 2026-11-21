/// حالة تفعيل باقة كروت الإنترنت (Voucher Package Status)
///
/// مطابق للقيم التشغيلية المعتمدة في النظام: نشطة ومفعلة أو معطلة
enum PackageStatus {
  active('ACTIVE'),
  inactive('INACTIVE'),
  unknown('UNKNOWN');

  final String wireValue;
  const PackageStatus(this.wireValue);

  static PackageStatus fromWire(dynamic raw) {
    if (raw == null) return PackageStatus.unknown;
    if (raw is bool) {
      return raw ? PackageStatus.active : PackageStatus.inactive;
    }
    final str = raw.toString().trim().toUpperCase();
    if (str == 'ACTIVE' || str == '1' || str == 'TRUE') return PackageStatus.active;
    if (str == 'INACTIVE' || str == '0' || str == 'FALSE') return PackageStatus.inactive;
    return PackageStatus.unknown;
  }

  bool get isKnown => this != PackageStatus.unknown;
  bool get isActive => this == PackageStatus.active;
}
