import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/workspace/presentation/models/pos_linked_network_option_view_model.dart';

class PosLinkedNetworkOptionMapper {
  const PosLinkedNetworkOptionMapper._();

  static List<PosLinkedNetworkOptionViewModel> map({
    required Iterable<NetworkPosLinkEntity> links,
    required int? selectedNetworkPosId,
  }) {
    return List.unmodifiable(
      links
          .where((link) => link.status)
          .map(
            (link) => PosLinkedNetworkOptionViewModel(
              networkPosId: link.networkPosId,
              networkId: link.networkId,
              displayName: link.displayNetworkName,
              isSelected: link.networkPosId == selectedNetworkPosId,
            ),
          ),
    );
  }
}
