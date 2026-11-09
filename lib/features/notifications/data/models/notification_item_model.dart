import 'package:netsales/core/enums/notification_type.dart';
import 'package:netsales/features/notifications/domain/entities/notification_item_entity.dart';

/// نموذج بيانات الإشعار الوارد من Laravel API (Data Model)
class NotificationItemModel extends NotificationItemEntity {
  const NotificationItemModel({
    required super.notificationId,
    required super.userId,
    required super.notificationType,
    super.notificationTypeLabel,
    required super.notificationTitle,
    required super.notificationMessage,
    super.notificationImage,
    required super.isRead,
    super.readAt,
    super.createdAt,
    super.updatedAt,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    final rawType = json['notification_type']?.toString();
    final type = NotificationType.fromWire(rawType);

    return NotificationItemModel(
      notificationId: json['notification_id'] is int
          ? json['notification_id'] as int
          : int.tryParse(json['notification_id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      notificationType: type,
      notificationTypeLabel: json['notification_type_label']?.toString(),
      notificationTitle: json['notification_title']?.toString() ?? '',
      notificationMessage: json['notification_message']?.toString() ?? '',
      notificationImage: json['notification_image']?.toString(),
      isRead:
          json['is_read'] == true ||
          json['is_read'] == 1 ||
          json['is_read'] == '1',
      readAt: parseDateTime(json['read_at']),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'user_id': userId,
      'notification_type': notificationType.value,
      'notification_type_label': notificationTypeLabel,
      'notification_title': notificationTitle,
      'notification_message': notificationMessage,
      'notification_image': notificationImage,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
