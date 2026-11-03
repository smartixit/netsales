import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';

/// كيان رابط الشراكة بين الشبكة ونقطة البيع (Network–POS Link Entity)
class NetworkPosLinkEntity {
  final int networkPosId;
  final int networkId;
  final int posId;
  final bool status;
  final String? createdAt;
  final String? updatedAt;
  final NetworkEntity? network;
  final PosEntity? pos;

  const NetworkPosLinkEntity({
    required this.networkPosId,
    required this.networkId,
    required this.posId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.network,
    this.pos,
  });

  bool get isActive => status;

  NetworkPosLinkEntity copyWith({
    int? networkPosId,
    int? networkId,
    int? posId,
    bool? status,
    String? createdAt,
    String? updatedAt,
    NetworkEntity? network,
    PosEntity? pos,
  }) {
    return NetworkPosLinkEntity(
      networkPosId: networkPosId ?? this.networkPosId,
      networkId: networkId ?? this.networkId,
      posId: posId ?? this.posId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      network: network ?? this.network,
      pos: pos ?? this.pos,
    );
  }
}
