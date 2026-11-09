import 'package:netsales/features/notifications/domain/repositories/notification_repository.dart';

class MarkAllNotificationsAsReadUseCase {
  final NotificationRepository repository;

  const MarkAllNotificationsAsReadUseCase(this.repository);

  Future<int> call() {
    return repository.markAllAsRead();
  }
}

