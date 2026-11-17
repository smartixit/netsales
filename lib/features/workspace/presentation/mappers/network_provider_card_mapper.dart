import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_workspace_overview_entity.dart';
import 'package:netsales/features/workspace/presentation/mappers/network_workspace_dashboard_mapper.dart';
import 'package:netsales/features/workspace/presentation/models/network_provider_card_view_model.dart';

class NetworkProviderCardMapper {
  const NetworkProviderCardMapper._();

  static List<NetworkProviderCardViewModel> map({
    required Iterable<NetworkEntity> networks,
    required int? selectedNetworkId,
    required NetworkWorkspaceOverviewEntity? overview,
  }) {
    return List.unmodifiable(
      networks.toList().asMap().entries.map((entry) {
        final network = entry.value;
        final isSelected = network.networkId == selectedNetworkId;
        final locationParts = [
          if (network.governorateName?.isNotEmpty == true)
            network.governorateName!,
          if (network.directorateName?.isNotEmpty == true)
            network.directorateName!,
        ];
        return NetworkProviderCardViewModel(
          networkId: network.networkId,
          networkName: network.networkName,
          logoUrl: network.networkProfileLogoUrl,
          avatarInitial: TextFormatter.avatarInitial(
            network.networkName,
            fallback: 'ش',
          ),
          subtitle: locationParts.isEmpty
              ? 'شبكة مصرحة ومعتمدة'
              : locationParts.join(' • '),
          networkCode: network.networkUuid ?? '',
          ownerDisplay: TextFormatter.firstAndLast(
            network.ownerName,
            fallback: 'المزود المعتمد',
          ),
          isActive: network.isActive,
          salesValue: NetworkWorkspaceDashboardMapper.formatNetworkSales(
            overview,
            isSelected: isSelected,
          ),
          posCountText: NetworkWorkspaceDashboardMapper.formatNetworkPosCount(
            overview,
            isSelected: isSelected,
          ),
          isSelected: isSelected,
          cardIndex: entry.key,
        );
      }),
    );
  }
}
