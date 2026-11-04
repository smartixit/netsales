/// كيان معاينة دعوة الربط المشفرة من جانب نقطة البيع
class NetworkPosLinkPreviewEntity {
  final String challengeUuid;
  final int networkId;
  final String networkName;
  final String? networkPhone;
  final String? governorateName;
  final String? directorateName;
  final int? posId;
  final String? posName;
  final DateTime expiresAt;
  final bool alreadyLinked;

  const NetworkPosLinkPreviewEntity({
    required this.challengeUuid,
    required this.networkId,
    required this.networkName,
    this.networkPhone,
    this.governorateName,
    this.directorateName,
    this.posId,
    this.posName,
    required this.expiresAt,
    required this.alreadyLinked,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

