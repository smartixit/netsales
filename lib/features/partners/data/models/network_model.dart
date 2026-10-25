import 'package:netsales/features/partners/domain/entities/network_entity.dart';

/// ============================================================================
/// نموذج بيانات مزود الشبكة (NetworkModel)
/// ============================================================================
/// يرث بالضرورة من الكيان الدوميني [NetworkEntity] طبقاً لقواعد Clean Architecture.
/// يتولى عمليات التسلسل وفك التسلسل لبيانات JSON الواردة من netsales_api.
class NetworkModel extends NetworkEntity {
  const NetworkModel({
    required super.networkId,
    required super.networkUuid,
    required super.networkName,
    super.networkProfileLogo,
    super.networkPhoneNumber,
    super.networkEmail,
    super.networkAddress,
    required super.governorateId,
    required super.directorateId,
    super.governorateName,
    super.directorateName,
    required super.ownerId,
    super.ownerName,
    super.ownerPhone,
    super.approvedAt,
    super.rejectedAt,
    super.rejectionReason,
    required super.status,
    super.posCount,
    super.packagesCount,
    super.createdAt,
  });

  factory NetworkModel.fromJson(Map<String, dynamic> json) {
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

    final ownerFullName = json['network_holder_name']?.toString() ??
        owner?['user_full_name']?.toString() ??
        json['owner_name']?.toString();

    final ownerPhoneNumber = owner?['user_phone_number']?.toString() ??
        json['owner_phone']?.toString();

    return NetworkModel(
      networkId: (json['network_id'] ?? json['id'] ?? 0) as int,
      networkUuid: (json['network_uuid'] ?? json['uuid'] ?? '').toString(),
      networkName: (json['network_name'] ?? json['name'] ?? '').toString(),
      networkProfileLogo: json['network_profile_logo']?.toString() ??
          json['profile_logo']?.toString() ??
          json['logo']?.toString(),
      networkPhoneNumber: json['network_phone_number']?.toString() ??
          json['phone_number']?.toString() ??
          json['phone']?.toString(),
      networkEmail: json['network_email']?.toString() ?? json['email']?.toString(),
      networkAddress: json['network_address']?.toString() ?? json['address']?.toString(),
      governorateId: (json['governorate_id'] ?? 0) as int,
      directorateId: (json['directorate_id'] ?? 0) as int,
      governorateName: govName,
      directorateName: dirName,
      ownerId: (json['owner_id'] ?? 0) as int,
      ownerName: ownerFullName,
      ownerPhone: ownerPhoneNumber,
      approvedAt: parseDate(json['approved_at']),
      rejectedAt: parseDate(json['rejected_at']),
      rejectionReason: json['rejection_reason']?.toString(),
      status: (json['status'] ?? 'PENDING').toString(),
      posCount: json['pos_count'] as int? ?? json['network_pos_count'] as int?,
      packagesCount: json['packages_count'] as int? ??
          json['voucher_packages_count'] as int?,
      createdAt: parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'network_id': networkId,
      'network_uuid': networkUuid,
      'network_name': networkName,
      'network_profile_logo': networkProfileLogo,
      'network_phone_number': networkPhoneNumber,
      'network_email': networkEmail,
      'network_address': networkAddress,
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
