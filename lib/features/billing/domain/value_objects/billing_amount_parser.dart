/// Converts a user-entered decimal amount to the currency's minor unit
/// without passing through binary floating-point arithmetic.
abstract final class BillingAmountParser {
  static int? toMinor(String input, int decimalPlaces) {
    if (decimalPlaces < 0 || decimalPlaces > 9) return null;

    final value = input.trim();
    if (value.isEmpty || !RegExp(r'^\d+(?:\.\d*)?$').hasMatch(value)) {
      return null;
    }

    final parts = value.split('.');
    final wholePart = parts.first;
    final fractionalPart = parts.length == 2 ? parts[1] : '';
    if (fractionalPart.length > decimalPlaces) return null;
    if (decimalPlaces == 0 && fractionalPart.isNotEmpty) return null;

    final scale = BigInt.from(10).pow(decimalPlaces);
    final whole = BigInt.tryParse(wholePart);
    final fractional = BigInt.tryParse(
      fractionalPart.padRight(decimalPlaces, '0').isEmpty
          ? '0'
          : fractionalPart.padRight(decimalPlaces, '0'),
    );
    if (whole == null || fractional == null) return null;

    final amountMinor = whole * scale + fractional;
    const maximumSafeMinor = 0x7fffffffffffffff;
    if (amountMinor <= BigInt.zero ||
        amountMinor > BigInt.from(maximumSafeMinor)) {
      return null;
    }

    return amountMinor.toInt();
  }
}
