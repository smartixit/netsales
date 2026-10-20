import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/push_notification_service.dart';

void main() {
  group('PushNotificationService Enterprise Tests', () {
    test('High importance notification channel configuration is enterprise standard', () {
      const channel = PushNotificationService.highImportanceChannel;

      expect(channel.id, 'netsales_high_importance');
      expect(channel.name.isNotEmpty, isTrue);
      expect(channel.description, isNotNull);
      expect(channel.description!.isNotEmpty, isTrue);
      expect(channel.importance, Importance.max);
      expect(channel.playSound, isTrue);
      expect(channel.enableVibration, isTrue);
      expect(channel.showBadge, isTrue);
    });

    test('ApiConstants notifications endpoints match backend routes', () {
      expect(ApiConstants.notifications, '/notifications');
      expect(ApiConstants.notificationsMy, '/notifications/my');
      expect(ApiConstants.notificationsUnreadCount, '/notifications/unread-count');
      expect(ApiConstants.notificationFcmToken, '/notifications/fcm-token');
      expect(ApiConstants.notificationMarkAsRead(5), '/notifications/5/read');
    });

    test('StorageKeys contains fcmTokenStorage key', () {
      expect(StorageKeys.fcmTokenStorage, 'fcm_token_storage');
    });

    test('Deep link routing paths match AppRoutes constants', () {
      expect(AppRoutes.dashboard, '/dashboard');
      // expect(AppRoutes.supportTickets, '/support-tickets');
      expect(AppRoutes.saleInvoices, '/sale-invoices');
      // expect(AppRoutes.voucherRequests, '/voucher-requests');
      expect(AppRoutes.networks, '/networks');
      expect(AppRoutes.pos, '/pos');
    });
  });
}
