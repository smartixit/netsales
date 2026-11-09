import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/notifications/domain/entities/notification_item_entity.dart';
import 'package:netsales/features/notifications/domain/usecases/get_my_notifications_use_case.dart';
import 'package:netsales/features/notifications/domain/usecases/get_unread_notifications_count_use_case.dart';
import 'package:netsales/features/notifications/domain/usecases/mark_all_notifications_as_read_use_case.dart';
import 'package:netsales/features/notifications/domain/usecases/mark_notification_as_read_use_case.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم مركز الإشعارات والتنبيهات الموجهة (Notification Center Controller)
class NotificationController extends GetxController {
  final GetMyNotificationsUseCase getMyNotificationsUseCase;
  final GetUnreadNotificationsCountUseCase getUnreadNotificationsCountUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final MarkAllNotificationsAsReadUseCase markAllNotificationsAsReadUseCase;

  NotificationController({
    required this.getMyNotificationsUseCase,
    required this.getUnreadNotificationsCountUseCase,
    required this.markNotificationAsReadUseCase,
    required this.markAllNotificationsAsReadUseCase,
  });

  static NotificationController get to => Get.find<NotificationController>();

  // State
  final notifications = <NotificationItemEntity>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isMarkingAllRead = false.obs;
  final errorMessage = RxnString();
  final nextCursor = RxnString();

  /// null = الكل، false = غير المقروءة، true = المقروءة
  final selectedFilter = Rxn<bool>();

  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  bool get hasMore => nextCursor.value != null && nextCursor.value!.isNotEmpty;
  bool get isEmpty => !isLoading.value && notifications.isEmpty;

  int _loadRevision = 0;

  @override
  void onInit() {
    super.onInit();

    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    debounce(
      searchQuery,
      (_) => loadNotifications(isRefresh: true),
      time: const Duration(milliseconds: 400),
    );

    loadInitialData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// تحميل البيانات الأولية للإشعارات مع عداد غير المقروء
  Future<void> loadInitialData() async {
    await Future.wait([fetchUnreadCount(), loadNotifications(isRefresh: true)]);
  }

  /// جلب وتحديث عداد الإشعارات غير المقروءة
  Future<void> fetchUnreadCount() async {
    try {
      final count = await getUnreadNotificationsCountUseCase();
      unreadCount.value = count >= 0 ? count : 0;
    } catch (_) {
      // Non-fatal, keep existing count
    }
  }

  /// تغيير فلتر العرض (الكل / غير المقروءة / المقروءة)
  void setFilter(bool? isRead) {
    if (selectedFilter.value == isRead) return;
    selectedFilter.value = isRead;
    loadNotifications(isRefresh: true);
  }

  /// تحميل قائمة الإشعارات من الخادم مع ترقيم المؤشر
  Future<void> loadNotifications({bool isRefresh = false}) async {
    final revision = ++_loadRevision;
    if (isRefresh) {
      nextCursor.value = null;
    }
    isLoading.value = true;
    errorMessage.value = null;

    final effectiveSearch = searchQuery.value.trim().isEmpty
        ? null
        : searchQuery.value.trim();

    try {
      final PaginatedList<NotificationItemEntity> result =
          await getMyNotificationsUseCase(
            isRead: selectedFilter.value,
            search: effectiveSearch,
            cursor: null,
          );

      if (revision != _loadRevision) return;

      notifications.assignAll(result.items);
      nextCursor.value = result.nextCursor;
    } catch (e) {
      if (revision != _loadRevision) return;
      errorMessage.value = e is AppException
          ? e.message
          : 'تعذر تحميل الإشعارات: ${e.toString()}';
    } finally {
      if (revision == _loadRevision) {
        isLoading.value = false;
      }
    }
  }

  /// تحميل المزيد من الإشعارات (Infinite Scrolling)
  Future<void> loadMoreNotifications() async {
    final cursor = nextCursor.value;
    if (isLoadingMore.value || isLoading.value || cursor == null) {
      return;
    }

    final revision = _loadRevision;
    isLoadingMore.value = true;

    final effectiveSearch = searchQuery.value.trim().isEmpty
        ? null
        : searchQuery.value.trim();

    try {
      final PaginatedList<NotificationItemEntity> result =
          await getMyNotificationsUseCase(
            isRead: selectedFilter.value,
            search: effectiveSearch,
            cursor: cursor,
          );

      if (revision != _loadRevision) return;

      final existingIds = notifications.map((n) => n.notificationId).toSet();
      final newItems = result.items
          .where((item) => !existingIds.contains(item.notificationId))
          .toList(growable: false);

      notifications.addAll(newItems);
      nextCursor.value = result.nextCursor;
    } catch (_) {
      // Allow explicit retry
    } finally {
      if (revision == _loadRevision) {
        isLoadingMore.value = false;
      }
    }
  }

  /// تعليم إشعار فردي كمقروء
  Future<void> markAsRead(NotificationItemEntity item) async {
    if (item.isRead) return;

    // Optimistic UI update
    final index = notifications.indexWhere(
      (n) => n.notificationId == item.notificationId,
    );
    if (index != -1) {
      notifications[index] = item.copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );
    }
    if (unreadCount.value > 0) {
      unreadCount.value--;
    }

    try {
      await markNotificationAsReadUseCase(item.notificationId);
    } catch (_) {
      // Revert if request fails
      if (index != -1) {
        notifications[index] = item;
      }
      unreadCount.value++;
    }
  }

  /// تعليم كافة الإشعارات كمقروءة دفعة واحدة
  Future<void> markAllAsRead() async {
    if (unreadCount.value == 0 && notifications.every((n) => n.isRead)) {
      return;
    }

    isMarkingAllRead.value = true;
    final previousUnread = unreadCount.value;
    final previousList = List<NotificationItemEntity>.from(notifications);

    // Optimistic UI update
    unreadCount.value = 0;
    notifications.assignAll(
      notifications.map(
        (n) => n.isRead ? n : n.copyWith(isRead: true, readAt: DateTime.now()),
      ),
    );

    try {
      await markAllNotificationsAsReadUseCase();
      CustomSnackbar.show(
        title: 'تم التحديث',
        message: 'تم تعليم جميع الإشعارات كمقروءة بنجاح.',
        type: SnackType.success,
      );
    } catch (e) {
      // Revert
      unreadCount.value = previousUnread;
      notifications.assignAll(previousList);
      CustomSnackbar.show(
        title: 'فشل التحديث',
        message: e is AppException
            ? e.message
            : 'تعذر تعليم الإشعارات كمقروءة.',
        type: SnackType.error,
      );
    } finally {
      isMarkingAllRead.value = false;
    }
  }

  /// معالجة النقر على الإشعار: تعليمه كمقروء ثم التوجيه الذكي
  Future<void> onNotificationTap(NotificationItemEntity item) async {
    if (!item.isRead) {
      await markAsRead(item);
    }

    final target = item.targetRoute;
    if (target.isNotEmpty && Get.currentRoute != target) {
      await Get.toNamed<dynamic>(target);
    }
  }

  /// دالة استدعاء لحظية عند وصول إشعار جديد أثناء فتح التطبيق
  void onNewNotificationReceived([NotificationItemEntity? newItem]) {
    unreadCount.value++;
    if (newItem != null) {
      notifications.insert(0, newItem);
    } else {
      loadNotifications(isRefresh: true);
    }
  }
}
