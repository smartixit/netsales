import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';

/// نموذج بيانات نقطة البيع لمطابقة عقد الخادم (POS Model)
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
    String? resolvedOwnerName;
    if (json['pos_holder_name'] != null) {
      resolvedOwnerName = json['pos_holder_name']?.toString();
    } else if (json['owner'] is Map) {
      resolvedOwnerName = json['owner']['user_full_name']?.toString();
    }

    String? govName;
    if (json['governorate'] is Map) {
      govName = json['governorate']['governorate_name']?.toString();
    }

    String? dirName;
    if (json['directorate'] is Map) {
      dirName = json['directorate']['directorate_name']?.toString();
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
      ownerName: resolvedOwnerName,
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
      'status': status,
      'status_label': statusLabel,
      'pos_holder_name': ownerName,
      'pos_profile_logo': posProfileLogoUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
