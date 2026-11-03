import 'package:netsales/core/routing/app_routes.dart';

/// أنواع الإشعارات الرسمية المعتمدة لنظام NetSales (22 نوعاً مطابقاً لـ NotificationType في netsales_api)
enum NotificationType {
  saleInvoiceCreated('SALE_INVOICE_CREATED'),
  saleInvoiceCompleted('SALE_INVOICE_COMPLETED'),
  saleInvoiceCancelled('SALE_INVOICE_CANCELLED'),
  voucherRequestCreated('VOUCHER_REQUEST_CREATED'),
  voucherRequestApproved('VOUCHER_REQUEST_APPROVED'),
  voucherRequestRejected('VOUCHER_REQUEST_REJECTED'),
  voucherRequestCancelled('VOUCHER_REQUEST_CANCELLED'),
  walletDeposit('WALLET_DEPOSIT'),
  walletWithdrawal('WALLET_WITHDRAWAL'),
  walletTransfer('WALLET_TRANSFER'),
  supportTicketCreated('SUPPORT_TICKET_CREATED'),
  supportTicketReplied('SUPPORT_TICKET_REPLIED'),
  supportTicketClosed('SUPPORT_TICKET_CLOSED'),
  networkApproved('NETWORK_APPROVED'),
  networkRejected('NETWORK_REJECTED'),
  posApproved('POS_APPROVED'),
  posRejected('POS_REJECTED'),
  securityLoginAlert('SECURITY_LOGIN_ALERT'),
  securityDeviceBlocked('SECURITY_DEVICE_BLOCKED'),
  securityPasswordChanged('SECURITY_PASSWORD_CHANGED'),
  systemAnnouncement('SYSTEM_ANNOUNCEMENT'),
  generalInfo('GENERAL_INFO');

  final String value;
  const NotificationType(this.value);

  static NotificationType fromString(String? raw) {
    if (raw == null) return NotificationType.generalInfo;
    final upper = raw.toUpperCase().trim();
    for (final type in NotificationType.values) {
      if (type.value == upper) return type;
    }
    return NotificationType.generalInfo;
  }

  String get defaultRoute {
    switch (this) {
      case NotificationType.saleInvoiceCreated:
      case NotificationType.saleInvoiceCompleted:
      case NotificationType.saleInvoiceCancelled:
        return AppRoutes.dashboard;
      case NotificationType.voucherRequestCreated:
      case NotificationType.voucherRequestApproved:
      case NotificationType.voucherRequestRejected:
      case NotificationType.voucherRequestCancelled:
        return AppRoutes.dashboard;
      case NotificationType.walletDeposit:
      case NotificationType.walletWithdrawal:
      case NotificationType.walletTransfer:
        return AppRoutes.dashboard;
      case NotificationType.securityLoginAlert:
      case NotificationType.securityDeviceBlocked:
      case NotificationType.securityPasswordChanged:
        return AppRoutes.activeSessions;
      default:
        return AppRoutes.dashboard;
    }
  }
}

