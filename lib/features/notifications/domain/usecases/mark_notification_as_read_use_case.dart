import 'package:netsales/features/notifications/domain/repositories/notification_repository.dart';

class MarkNotificationAsReadUseCase {
  final NotificationRepository repository;

  const MarkNotificationAsReadUseCase(this.repository);

  Future<void> call(int notificationId) {
    return repository.markAsRead(notificationId);
  }
}
