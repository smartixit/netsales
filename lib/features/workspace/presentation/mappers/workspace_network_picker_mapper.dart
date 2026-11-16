import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/workspace/presentation/models/workspace_network_picker_item_view_model.dart';

class WorkspaceNetworkPickerMapper {
  const WorkspaceNetworkPickerMapper._();

  static List<WorkspaceNetworkPickerItemViewModel> map(
    Iterable<NetworkEntity> networks,
  ) =>
      List.unmodifiable(networks.map((network) {
        final location = [
          if (network.governorateName?.isNotEmpty == true)
            network.governorateName!,
          if (network.directorateName?.isNotEmpty == true)
            network.directorateName!,
        ].join(' • ');

        return WorkspaceNetworkPickerItemViewModel(
          id: network.networkId,
          name: network.networkName,
          logoUrl: network.networkProfileLogoUrl,
          initials: TextFormatter.avatarInitials(
            network.networkName,
            maxChars: 2,
          ),
          subtitle: location.isNotEmpty
              ? location
              : network.networkPhoneNumber.isNotEmpty
                  ? network.networkPhoneNumber
                  : 'شبكة اتصالات معتمدة',
          isActive: network.isActive,
        );
      }));
}
