import 'package:netsales/features/commercial/domain/entities/network_pos_agreement_entity.dart';

class NetworkPosAgreementModel extends NetworkPosAgreementEntity {
  const NetworkPosAgreementModel({
    required super.agreementId,
    required super.networkPosId,
    required super.version,
    required super.title,
    required super.terms,
    required super.status,
    super.reference,
    super.startsAt,
    super.endsAt,
    super.activatedAt,
    super.terminatedAt,
    super.validityState,
  });

  factory NetworkPosAgreementModel.fromJson(Map<String, dynamic> json) {
    return NetworkPosAgreementModel(
      agreementId: (json['agreement_id'] as num?)?.toInt() ?? 0,
      networkPosId: (json['network_pos_id'] as num?)?.toInt() ?? 0,
      version: (json['version'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      terms: json['terms']?.toString() ?? '',
      status: json['status']?.toString() ?? 'DRAFT',
      reference: json['reference']?.toString(),
      startsAt: json['starts_at']?.toString(),
      endsAt: json['ends_at']?.toString(),
      activatedAt: json['activated_at']?.toString(),
      terminatedAt: json['terminated_at']?.toString(),
      validityState: json['validity_state']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'agreement_id': agreementId,
    'network_pos_id': networkPosId,
    'version': version,
    'title': title,
    'terms': terms,
    'status': status,
    'reference': reference,
    'starts_at': startsAt,
    'ends_at': endsAt,
    'activated_at': activatedAt,
    'terminated_at': terminatedAt,
  };
}
