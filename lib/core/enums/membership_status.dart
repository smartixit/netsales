enum MembershipStatus {
  active('ACTIVE'),
  suspended('SUSPENDED'),
  invited('INVITED'),
  unknown('UNKNOWN');

  const MembershipStatus(this.wireValue);
  final String wireValue;

  static MembershipStatus fromWire(String? raw) {
    for (final value in values) {
      if (value.wireValue == raw) return value;
    }
    return MembershipStatus.unknown;
  }
}
