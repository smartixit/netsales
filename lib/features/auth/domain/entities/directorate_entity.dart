/// كائن المديرية الدوميني النقي (DirectorateEntity)
class DirectorateEntity {
  final int directorateId;
  final int governorateId;
  final String directorateName;

  const DirectorateEntity({
    required this.directorateId,
    required this.governorateId,
    required this.directorateName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DirectorateEntity &&
          runtimeType == other.runtimeType &&
          directorateId == other.directorateId;

  @override
  int get hashCode => directorateId.hashCode;

  @override
  String toString() => directorateName;
}
