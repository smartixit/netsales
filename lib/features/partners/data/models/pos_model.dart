import 'package:netsales/features/partners/domain/entities/pos_entity.dart';

/// ============================================================================
/// نموذج بيانات نقطة البيع / الوكيل (PosModel)
/// ============================================================================
/// يرث بالضرورة من الكيان الدوميني [PosEntity] طبقاً لقواعد Clean Architecture.
/// يتولى عمليات التسلسل وفك التسلسل لبيانات JSON الواردة من netsales_api.
class PosModel extends PosEntity {
  const PosModel({
    required super.posId,
    required super.posUuid,
    required super.posName,
    super.posProfileLogo,
    super.posPhoneNumber,
    super.posEmail,
    super.posAddress,
    required super.governorateId,
    required super.directorateId,
    super.governorateName,
    super.directorateName,
    required super.ownerId,
    super.agentName,
    super.agentPhone,
    super.approvedAt,
    super.rejectedAt,
    super.rejectionReason,
    required super.status,
    super.networksCount,
    super.createdAt,
  });

  factory PosModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      try {
        return DateTime.tryParse(value.toString());
      } catch (_) {
        return null;
      }
    }

    final owner = json['owner'] is Map ? json['owner'] as Map<String, dynamic> : null;
    final governorate = json['governorate'] is Map
        ? json['governorate'] as Map<String, dynamic>
        : null;
    final directorate = json['directorate'] is Map
        ? json['directorate'] as Map<String, dynamic>
        : null;

    final govName = governorate?['governorate_name_ar']?.toString() ??
        governorate?['governorate_name']?.toString() ??
        json['governorate_name']?.toString();

    final dirName = directorate?['directorate_name_ar']?.toString() ??
        directorate?['directorate_name']?.toString() ??
        json['directorate_name']?.toString();

    final agentFullName = json['pos_holder_name']?.toString() ??
        owner?['user_full_name']?.toString() ??
        json['agent_name']?.toString();

    final agentPhoneNumber = owner?['user_phone_number']?.toString() ??
        json['pos_phone_number']?.toString() ??
        json['agent_phone']?.toString();

    return PosModel(
      posId: (json['pos_id'] ?? json['id'] ?? 0) as int,
      posUuid: (json['pos_uuid'] ?? json['uuid'] ?? '').toString(),
      posName: (json['pos_name'] ?? json['name'] ?? '').toString(),
      posProfileLogo: json['pos_profile_logo']?.toString() ??
          json['profile_logo']?.toString() ??
          json['logo']?.toString(),
      posPhoneNumber: json['pos_phone_number']?.toString() ??
          json['phone_number']?.toString() ??
          json['phone']?.toString(),
      posEmail: json['pos_email']?.toString() ?? json['email']?.toString(),
      posAddress: json['pos_address']?.toString() ?? json['address']?.toString(),
      governorateId: (json['governorate_id'] ?? 0) as int,
      directorateId: (json['directorate_id'] ?? 0) as int,
      governorateName: govName,
      directorateName: dirName,
      ownerId: (json['owner_id'] ?? 0) as int,
      agentName: agentFullName,
      agentPhone: agentPhoneNumber,
      approvedAt: parseDate(json['approved_at']),
      rejectedAt: parseDate(json['rejected_at']),
      rejectionReason: json['rejection_reason']?.toString(),
      status: (json['status'] ?? 'PENDING').toString(),
      networksCount:
          json['networks_count'] as int? ?? json['network_pos_count'] as int?,
      createdAt: parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pos_id': posId,
      'pos_uuid': posUuid,
      'pos_name': posName,
      'pos_profile_logo': posProfileLogo,
      'pos_phone_number': posPhoneNumber,
      'pos_email': posEmail,
      'pos_address': posAddress,
      'governorate_id': governorateId,
      'directorate_id': directorateId,
      'owner_id': ownerId,
      'status': status,
      if (approvedAt != null) 'approved_at': approvedAt!.toIso8601String(),
      if (rejectedAt != null) 'rejected_at': rejectedAt!.toIso8601String(),
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
