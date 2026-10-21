import 'package:netsales/features/auth/domain/entities/governorate_entity.dart';

/// نموذج بيانات المحافظة (GovernorateModel) يرث من الكيان الدوميني
class GovernorateModel extends GovernorateEntity {
  const GovernorateModel({
    required super.governorateId,
    required super.governorateName,
  });

  factory GovernorateModel.fromJson(Map<String, dynamic> json) {
    return GovernorateModel(
      governorateId: (json['governorate_id'] ?? json['id']) as int? ?? 0,
      governorateName: (json['governorate_name'] ?? json['name'])?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'governorate_id': governorateId,
      'governorate_name': governorateName,
    };
  }
}
