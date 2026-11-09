import 'package:get/get.dart';
import 'package:netsales/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:netsales/features/notifications/data/datasources/notification_remote_data_source_impl.dart';
import 'package:netsales/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:netsales/features/notifications/domain/repositories/notification_repository.dart';
import 'package:netsales/features/notifications/domain/usecases/get_my_notifications_use_case.dart';
import 'package:netsales/features/notifications/domain/usecases/get_unread_notifications_count_use_case.dart';
import 'package:netsales/features/notifications/domain/usecases/mark_all_notifications_as_read_use_case.dart';
import 'package:netsales/features/notifications/domain/usecases/mark_notification_as_read_use_case.dart';
import 'package:netsales/features/notifications/presentation/controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<NotificationRemoteDataSource>(
      () => const NotificationRemoteDataSourceImpl(),
      fenix: true,
    );

    // Repository
    Get.lazyPut<NotificationRepository>(
      () => NotificationRepositoryImpl(
        Get.find<NotificationRemoteDataSource>(),
      ),
      fenix: true,
    );

    // Use Cases
    Get.lazyPut(
      () => GetMyNotificationsUseCase(Get.find<NotificationRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => GetUnreadNotificationsCountUseCase(
        Get.find<NotificationRepository>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => MarkNotificationAsReadUseCase(Get.find<NotificationRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () =>
          MarkAllNotificationsAsReadUseCase(Get.find<NotificationRepository>()),
      fenix: true,
    );

    // Controller
    Get.lazyPut<NotificationController>(
      () => NotificationController(
        getMyNotificationsUseCase: Get.find<GetMyNotificationsUseCase>(),
        getUnreadNotificationsCountUseCase:
            Get.find<GetUnreadNotificationsCountUseCase>(),
        markNotificationAsReadUseCase:
            Get.find<MarkNotificationAsReadUseCase>(),
        markAllNotificationsAsReadUseCase:
            Get.find<MarkAllNotificationsAsReadUseCase>(),
      ),
      fenix: true,
    );
  }
}
