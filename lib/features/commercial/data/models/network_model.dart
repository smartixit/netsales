import 'package:netsales/features/commercial/domain/entities/network_entity.dart';

/// نموذج بيانات مزود الشبكة التجاري (Network Model)
class NetworkModel extends NetworkEntity {
  const NetworkModel({
    required super.networkId,
    required super.ownerId,
    required super.networkName,
    required super.networkPhoneNumber,
    super.networkUuid,
    super.networkEmail,
    super.networkAddress,
    super.governorateId,
    super.directorateId,
    super.governorateName,
    super.directorateName,
    super.status,
    super.statusLabel,
    super.ownerName,
    super.networkProfileLogoUrl,
    super.createdAt,
    super.updatedAt,
  });

  factory NetworkModel.fromJson(Map<String, dynamic> json) {
    // استخراج أسماء المحافظة والمديرية إن وُجدت العلاقات محملة
    String? govName;
    if (json['governorate'] is Map<String, dynamic>) {
      govName = json['governorate']['governorate_name']?.toString();
    } else if (json['governorate_name'] != null) {
      govName = json['governorate_name']?.toString();
    }

    String? dirName;
    if (json['directorate'] is Map<String, dynamic>) {
      dirName = json['directorate']['directorate_name']?.toString();
    } else if (json['directorate_name'] != null) {
      dirName = json['directorate_name']?.toString();
    }

    String? ownerFullName;
    if (json['owner'] is Map<String, dynamic>) {
      ownerFullName = json['owner']['user_full_name']?.toString();
    } else if (json['network_holder_name'] != null) {
      ownerFullName = json['network_holder_name']?.toString();
    } else if (json['owner_name'] != null) {
      ownerFullName = json['owner_name']?.toString();
    }

    return NetworkModel(
      networkId: (json['network_id'] as num?)?.toInt() ?? 0,
      ownerId: (json['owner_id'] as num?)?.toInt() ?? 0,
      networkUuid: json['network_uuid']?.toString(),
      networkName: json['network_name']?.toString() ?? '',
      networkPhoneNumber: json['network_phone_number']?.toString() ?? '',
      networkEmail: json['network_email']?.toString(),
      networkAddress: json['network_address']?.toString(),
      governorateId: (json['governorate_id'] as num?)?.toInt(),
      directorateId: (json['directorate_id'] as num?)?.toInt(),
      governorateName: govName,
      directorateName: dirName,
      status: json['status']?.toString(),
      statusLabel: json['status_label']?.toString(),
      ownerName: ownerFullName,
      networkProfileLogoUrl: json['network_profile_logo']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'network_id': networkId,
      'owner_id': ownerId,
      'network_uuid': networkUuid,
      'network_name': networkName,
      'network_phone_number': networkPhoneNumber,
      'network_email': networkEmail,
      'network_address': networkAddress,
      'governorate_id': governorateId,
      'directorate_id': directorateId,
      'governorate_name': governorateName,
      'directorate_name': directorateName,
      'status': status,
      'status_label': statusLabel,
      'owner_name': ownerName,
      'network_profile_logo': networkProfileLogoUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
