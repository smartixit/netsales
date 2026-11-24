enum PackageDiscountActivationStatus {
  enabled,
  disabled,
  unknown;

  static PackageDiscountActivationStatus fromValue(bool? value) => switch (value) {
    true => enabled,
    false => disabled,
    null => unknown,
  };
}
