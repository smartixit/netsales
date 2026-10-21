/// كائن المحافظة الدوميني النقي (GovernorateEntity)
class GovernorateEntity {
  final int governorateId;
  final String governorateName;

  const GovernorateEntity({
    required this.governorateId,
    required this.governorateName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GovernorateEntity &&
          runtimeType == other.runtimeType &&
          governorateId == other.governorateId;

  @override
  int get hashCode => governorateId.hashCode;

  @override
  String toString() => governorateName;
}
