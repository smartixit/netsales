/// حالات الفوترة المشتركة كما يرسلها Laravel دون تعديل حالة الأحرف.
enum BillingStatus {
  incomplete('INCOMPLETE'),
  trialing('TRIALING'),
  active('ACTIVE'),
  pastDue('PAST_DUE'),
  paused('PAUSED'),
  suspended('SUSPENDED'),
  canceled('CANCELED'),
  ended('ENDED'),
  reserved('RESERVED'),
  pendingApproval('PENDING_APPROVAL'),
  completed('COMPLETED'),
  expired('EXPIRED'),
  rejected('REJECTED'),
  revoked('REVOKED'),
  draft('DRAFT'),
  issued('ISSUED'),
  open('OPEN'),
  partiallyPaid('PARTIALLY_PAID'),
  partiallyCredited('PARTIALLY_CREDITED'),
  paid('PAID'),
  credited('CREDITED'),
  uncollectible('UNCOLLECTIBLE'),
  voided('VOID'),
  pendingReview('PENDING_REVIEW'),
  verified('VERIFIED'),
  failed('FAILED'),
  refunded('REFUNDED'),
  partiallyRefunded('PARTIALLY_REFUNDED'),
  pending('PENDING'),
  queued('QUEUED'),
  cancelled('CANCELLED'),
  unknown('UNKNOWN');

  const BillingStatus(this.wireValue);

  final String wireValue;

  static BillingStatus fromWire(String? raw) {
    if (raw == null) return BillingStatus.unknown;
    final value = raw.trim();
    for (final status in BillingStatus.values) {
      if (status.wireValue == value) return status;
    }
    return BillingStatus.unknown;
  }

  bool get isKnown => this != BillingStatus.unknown;
}
