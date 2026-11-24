enum PackageDiscountValidityState {
  effective('EFFECTIVE'), scheduled('SCHEDULED'), expired('EXPIRED'),
  disabled('DISABLED'), unknown('UNKNOWN');
  const PackageDiscountValidityState(this.wireValue);
  final String wireValue;
  static PackageDiscountValidityState fromWire(String? value) =>
      values.firstWhere((e) => e.wireValue == value?.trim(),
          orElse: () => unknown);
}
