/// حالة اشتراك مزود الخدمة بالباقات (Provider Subscription Status)
/// مطابق للقيم السلكية المعتمدة في netsales_api (App\Enums\ProviderSubscriptionStatus)
enum ProviderSubscriptionStatus {
  active('ACTIVE'),
  queued('QUEUED'),
  expired('EXPIRED'),
  cancelled('CANCELLED'),
  suspended('SUSPENDED'),
  unknown('UNKNOWN');

  final String wireValue;
  const ProviderSubscriptionStatus(this.wireValue);

  static ProviderSubscriptionStatus fromWire(String? raw) {
    if (raw == null) return ProviderSubscriptionStatus.unknown;
    for (final status in ProviderSubscriptionStatus.values) {
      if (status.wireValue == raw) return status;
    }
    return ProviderSubscriptionStatus.unknown;
  }

  bool get isKnown => this != ProviderSubscriptionStatus.unknown;
}
