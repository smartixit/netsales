/// حالة سداد الفاتورة المالية (Invoice Payment Status)
/// مطابق للقيم السلكية المعتمدة في netsales_api (App\Enums\InvoicePaymentStatus)
enum InvoicePaymentStatus {
  paid('PAID'),
  partiallyPaid('PARTIALLY_PAID'),
  unpaid('UNPAID'),
  unknown('UNKNOWN');

  final String wireValue;
  const InvoicePaymentStatus(this.wireValue);

  static InvoicePaymentStatus fromWire(String? raw) {
    if (raw == null) return InvoicePaymentStatus.unknown;
    for (final status in InvoicePaymentStatus.values) {
      if (status.wireValue == raw) return status;
    }
    return InvoicePaymentStatus.unknown;
  }

  bool get isKnown => this != InvoicePaymentStatus.unknown;
}

