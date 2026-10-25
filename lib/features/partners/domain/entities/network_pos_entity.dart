/// ============================================================================
/// كائن عقد ربط الشبكة بنقطة البيع الدوميني النقي (NetworkPosEntity)
/// ============================================================================
/// كائن دوميني نقي يمثل شراكة التوزيع وعلاقة الربط بين الشبكة ونقطة البيع.
class NetworkPosEntity {
  final int networkPosId;
  final int networkId;
  final int posId;
  final String? networkName;
  final String? networkPhone;
  final String? networkLogo;
  final String? posName;
  final String? posPhone;
  final String? posLogo;
  final String? governorateName;
  final String? directorateName;
  final bool status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NetworkPosEntity({
    required this.networkPosId,
    required this.networkId,
    required this.posId,
    this.networkName,
    this.networkPhone,
    this.networkLogo,
    this.posName,
    this.posPhone,
    this.posLogo,
    this.governorateName,
    this.directorateName,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status;
  String get statusLabel => status ? 'نشط ومفعل' : 'معطل ومجمد';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkPosEntity &&
          runtimeType == other.runtimeType &&
          networkPosId == other.networkPosId;

  @override
  int get hashCode => networkPosId.hashCode;

  @override
  String toString() =>
      'NetworkPosEntity(id: $networkPosId, network: $networkName, pos: $posName, status: $status)';
}
