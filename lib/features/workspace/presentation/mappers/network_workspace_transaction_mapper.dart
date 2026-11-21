import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/workspace/domain/entities/network_pending_request_entity.dart';
import 'package:netsales/features/workspace/presentation/models/workspace_transaction_item_view_model.dart';

/// Converts network overview requests into immutable dashboard row models.
class NetworkWorkspaceTransactionMapper {
  const NetworkWorkspaceTransactionMapper._();

  static List<WorkspaceTransactionItemViewModel> mapPendingRequests(
    Iterable<NetworkPendingRequestEntity> requests, {
    required void Function(int requestId) onOpenRequest,
  }) {
    return requests
        .map((request) {
          final reference = request.requestUuid.isEmpty
              ? ''
              : request.requestUuid.split('-').first;
          final parsedDate = DateFormatter.tryParse(request.requestDate);
          final dateLabel = parsedDate == null
              ? ''
              : DateFormatter.smart(parsedDate);
          final subtitle = [
            request.posName,
            if (dateLabel.isNotEmpty) dateLabel,
          ].join(' • ');
          void openRequest() => onOpenRequest(request.requestId);
          final statusPresentation =
              EnumPresentationRegistry.resolveRequestStatus(
            request.status,
            serverLabel: request.statusLabel,
          );

          return WorkspaceTransactionItemViewModel(
            title: 'طلب توريد',
            reference: '#${request.requestId}',
            subtitle: subtitle,
            formattedAmount: '',
            statusPresentation: statusPresentation,
            icon: Icons.inventory_2_rounded,
            onTap: openRequest,
          );
        })
        .toList(growable: false);
  }
}
