import 'package:netsales/features/commercial/domain/entities/network_entity.dart';

/// نموذج بيانات مزود الشبكة (Network Data Model)
class NetworkModel extends NetworkEntity {
  const NetworkModel({
    required super.networkId,
    required super.ownerId,
    required super.networkName,
    required super.networkPhoneNumber,
    super.networkEmail,
    super.networkAddress,
    super.governorateId,
    super.directorateId,
    super.status,
    super.statusLabel,
    super.ownerName,
    super.networkProfileLogoUrl,
    super.createdAt,
    super.updatedAt,
  });

  factory NetworkModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw FormatException('Invalid JSON type for NetworkModel: ${json.runtimeType}');
    }

    String? ownerName;
    if (json['owner'] is Map) {
      ownerName = json['owner']['user_full_name']?.toString();
    } else if (json['owner_name'] != null) {
      ownerName = json['owner_name']?.toString();
    }

    return NetworkModel(
      networkId: _toInt(json['network_id']),
      ownerId: _toInt(json['owner_id']),
      networkName: json['network_name']?.toString() ?? '',
      networkPhoneNumber: json['network_phone_number']?.toString() ?? '',
      networkEmail: json['network_email']?.toString(),
      networkAddress: json['network_address']?.toString(),
      governorateId: json['governorate_id'] != null ? _toInt(json['governorate_id']) : null,
      directorateId: json['directorate_id'] != null ? _toInt(json['directorate_id']) : null,
      status: json['status']?.toString(),
      statusLabel: json['status_label']?.toString(),
      ownerName: ownerName,
      networkProfileLogoUrl: json['network_profile_logo_url']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'network_id': networkId,
      'owner_id': ownerId,
      'network_name': networkName,
      'network_phone_number': networkPhoneNumber,
      'network_email': networkEmail,
      'network_address': networkAddress,
      'governorate_id': governorateId,
      'directorate_id': directorateId,
      'status': status,
      'network_profile_logo_url': networkProfileLogoUrl,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
