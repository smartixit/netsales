import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/workspace/presentation/models/workspace_pos_picker_item_view_model.dart';

class WorkspacePosPickerMapper {
  const WorkspacePosPickerMapper._();

  static List<WorkspacePosPickerItemViewModel> map(Iterable<PosEntity> points) =>
      List.unmodifiable(points.map((pos) {
        final location = [
          if (pos.governorateName?.isNotEmpty == true) pos.governorateName!,
          if (pos.directorateName?.isNotEmpty == true) pos.directorateName!,
        ].join(' • ');

        return WorkspacePosPickerItemViewModel(
          id: pos.posId,
          name: pos.posName,
          logoUrl: pos.posProfileLogoUrl,
          subtitle: location.isNotEmpty
              ? location
              : pos.posPhoneNumber.isNotEmpty
                  ? pos.posPhoneNumber
                  : 'نقطة بيع معتمدة',
          isActive: pos.isActive,
        );
      }));
}
