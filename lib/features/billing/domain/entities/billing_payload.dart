class BillingPayload {
  const BillingPayload(this.data);
  final Map<String, dynamic> data;

  factory BillingPayload.fromJson(Map<String, dynamic> json) => BillingPayload(Map<String, dynamic>.unmodifiable(json));
  Map<String, dynamic> toJson() => data;
}
