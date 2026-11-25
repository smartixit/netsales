import 'package:equatable/equatable.dart';

class NetworkPosAgreementEntity extends Equatable {
  const NetworkPosAgreementEntity({
    required this.agreementId,
    required this.networkPosId,
    required this.version,
    required this.title,
    required this.terms,
    required this.status,
    this.reference,
    this.startsAt,
    this.endsAt,
    this.activatedAt,
    this.terminatedAt,
    this.validityState,
  });

  final int agreementId;
  final int networkPosId;
  final int version;
  final String title;
  final String terms;
  final String status;
  final String? reference;
  final String? startsAt;
  final String? endsAt;
  final String? activatedAt;
  final String? terminatedAt;
  final String? validityState;

  bool get isDraft => status == 'DRAFT';
  bool get isActive => status == 'ACTIVE' && validityState != 'EXPIRED';
  bool get isTerminated => status == 'TERMINATED';

  @override
  List<Object?> get props => [
    agreementId, networkPosId, version, title, terms, status, reference,
    startsAt, endsAt, activatedAt, terminatedAt, validityState,
  ];
}
