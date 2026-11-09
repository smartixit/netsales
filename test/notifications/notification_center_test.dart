import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/enums/notification_type.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/notifications/data/models/notification_item_model.dart';
import 'package:netsales/features/notifications/domain/entities/notification_item_entity.dart';
import 'package:netsales/features/notifications/domain/repositories/notification_repository.dart';
import 'package:netsales/features/notifications/domain/usecases/get_my_notifications_use_case.dart';
import 'package:netsales/features/notifications/domain/usecases/get_unread_notifications_count_use_case.dart';
import 'package:netsales/features/notifications/domain/usecases/mark_all_notifications_as_read_use_case.dart';
import 'package:netsales/features/notifications/domain/usecases/mark_notification_as_read_use_case.dart';
import 'package:netsales/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockNotificationRepository implements NotificationRepository {
  List<NotificationItemEntity> items;
  int unreadCountValue;
  bool shouldThrow = false;
  String? lastSearch;
  bool? lastIsReadFilter;

  MockNotificationRepository({
    required this.items,
    required this.unreadCountValue,
  });

  @override
  Future<PaginatedList<NotificationItemEntity>> getMyNotifications({
    bool? isRead,
    String? notificationType,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    if (shouldThrow) {
      throw const AppException('فشل الاتصال بخادم الإشعارات', code: '500');
    }

    lastSearch = search;
    lastIsReadFilter = isRead;

    var filtered = List<NotificationItemEntity>.from(items);
    if (isRead != null) {
      filtered = filtered.where((n) => n.isRead == isRead).toList();
    }
    if (search != null && search.isNotEmpty) {
      filtered = filtered
          .where(
            (n) =>
                n.notificationTitle.contains(search) ||
                n.notificationMessage.contains(search),
          )
          .toList();
    }

    return PaginatedList(
      items: filtered,
      nextCursor: cursor == null && filtered.length > 2
          ? 'cursor_page_2'
          : null,
    );
  }

  @override
  Future<int> getUnreadCount() async {
    if (shouldThrow) {
      throw const AppException('تعذر جلب العداد');
    }
    return unreadCountValue;
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    if (shouldThrow) {
      throw const AppException('فشل تحديث الإشعار');
    }
    final index = items.indexWhere((n) => n.notificationId == notificationId);
    if (index != -1) {
      items[index] = items[index].copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );
      if (unreadCountValue > 0) {
        unreadCountValue--;
      }
    }
  }

  @override
  Future<int> markAllAsRead() async {
    if (shouldThrow) {
      throw const AppException('فشل تعليم الكل كمقروء');
    }
    final count = items.where((n) => !n.isRead).length;
    items = items
        .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
        .toList();
    unreadCountValue = 0;
    return count;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  DateFormatter.ensureInitialized();

  final sample1 = NotificationItemEntity(
    notificationId: 101,
    userId: 1,
    notificationType: NotificationType.voucherRequestCreated,
    notificationTypeLabel: 'طلب كروت إنترنت جديد',
    notificationTitle: 'تم إنشاء طلب توريد كروت جديد',
    notificationMessage: 'قام الوكيل برفع طلب كروت رقم #55',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
  );

  final sample2 = NotificationItemEntity(
    notificationId: 102,
    userId: 1,
    notificationType: NotificationType.saleInvoiceCompleted,
    notificationTypeLabel: 'اكتملت فاتورة مبيعات',
    notificationTitle: 'فاتورة مبيعات كروت مكتملة',
    notificationMessage: 'تم إصدار الفاتورة رقم #777 بنجاح',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  );

  final sample3 = NotificationItemEntity(
    notificationId: 103,
    userId: 1,
    notificationType: NotificationType.walletDeposit,
    notificationTypeLabel: 'إيداع في المحفظة',
    notificationTitle: 'تم إيداع رصيد بنجاح',
    notificationMessage: 'تم إضافة مبلغ 50,000 ريال إلى محفظتك',
    isRead: true,
    readAt: DateTime.now().subtract(const Duration(days: 1)),
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  );

  late MockNotificationRepository mockRepo;
  late NotificationController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Get.reset();

    mockRepo = MockNotificationRepository(
      items: [sample1, sample2, sample3],
      unreadCountValue: 2,
    );

    controller = NotificationController(
      getMyNotificationsUseCase: GetMyNotificationsUseCase(mockRepo),
      getUnreadNotificationsCountUseCase: GetUnreadNotificationsCountUseCase(
        mockRepo,
      ),
      markNotificationAsReadUseCase: MarkNotificationAsReadUseCase(mockRepo),
      markAllNotificationsAsReadUseCase: MarkAllNotificationsAsReadUseCase(
        mockRepo,
      ),
    );
  });

  group('2.1 Notifications Center & Operational Delivery Tests', () {
    test('Scenario 1 & 2: Initial load fetches unread count and populates persistent notifications list', () async {
      await controller.loadInitialData();

      expect(controller.unreadCount.value, equals(2));
      expect(controller.notifications.length, equals(3));
      expect(controller.isLoading.value, isFalse);
      expect(controller.errorMessage.value, isNull);
    });

    test('Scenario 3: Marking single notification as read updates state in-place and decrements unread count', () async {
      await controller.loadInitialData();
      expect(controller.unreadCount.value, equals(2));

      await controller.markAsRead(sample1);

      expect(controller.unreadCount.value, equals(1));
      final updatedItem = controller.notifications.firstWhere(
        (n) => n.notificationId == 101,
      );
      expect(updatedItem.isRead, isTrue);
      expect(updatedItem.readAt, isNotNull);
    });

    test('Scenario 4: Marking all notifications as read updates all items and resets unread count to 0', () async {
      await controller.loadInitialData();
      expect(controller.unreadCount.value, equals(2));
      expect(controller.notifications.any((n) => !n.isRead), isTrue);

      await controller.markAllAsRead();

      expect(controller.unreadCount.value, equals(0));
      expect(controller.notifications.every((n) => n.isRead), isTrue);
      expect(mockRepo.items.every((n) => n.isRead), isTrue);
    });

    test('Scenario 5 & 6: Filter chips toggle between all, unread, and read correctly', () async {
      await controller.loadInitialData();

      // Filter unread only
      controller.setFilter(false);
      await controller.loadNotifications();
      expect(controller.notifications.length, equals(2));
      expect(controller.notifications.every((n) => !n.isRead), isTrue);
      expect(mockRepo.lastIsReadFilter, isFalse);

      // Filter read only
      controller.setFilter(true);
      await controller.loadNotifications();
      expect(controller.notifications.length, equals(1));
      expect(controller.notifications.first.notificationId, equals(103));
      expect(mockRepo.lastIsReadFilter, isTrue);

      // Reset to all
      controller.setFilter(null);
      await controller.loadNotifications();
      expect(controller.notifications.length, equals(3));
      expect(mockRepo.lastIsReadFilter, isNull);
    });

    test(
      'Scenario 7: Search filter correctly sends query to repository',
      () async {
        await controller.loadInitialData();

        controller.searchQuery.value = 'توريد';
        await controller.loadNotifications();

        expect(mockRepo.lastSearch, equals('توريد'));
        expect(controller.notifications.length, equals(1));
        expect(controller.notifications.first.notificationId, equals(101));
      },
    );

    test('Scenario 8: Foreground push arrival increments unread counter and prepends notification', () async {
      await controller.loadInitialData();
      expect(controller.unreadCount.value, equals(2));
      final originalLength = controller.notifications.length;

      final incomingPush = NotificationItemEntity(
        notificationId: 999,
        userId: 1,
        notificationType: NotificationType.systemAnnouncement,
        notificationTitle: 'تحديث نظام جديد',
        notificationMessage: 'تمت ترقية الخوادم إلى الإصدار الأحدث',
        isRead: false,
        createdAt: DateTime.now(),
      );

      controller.onNewNotificationReceived(incomingPush);

      expect(controller.unreadCount.value, equals(3));
      expect(controller.notifications.length, equals(originalLength + 1));
      expect(controller.notifications.first.notificationId, equals(999));
    });

    test('Scenario 9: Deep link routing resolves appropriate operational screen based on workspace and notification type', () async {
      // In POS workspace
      WorkspaceService.instance.currentWorkspace.value = AppWorkspace.pos;
      expect(
        NotificationType.voucherRequestCreated.defaultRoute,
        equals(AppRoutes.procurementOrders),
      );
      expect(
        NotificationType.saleInvoiceCompleted.defaultRoute,
        equals(AppRoutes.purchaseInvoices),
      );
      expect(
        NotificationType.walletDeposit.defaultRoute,
        equals(AppRoutes.posWalletStatement),
      );

      // In Network workspace
      WorkspaceService.instance.currentWorkspace.value = AppWorkspace.network;
      expect(
        NotificationType.voucherRequestCreated.defaultRoute,
        equals(AppRoutes.supplyRequestsReview),
      );
      expect(
        NotificationType.saleInvoiceCompleted.defaultRoute,
        equals(AppRoutes.wholesaleInvoices),
      );
      expect(
        NotificationType.walletDeposit.defaultRoute,
        equals(AppRoutes.networkWalletStatement),
      );
    });

    test(
      'Scenario 10: Server error states are surfaced gracefully to the user',
      () async {
        mockRepo.shouldThrow = true;

        await controller.loadNotifications();

        expect(
          controller.errorMessage.value,
          contains('فشل الاتصال بخادم الإشعارات'),
        );
        expect(controller.isLoading.value, isFalse);
      },
    );

    test('Scenario 11: Empty list state is handled properly', () async {
      mockRepo.items.clear();
      mockRepo.unreadCountValue = 0;

      await controller.loadInitialData();

      expect(controller.notifications, isEmpty);
      expect(controller.unreadCount.value, equals(0));
      expect(controller.isEmpty, isTrue);
    });

    test('Scenario 12: NotificationItemModel JSON serialization and deserialization is lossless', () {
      final jsonMap = {
        'notification_id': 505,
        'user_id': 12,
        'notification_type': 'VOUCHER_REQUEST_APPROVED',
        'notification_type_label': 'تمت الموافقة على طلب الكروت',
        'notification_title': 'طلبك معتمد',
        'notification_message': 'وافق مزود الشبكة على طلب الكروت رقم #20',
        'notification_image': 'https://example.com/logo.png',
        'is_read': 0,
        'read_at': null,
        'created_at': '2026-11-10T00:15:00.000Z',
        'updated_at': '2026-11-10T00:15:00.000Z',
      };

      final model = NotificationItemModel.fromJson(jsonMap);

      expect(model.notificationId, equals(505));
      expect(model.userId, equals(12));
      expect(
        model.notificationType,
        equals(NotificationType.voucherRequestApproved),
      );
      expect(
        model.notificationTypeLabel,
        equals('تمت الموافقة على طلب الكروت'),
      );
      expect(model.notificationTitle, equals('طلبك معتمد'));
      expect(model.notificationImage, equals('https://example.com/logo.png'));
      expect(model.isRead, isFalse);
      expect(model.createdAt, isNotNull);

      final backToJson = model.toJson();
      expect(backToJson['notification_id'], equals(505));
      expect(
        backToJson['notification_type'],
        equals('VOUCHER_REQUEST_APPROVED'),
      );
      expect(backToJson['is_read'], isFalse);
    });

    test('Scenario 13: DateFormatter.timeAgo is used for relative time without duplication', () {
      final recent = NotificationItemEntity(
        notificationId: 1,
        userId: 1,
        notificationType: NotificationType.generalInfo,
        notificationTitle: 'تنبيه',
        notificationMessage: 'مرحباً',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      final expected = DateFormatter.timeAgo(recent.createdAt!);
      expect(recent.relativeTime, equals(expected));
    });
  });
}
