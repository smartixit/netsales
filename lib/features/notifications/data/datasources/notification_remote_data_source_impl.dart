import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:netsales/features/notifications/data/models/notification_item_model.dart';

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiService? apiService;

  const NotificationRemoteDataSourceImpl({this.apiService});

  ApiService get _api => apiService ?? ApiService.instance;

  @override
  Future<ApiResponse<List<NotificationItemModel>>> getMyNotifications({
    Map<String, dynamic>? query,
  }) {
    return _api.get<List<NotificationItemModel>>(
      ApiConstants.notificationsMy,
      queryParameters: query,
      fromJson: (data) {
        if (data is List) {
          return data
              .map(
                (item) => NotificationItemModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList();
        }
        return [];
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getUnreadCount() {
    return _api.get<Map<String, dynamic>>(
      ApiConstants.notificationsUnreadCount,
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
        return {};
      },
    );
  }

  @override
  Future<ApiResponse<dynamic>> markAsRead(int notificationId) {
    return _api.post<dynamic>(
      ApiConstants.notificationMarkAsRead(notificationId),
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> markAllAsRead() {
    return _api.post<Map<String, dynamic>>(
      ApiConstants.notificationsMarkAllRead,
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
        return {};
      },
    );
  }
}
