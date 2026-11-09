import 'package:flutter/material.dart';
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

  /// أيقونة تصنيف الإشعار الدوميني
  IconData get iconData {
    switch (notificationType) {
      case NotificationType.saleInvoiceCreated:
      case NotificationType.saleInvoiceCompleted:
      case NotificationType.saleInvoiceCancelled:
        return Icons.receipt_long_rounded;

      case NotificationType.voucherRequestCreated:
      case NotificationType.voucherRequestApproved:
      case NotificationType.voucherRequestRejected:
      case NotificationType.voucherRequestCancelled:
        return Icons.inventory_2_rounded;

      case NotificationType.walletDeposit:
      case NotificationType.walletWithdrawal:
      case NotificationType.walletTransfer:
        return Icons.account_balance_wallet_rounded;

      case NotificationType.supportTicketCreated:
      case NotificationType.supportTicketReplied:
      case NotificationType.supportTicketClosed:
        return Icons.support_agent_rounded;

      case NotificationType.networkApproved:
      case NotificationType.networkRejected:
        return Icons.hub_rounded;

      case NotificationType.posApproved:
      case NotificationType.posRejected:
        return Icons.storefront_rounded;

      case NotificationType.securityLoginAlert:
      case NotificationType.securityDeviceBlocked:
      case NotificationType.securityPasswordChanged:
        return Icons.security_rounded;

      case NotificationType.systemAnnouncement:
        return Icons.campaign_rounded;

      case NotificationType.generalInfo:
      case NotificationType.unknown:
        return Icons.notifications_rounded;
    }
  }

  /// المسار المستهدف عند النقر للتوجيه الذكي
  String get targetRoute => notificationType.defaultRoute;

  /// الوقت النسبي المعتمد من DateFormatter
  String get relativeTime {
    if (createdAt == null) return '';
    return DateFormatter.timeAgo(createdAt!);
  }
}
