import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/notification_type.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/notifications/domain/entities/notification_item_entity.dart';
import 'package:netsales/features/notifications/domain/repositories/notification_repository.dart';
import 'package:netsales/features/notifications/domain/usecases/get_my_notifications_use_case.dart';
import 'package:netsales/features/notifications/domain/usecases/get_unread_notifications_count_use_case.dart';
import 'package:netsales/features/notifications/domain/usecases/mark_all_notifications_as_read_use_case.dart';
import 'package:netsales/features/notifications/domain/usecases/mark_notification_as_read_use_case.dart';
import 'package:netsales/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:netsales/features/notifications/presentation/screens/notification_center_screen.dart';
import 'package:netsales/features/notifications/presentation/widgets/notification_item_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeNotificationRepository implements NotificationRepository {
  List<NotificationItemEntity> items;
  int unreadCount;

  FakeNotificationRepository({required this.items, required this.unreadCount});

  @override
  Future<PaginatedList<NotificationItemEntity>> getMyNotifications({
    bool? isRead,
    String? notificationType,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
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
    return PaginatedList(items: filtered, nextCursor: null);
  }

  @override
  Future<int> getUnreadCount() async => unreadCount;

  @override
  Future<void> markAsRead(int notificationId) async {
    final idx = items.indexWhere((n) => n.notificationId == notificationId);
    if (idx != -1) {
      items[idx] = items[idx].copyWith(isRead: true, readAt: DateTime.now());
      if (unreadCount > 0) unreadCount--;
    }
  }

  @override
  Future<int> markAllAsRead() async {
    final count = items.where((n) => !n.isRead).length;
    items = items
        .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
        .toList();
    unreadCount = 0;
    return count;
  }
}

Widget createNotificationTestScreen() {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    minTextAdapt: true,
    builder: (context, _) => GetMaterialApp(
      theme: AppThemes.dark,
      locale: const Locale('ar'),
      home: const NotificationCenterScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  DateFormatter.ensureInitialized();

  final sample1 = NotificationItemEntity(
    notificationId: 101,
    userId: 1,
    notificationType: NotificationType.saleInvoiceCreated,
    notificationTypeLabel: 'فاتورة جديدة',
    notificationTitle: 'تم إصدار فاتورة بيع كروت',
    notificationMessage: 'تم إصدار فاتورة مبيعات جديدة رقم #100',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
  );

  late FakeNotificationRepository fakeRepo;
  late NotificationController controller;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();

    fakeRepo = FakeNotificationRepository(items: [sample1], unreadCount: 1);

    controller = NotificationController(
      getMyNotificationsUseCase: GetMyNotificationsUseCase(fakeRepo),
      getUnreadNotificationsCountUseCase: GetUnreadNotificationsCountUseCase(
        fakeRepo,
      ),
      markNotificationAsReadUseCase: MarkNotificationAsReadUseCase(fakeRepo),
      markAllNotificationsAsReadUseCase: MarkAllNotificationsAsReadUseCase(
        fakeRepo,
      ),
    );
    Get.put<NotificationController>(controller);
  });

  group('NotificationCenterScreen Composition & VIP UI Tests', () {
    testWidgets(
      'renders CustomRefreshablePage.slivers and notification items',
      (tester) async {
        await tester.pumpWidget(createNotificationTestScreen());
        await tester.pumpAndSettle();

        // CustomRefreshablePage present
        expect(find.byType(CustomRefreshablePage), findsOneWidget);

        // Notification item card present
        expect(find.byType(NotificationItemCard), findsOneWidget);
        expect(find.text('تم إصدار فاتورة بيع كروت'), findsOneWidget);

        // AppBar action button for mark-all-read present
        expect(find.byIcon(Icons.done_all_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'tapping mark all as read triggers controller and updates unread badge',
      (tester) async {
        await tester.pumpWidget(createNotificationTestScreen());
        await tester.pumpAndSettle();

        expect(controller.unreadCount.value, equals(1));

        // Tap the action button
        await tester.tap(find.byIcon(Icons.done_all_rounded));
        await tester.pumpAndSettle();

        expect(controller.unreadCount.value, equals(0));
        expect(fakeRepo.items.first.isRead, isTrue);
      },
    );

    testWidgets(
      'displays the shared empty state when search yields no matches',
      (tester) async {
        await tester.pumpWidget(createNotificationTestScreen());
        await tester.pumpAndSettle();

        // Enter search query with no matches
        controller.searchController.text = 'كلمة غير موجودة بتاتا';
        // Let the controller's production debounce interval elapse so its
        // scheduled search completes before the widget test is torn down.
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();

        expect(find.byType(CustomStateView), findsOneWidget);
        expect(find.text('لا توجد إشعارات مطابقة'), findsOneWidget);
      },
    );

    testWidgets(
      'keeps loaded notifications visible while a filtered request is loading',
      (tester) async {
        await tester.pumpWidget(createNotificationTestScreen());
        await tester.pumpAndSettle();

        // Initially loaded and showing items
        expect(find.byType(NotificationItemCard), findsOneWidget);

        // Simulate filter change loading
        controller.isLoading.value = true;
        await tester.pump();

        // Existing results remain visible; the page-level skeleton is reserved
        // for the initial empty load to avoid replacing useful content.
        expect(find.byType(NotificationItemCard), findsOneWidget);
        expect(find.byType(CustomStateView), findsNothing);

        controller.isLoading.value = false;
        await tester.pump();
        expect(find.byType(NotificationItemCard), findsOneWidget);
      },
    );
  });
}
