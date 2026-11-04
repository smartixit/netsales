/// حالة دعوة ربط نقطة البيع بالشبكة (Linking Challenge Status)
/// مطابق للقيم السلكية المعتمدة في netsales_api (App\Enums\LinkingChallengeStatus)
enum LinkingChallengeStatus {
  pending('PENDING'),
  consumed('CONSUMED'),
  expired('EXPIRED'),
  revoked('REVOKED'),
  unknown('UNKNOWN');

  final String wireValue;
  const LinkingChallengeStatus(this.wireValue);

  static LinkingChallengeStatus fromWire(String? raw) {
    if (raw == null) return LinkingChallengeStatus.unknown;
    for (final status in LinkingChallengeStatus.values) {
      if (status.wireValue == raw) return status;
    }
    return LinkingChallengeStatus.unknown;
  }

  bool get isPending => this == LinkingChallengeStatus.pending;
  bool get isConsumed => this == LinkingChallengeStatus.consumed;
  bool get isExpired => this == LinkingChallengeStatus.expired;
  bool get isRevoked => this == LinkingChallengeStatus.revoked;
  bool get isKnown => this != LinkingChallengeStatus.unknown;
}
