import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';

/// ============================================================================
/// نموذج بيانات عقد ربط الشبكة بنقطة البيع (NetworkPosModel)
/// ============================================================================
/// يرث بالضرورة من الكيان الدوميني [NetworkPosEntity] طبقاً لقواعد Clean Architecture.
/// يتولى عمليات التسلسل وفك التسلسل لبيانات JSON الواردة من netsales_api.
class NetworkPosModel extends NetworkPosEntity {
  const NetworkPosModel({
    required super.networkPosId,
    required super.networkId,
    required super.posId,
    super.networkName,
    super.networkPhone,
    super.networkLogo,
    super.posName,
    super.posPhone,
    super.posLogo,
    super.governorateName,
    super.directorateName,
    required super.status,
    super.createdAt,
    super.updatedAt,
  });

  factory NetworkPosModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      try {
        return DateTime.tryParse(value.toString());
      } catch (_) {
        return null;
      }
    }

    final network =
        json['network'] is Map ? json['network'] as Map<String, dynamic> : null;
    final pos = json['pos'] is Map ? json['pos'] as Map<String, dynamic> : null;

    final networkTitle = network?['network_name']?.toString() ??
        json['network_name']?.toString();
    final networkContact = network?['network_phone_number']?.toString() ??
        json['network_phone']?.toString();
    final networkImg = network?['network_profile_logo']?.toString() ??
        json['network_logo']?.toString();

    final posTitle = pos?['pos_name']?.toString() ?? json['pos_name']?.toString();
    final posContact = pos?['pos_phone_number']?.toString() ??
        json['pos_phone']?.toString();
    final posImg = pos?['pos_profile_logo']?.toString() ??
        json['pos_logo']?.toString();

    final posGov = pos?['governorate'] is Map
        ? (pos!['governorate']['governorate_name_ar'] ??
            pos['governorate']['governorate_name'])
        : null;
    final posDir = pos?['directorate'] is Map
        ? (pos!['directorate']['directorate_name_ar'] ??
            pos['directorate']['directorate_name'])
        : null;

    final govName = posGov?.toString() ?? json['governorate_name']?.toString();
    final dirName = posDir?.toString() ?? json['directorate_name']?.toString();

    final rawStatus = json['status'];
    final bool parsedStatus = rawStatus is bool
        ? rawStatus
        : (rawStatus == 1 || rawStatus == '1' || rawStatus == 'true');

    return NetworkPosModel(
      networkPosId: (json['network_pos_id'] ?? json['id'] ?? 0) as int,
      networkId: (json['network_id'] ?? 0) as int,
      posId: (json['pos_id'] ?? 0) as int,
      networkName: networkTitle,
      networkPhone: networkContact,
      networkLogo: networkImg,
      posName: posTitle,
      posPhone: posContact,
      posLogo: posImg,
      governorateName: govName,
      directorateName: dirName,
      status: parsedStatus,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'network_pos_id': networkPosId,
      'network_id': networkId,
      'pos_id': posId,
      'status': status,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
