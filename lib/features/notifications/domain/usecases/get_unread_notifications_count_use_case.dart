import 'package:netsales/features/notifications/domain/repositories/notification_repository.dart';

class GetUnreadNotificationsCountUseCase {
  final NotificationRepository repository;

  const GetUnreadNotificationsCountUseCase(this.repository);

  Future<int> call() {
    return repository.getUnreadCount();
  }
}
