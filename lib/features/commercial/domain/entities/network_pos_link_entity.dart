import 'package:equatable/equatable.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';

/// كيان رابط الشراكة والارتباط التجاري بين الشبكة ونقطة البيع (Network-POS Link Entity)
class NetworkPosLinkEntity extends Equatable {
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

  final int networkPosId;
  final int networkId;
  final int posId;
  final bool status;
  final String? createdAt;
  final String? updatedAt;
  final NetworkEntity? network;
  final PosEntity? pos;

  bool get isActive => status;

  String get displayPosName => pos?.displayName ?? 'نقطة بيع #$posId';

  String get displayPosReference => pos?.displayReference ?? '#$posId';

  String get posPhone => pos?.displayPhone ?? 'غير متوفر';

  String get posOwnerName => pos?.displayOwnerName ?? 'غير محدد';

  String get posLocation => pos?.displayLocation ?? 'غير محدد';

  String get displayNetworkName =>
      network?.displayName ?? 'شبكة #$networkId';

  String get displayNetworkReference =>
      network?.displayReference ?? '#$networkId';

  String get networkPhone => network?.displayPhone ?? 'غير متوفر';

  String get networkOwnerName => network?.displayOwnerName ?? 'غير محدد';

  String get networkLocation => network?.displayLocation ?? 'غير محدد';

  DateTime? get parsedLinkedDate => DateTime.tryParse(createdAt ?? '');

  String get formattedLinkedDate => parsedLinkedDate != null
      ? DateFormatter.date(parsedLinkedDate!)
      : (createdAt ?? 'غير متوفر');

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

  @override
  List<Object?> get props => [
        networkPosId,
        networkId,
        posId,
        status,
        createdAt,
        updatedAt,
        network,
        pos,
      ];
}
