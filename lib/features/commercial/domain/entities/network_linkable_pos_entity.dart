import 'package:equatable/equatable.dart';

/// Minimal POS identity returned only after the API resolves an exact
/// commercial business code for a specific Network invitation.
class NetworkLinkablePosEntity extends Equatable {
  const NetworkLinkablePosEntity({
    required this.posId,
    required this.posUuid,
    required this.posName,
  });

  final int posId;
  final String posUuid;
  final String posName;

  @override
  List<Object?> get props => [posId, posUuid, posName];
}
