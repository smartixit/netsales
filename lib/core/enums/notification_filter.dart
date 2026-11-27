/// خيارات تصفية مركز الإشعارات الموحدة (Notification Filter Enum).
enum NotificationFilter {
  all('ALL'),
  unread('UNREAD'),
  read('READ'),
  financial('FINANCIAL'),
  operational('OPERATIONAL'),
  security('SECURITY'),
  support('SUPPORT');

  final String wireValue;
  const NotificationFilter(this.wireValue);

  static NotificationFilter fromWire(String? raw) {
    if (raw == null) return NotificationFilter.all;
    for (final item in NotificationFilter.values) {
      if (item.wireValue == raw) return item;
    }
    return NotificationFilter.all;
  }

  bool get isReadStatusFilter =>
      this == NotificationFilter.unread || this == NotificationFilter.read;

  bool get isCategoryFilter =>
      this == NotificationFilter.financial ||
      this == NotificationFilter.operational ||
      this == NotificationFilter.security ||
      this == NotificationFilter.support;
}
