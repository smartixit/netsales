import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/notifications/domain/entities/notification_item_entity.dart';

/// واجهة مستودع الإشعارات (Clean Architecture Domain Contract)
abstract class NotificationRepository {
  /// جلب قائمة إشعارات المستخدم الحالي مع الفلترة والترقيم بالمؤشر
  Future<PaginatedList<NotificationItemEntity>> getMyNotifications({
    bool? isRead,
    String? notificationType,
    String? search,
    String? cursor,
    int? perPage,
  });

  /// جلب عدد الإشعارات غير المقروءة للمستخدم الحالي
  Future<int> getUnreadCount();

  /// تعليم إشعار فردي كمقروء
  Future<void> markAsRead(int notificationId);

  /// تعليم كافة إشعارات المستخدم كمقروءة دفعة واحدة
  Future<int> markAllAsRead();
}
