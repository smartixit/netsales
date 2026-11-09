import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/notifications/domain/entities/notification_item_entity.dart';
import 'package:netsales/features/notifications/domain/repositories/notification_repository.dart';

class GetMyNotificationsUseCase {
  final NotificationRepository repository;

  const GetMyNotificationsUseCase(this.repository);

  Future<PaginatedList<NotificationItemEntity>> call({
    bool? isRead,
    String? notificationType,
    String? search,
    String? cursor,
    int? perPage,
  }) {
    return repository.getMyNotifications(
      isRead: isRead,
      notificationType: notificationType,
      search: search,
      cursor: cursor,
      perPage: perPage,
    );
  }
}
