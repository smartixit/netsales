import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/notification_filter.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/media_gallery_item_model.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/notifications/domain/entities/notification_item_entity.dart';
import 'package:netsales/features/notifications/domain/usecases/get_my_notifications_use_case.dart';
import 'package:netsales/features/notifications/domain/usecases/get_unread_notifications_count_use_case.dart';
import 'package:netsales/features/notifications/domain/usecases/mark_all_notifications_as_read_use_case.dart';
import 'package:netsales/features/notifications/domain/usecases/mark_notification_as_read_use_case.dart';
import 'package:netsales/features/notifications/presentation/widgets/notification_details_sheet.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';
import 'package:netsales/widgets/media_gallery/media_gallery_viewer.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم مركز الإشعارات والتنبيهات الموجهة (NotificationCenter Controller).
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

  // -------------------------------------------------------------------------
  // State
  // -------------------------------------------------------------------------

  final notifications = <NotificationItemEntity>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isMarkingAllRead = false.obs;
  final errorMessage = RxnString();
  final nextCursor = RxnString();

  final selectedFilter = NotificationFilter.all.obs;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  Timer? _debounce;
  bool _suppressSearchListener = false;
  int _loadRevision = 0;

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    loadInitialData();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    if (_suppressSearchListener) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      searchQuery.value = searchController.text.trim();
      loadNotifications(isRefresh: true);
    });
  }

  // -------------------------------------------------------------------------
  // Computed / Filters / KPIs
  // -------------------------------------------------------------------------

  bool get hasMore => nextCursor.value != null && nextCursor.value!.isNotEmpty;

  bool get isEmpty => !isLoading.value && filteredNotifications.isEmpty;

  bool get hasActiveFilters =>
      searchQuery.value.trim().isNotEmpty ||
      selectedFilter.value != NotificationFilter.all;

  bool? get _apiIsReadParam => switch (selectedFilter.value) {
    NotificationFilter.unread => false,
    NotificationFilter.read => true,
    _ => null,
  };

  int get totalCount => notifications.length;

  int countForCategory(NotificationFilter filter) => notifications
      .where((n) => n.notificationType.category == filter.wireValue)
      .length;

  List<NotificationItemEntity> get filteredNotifications {
    final active = selectedFilter.value;
    if (!active.isCategoryFilter) return notifications;
    return notifications
        .where((n) => n.notificationType.category == active.wireValue)
        .toList(growable: false);
  }

  List<CustomSearchFilterOption<NotificationFilter>> get filterOptions {
    return NotificationFilter.values.map((filter) {
      final pres = EnumPresentationRegistry.resolveNotificationFilter(filter);
      return CustomSearchFilterOption<NotificationFilter>(
        value: filter,
        label: pres.label,
        icon: pres.icon,
      );
    }).toList(growable: false);
  }

  List<CustomKpiCardData> buildKpiCards(BuildContext context) {
    final colors = context.colors;
    const kpiFilters = [
      NotificationFilter.all,
      NotificationFilter.unread,
      NotificationFilter.financial,
      NotificationFilter.security,
    ];

    return kpiFilters.map((filter) {
      final pres = EnumPresentationRegistry.resolveNotificationFilter(filter);
      final count = switch (filter) {
        NotificationFilter.all => totalCount,
        NotificationFilter.unread => unreadCount.value,
        _ => countForCategory(filter),
      };

      return CustomKpiCardData(
        label: pres.label,
        count: count,
        icon: pres.icon ?? Icons.notifications_rounded,
        accentColor: pres.tone.resolveColor(colors),
        statusKey: filter.wireValue,
      );
    }).toList(growable: false);
  }

  // -------------------------------------------------------------------------
  // Data Loading & Filters
  // -------------------------------------------------------------------------

  Future<void> loadInitialData() async {
    await Future.wait([fetchUnreadCount(), loadNotifications(isRefresh: true)]);
  }

  Future<void> fetchUnreadCount() async {
    try {
      final count = await getUnreadNotificationsCountUseCase();
      unreadCount.value = count >= 0 ? count : 0;
    } catch (_) {
      // Non-fatal
    }
  }

  void setFilter(NotificationFilter filter) {
    final next = selectedFilter.value == filter && filter != NotificationFilter.all
        ? NotificationFilter.all
        : filter;

    final previousWasReadParam = _apiIsReadParam;
    selectedFilter.value = next;
    final currentReadParam = _apiIsReadParam;

    if (previousWasReadParam != currentReadParam ||
        next == NotificationFilter.all) {
      loadNotifications(isRefresh: true);
    }
  }

  void onKpiSelected(String? statusKey) {
    setFilter(NotificationFilter.fromWire(statusKey));
  }

  void clearSearch() {
    _debounce?.cancel();
    _suppressSearchListener = true;
    searchController.clear();
    _suppressSearchListener = false;
    searchQuery.value = '';
    loadNotifications(isRefresh: true);
  }

  void resetFilters() {
    _debounce?.cancel();
    _suppressSearchListener = true;
    searchController.clear();
    _suppressSearchListener = false;
    searchQuery.value = '';
    selectedFilter.value = NotificationFilter.all;
    loadNotifications(isRefresh: true);
  }

  Future<void> loadNotifications({bool isRefresh = false}) async {
    final revision = ++_loadRevision;
    if (isRefresh) {
      nextCursor.value = null;
    }
    isLoading.value = true;
    errorMessage.value = null;

    final effectiveSearch =
        searchQuery.value.trim().isEmpty ? null : searchQuery.value.trim();

    try {
      final PaginatedList<NotificationItemEntity> result =
          await getMyNotificationsUseCase(
            isRead: _apiIsReadParam,
            search: effectiveSearch,
            cursor: null,
          );

      if (revision != _loadRevision || isClosed) return;

      notifications.assignAll(result.items);
      nextCursor.value = result.nextCursor;
    } catch (e) {
      if (revision != _loadRevision || isClosed) return;
      errorMessage.value = AppException.sanitizeMessage(
        e,
        fallback: 'تعذر تحميل الإشعارات.',
      );
    } finally {
      if (revision == _loadRevision && !isClosed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadMoreNotifications() async {
    final cursor = nextCursor.value;
    if (isLoadingMore.value || isLoading.value || cursor == null) {
      return;
    }

    final revision = _loadRevision;
    isLoadingMore.value = true;

    final effectiveSearch =
        searchQuery.value.trim().isEmpty ? null : searchQuery.value.trim();

    try {
      final PaginatedList<NotificationItemEntity> result =
          await getMyNotificationsUseCase(
            isRead: _apiIsReadParam,
            search: effectiveSearch,
            cursor: cursor,
          );

      if (revision != _loadRevision || isClosed) return;

      final existingIds = notifications.map((n) => n.notificationId).toSet();
      final newItems = result.items
          .where((item) => !existingIds.contains(item.notificationId))
          .toList(growable: false);

      notifications.addAll(newItems);
      nextCursor.value = result.nextCursor;
    } catch (_) {
      // Allow retry
    } finally {
      if (revision == _loadRevision && !isClosed) {
        isLoadingMore.value = false;
      }
    }
  }

  // -------------------------------------------------------------------------
  // Read State & Media Preview & Details
  // -------------------------------------------------------------------------

  Future<void> markAsRead(NotificationItemEntity item) async {
    if (item.isRead) return;

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
      if (index != -1) {
        notifications[index] = item;
      }
      unreadCount.value++;
    }
  }

  Future<void> markAllAsRead() async {
    if (unreadCount.value == 0 && notifications.every((n) => n.isRead)) {
      return;
    }

    isMarkingAllRead.value = true;
    final previousUnread = unreadCount.value;
    final previousList = List<NotificationItemEntity>.from(notifications);

    unreadCount.value = 0;
    notifications.assignAll(
      notifications.map(
        (n) => n.isRead ? n : n.copyWith(isRead: true, readAt: DateTime.now()),
      ),
    );

    try {
      await CustomAnimationOverlay.showLoading(
        message: 'جارٍ تعليم كافة الإشعارات كمقروءة...',
      );

      await markAllNotificationsAsReadUseCase();

      await CustomAnimationOverlay.showSuccess(
        message: 'تم تعليم جميع الإشعارات كمقروءة بنجاح.',
      );
    } catch (e) {
      unreadCount.value = previousUnread;
      notifications.assignAll(previousList);
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      CustomSnackbar.show(
        title: 'فشل التحديث',
        message: AppException.sanitizeMessage(
          e,
          fallback: 'تعذر تعليم الإشعارات كمقروءة.',
        ),
        type: SnackType.error,
      );
    } finally {
      isMarkingAllRead.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
    }
  }

  Future<void> openNotificationCenter() async {
    if (Get.currentRoute != AppRoutes.notifications) {
      await Get.toNamed<dynamic>(AppRoutes.notifications);
    }
  }

  Future<void> openMediaPreview(
    BuildContext context,
    NotificationItemEntity item,
  ) async {
    if (!item.hasImage) return;
    await MediaGalleryViewer.showSingle(
      context,
      MediaGalleryItemModel(
        url: item.notificationImage!,
        title: item.notificationTitle,
        subtitle: item.relativeTime,
        type: MediaGalleryType.image,
        heroTag: 'notification_media_${item.notificationId}',
      ),
    );
  }

  Future<void> openNotificationDetails(
    BuildContext context,
    NotificationItemEntity item,
  ) async {
    unawaited(markAsRead(item));
    await CustomBottomSheet.show<void>(
      title: 'تفاصيل الإشعار',
      leadingIcon: Icons.notifications_rounded,
      child: NotificationDetailsSheet(
        notification: item,
        onPreviewImage: item.hasImage
            ? () => openMediaPreview(context, item)
            : null,
        onNavigateTarget: item.hasTargetRoute
            ? () {
                Get.back<void>();
                onNotificationTap(item);
              }
            : null,
      ),
    );
  }

  Future<void> onNotificationTap(NotificationItemEntity item) async {
    if (!item.isRead) {
      await markAsRead(item);
    }

    final target = item.targetRoute;
    if (target.isNotEmpty && Get.currentRoute != target) {
      await Get.toNamed<dynamic>(target);
    }
  }

  void onNewNotificationReceived([NotificationItemEntity? newItem]) {
    unreadCount.value++;
    if (newItem != null) {
      notifications.insert(0, newItem);
    } else {
      loadNotifications(isRefresh: true);
    }
  }
}
