import 'package:netsales/core/enums/notification_type.dart';
import 'package:netsales/core/utils/date_formatter.dart';

/// كيان الإشعار المؤسسي الموحد في النطاق (Notification Item Entity)
class NotificationItemEntity {
  final int notificationId;
  final int userId;
  final NotificationType notificationType;
  final String? notificationTypeLabel;
  final String notificationTitle;
  final String notificationMessage;
  final String? notificationImage;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NotificationItemEntity({
    required this.notificationId,
    required this.userId,
    required this.notificationType,
    this.notificationTypeLabel,
    required this.notificationTitle,
    required this.notificationMessage,
    this.notificationImage,
    required this.isRead,
    this.readAt,
    this.createdAt,
    this.updatedAt,
  });

  NotificationItemEntity copyWith({
    int? notificationId,
    int? userId,
    NotificationType? notificationType,
    String? notificationTypeLabel,
    String? notificationTitle,
    String? notificationMessage,
    String? notificationImage,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationItemEntity(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      notificationType: notificationType ?? this.notificationType,
      notificationTypeLabel:
          notificationTypeLabel ?? this.notificationTypeLabel,
      notificationTitle: notificationTitle ?? this.notificationTitle,
      notificationMessage: notificationMessage ?? this.notificationMessage,
      notificationImage: notificationImage ?? this.notificationImage,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// المسار المستهدف عند النقر للتوجيه الذكي
  String get targetRoute => notificationType.defaultRoute;

  /// الوقت النسبي المعتمد من DateFormatter
  String get relativeTime {
    if (createdAt == null) return '';
    return DateFormatter.timeAgo(createdAt!);
  }
}

