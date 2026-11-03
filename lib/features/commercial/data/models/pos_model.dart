import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';

/// نموذج بيانات نقطة البيع (POS Data Model)
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
    super.status,
    super.statusLabel,
    super.ownerName,
    super.posProfileLogoUrl,
    super.createdAt,
    super.updatedAt,
  });

  factory PosModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw FormatException(
        'Invalid JSON type for PosModel: ${json.runtimeType}',
      );
    }

    String? ownerName;
    if (json['owner'] is Map) {
      ownerName = json['owner']['user_full_name']?.toString();
    } else if (json['owner_name'] != null) {
      ownerName = json['owner_name']?.toString();
    }

    return PosModel(
      posId: _toInt(json['pos_id']),
      ownerId: _toInt(json['owner_id']),
      posUuid: json['pos_uuid']?.toString() ?? '',
      posName: json['pos_name']?.toString() ?? '',
      posPhoneNumber: json['pos_phone_number']?.toString() ?? '',
      posEmail: json['pos_email']?.toString(),
      posAddress: json['pos_address']?.toString(),
      governorateId: json['governorate_id'] != null
          ? _toInt(json['governorate_id'])
          : null,
      directorateId: json['directorate_id'] != null
          ? _toInt(json['directorate_id'])
          : null,
      status: json['status']?.toString(),
      statusLabel: json['status_label']?.toString(),
      ownerName: ownerName,
      posProfileLogoUrl: json['pos_profile_logo_url']?.toString(),
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
      'pos_profile_logo_url': posProfileLogoUrl,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
