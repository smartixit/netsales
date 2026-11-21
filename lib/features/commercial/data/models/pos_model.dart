import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';

/// نموذج بيانات نقطة البيع التجارية (POS Model)
class PosModel extends PosEntity {
  const PosModel({
    required super.posId,
    required super.ownerId,
    required super.posUuid,
    required super.posName,
    required super.posPhoneNumber,
    super.posEmail,
    super.posAddress,
    super.governorateId,
    super.directorateId,
    super.governorateName,
    super.directorateName,
    super.status,
    super.statusLabel,
    super.ownerName,
    super.posProfileLogoUrl,
    super.createdAt,
    super.updatedAt,
  });

  factory PosModel.fromJson(Map<String, dynamic> json) {
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
    } else if (json['pos_holder_name'] != null) {
      ownerFullName = json['pos_holder_name']?.toString();
    } else if (json['owner_name'] != null) {
      ownerFullName = json['owner_name']?.toString();
    }

    return PosModel(
      posId: (json['pos_id'] as num?)?.toInt() ?? 0,
      ownerId: (json['owner_id'] as num?)?.toInt() ?? 0,
      posUuid: json['pos_uuid']?.toString() ?? '',
      posName: json['pos_name']?.toString() ?? '',
      posPhoneNumber: json['pos_phone_number']?.toString() ?? '',
      posEmail: json['pos_email']?.toString(),
      posAddress: json['pos_address']?.toString(),
      governorateId: (json['governorate_id'] as num?)?.toInt(),
      directorateId: (json['directorate_id'] as num?)?.toInt(),
      governorateName: govName,
      directorateName: dirName,
      status: json['status']?.toString(),
      statusLabel: json['status_label']?.toString(),
      ownerName: ownerFullName,
      posProfileLogoUrl: json['pos_profile_logo']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pos_id': posId,
      'owner_id': ownerId,
      'pos_uuid': posUuid,
      'pos_name': posName,
      'pos_phone_number': posPhoneNumber,
      'pos_email': posEmail,
      'pos_address': posAddress,
      'governorate_id': governorateId,
      'directorate_id': directorateId,
      'governorate_name': governorateName,
      'directorate_name': directorateName,
      'status': status,
      'status_label': statusLabel,
      'owner_name': ownerName,
      'pos_profile_logo': posProfileLogoUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
