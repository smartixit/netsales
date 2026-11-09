import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:netsales/features/notifications/domain/entities/notification_item_entity.dart';
import 'package:netsales/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  const NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<PaginatedList<NotificationItemEntity>> getMyNotifications({
    bool? isRead,
    String? notificationType,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    final query = <String, dynamic>{
      'is_read': ?isRead,
      if (notificationType != null && notificationType.isNotEmpty)
        'notification_type': notificationType,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      if (perPage != null && perPage > 0) 'per_page': perPage,
    };

    final response = await remoteDataSource.getMyNotifications(
      query: query.isNotEmpty ? query : null,
    );

    final items = response.data ?? [];

    return PaginatedList<NotificationItemEntity>(
      items: items,
      nextCursor: response.nextCursor,
      prevCursor: response.prevCursor,
    );
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await remoteDataSource.getUnreadCount();
    final data = response.data;
    if (data != null && data['unread_count'] != null) {
      final count = data['unread_count'];
      if (count is int) return count;
      return int.tryParse(count.toString()) ?? 0;
    }
    return 0;
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    await remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<int> markAllAsRead() async {
    final response = await remoteDataSource.markAllAsRead();
    final data = response.data;
    if (data != null && data['marked_read_count'] != null) {
      final count = data['marked_read_count'];
      if (count is int) return count;
      return int.tryParse(count.toString()) ?? 0;
    }
    return 0;
  }
}
