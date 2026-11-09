import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/notifications/data/models/notification_item_model.dart';

abstract class NotificationRemoteDataSource {
  Future<ApiResponse<List<NotificationItemModel>>> getMyNotifications({
    Map<String, dynamic>? query,
  });

  Future<ApiResponse<Map<String, dynamic>>> getUnreadCount();

  Future<ApiResponse<dynamic>> markAsRead(int notificationId);

  Future<ApiResponse<Map<String, dynamic>>> markAllAsRead();
}
