import 'package:netsales/features/auth/domain/entities/directorate_entity.dart';

/// نموذج بيانات المديرية (DirectorateModel) يرث من الكيان الدوميني
class DirectorateModel extends DirectorateEntity {
  const DirectorateModel({
    required super.directorateId,
    required super.governorateId,
    required super.directorateName,
  });

  factory DirectorateModel.fromJson(Map<String, dynamic> json) {
    return DirectorateModel(
      directorateId: (json['directorate_id'] ?? json['id']) as int? ?? 0,
      governorateId: (json['governorate_id']) as int? ?? 0,
      directorateName: (json['directorate_name'] ?? json['name'])?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'directorate_id': directorateId,
      'governorate_id': governorateId,
      'directorate_name': directorateName,
    };
  }
}
