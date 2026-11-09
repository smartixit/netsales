/// حالة طلب التزويد التجاري (Request Status)
/// مطابق للقيم السلكية المعتمدة في netsales_api (App\Enums\RequestStatus)
enum RequestStatus {
  pending('PENDING'),
  approved('APPROVED'),
  rejected('REJECTED'),
  cancelled('CANCELLED'),
  unknown('UNKNOWN');

  final String wireValue;
  const RequestStatus(this.wireValue);

  static RequestStatus fromWire(String? raw) {
    if (raw == null) return RequestStatus.unknown;
    for (final status in RequestStatus.values) {
      if (status.wireValue == raw) return status;
    }
    return RequestStatus.unknown;
  }

  bool get isKnown => this != RequestStatus.unknown;
}
