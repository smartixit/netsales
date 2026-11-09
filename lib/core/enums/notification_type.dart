import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/workspace_service.dart';

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
  generalInfo('GENERAL_INFO'),
  unknown('UNKNOWN');

  final String value;
  const NotificationType(this.value);

  /// تحليل آمن ومطابق للقيمة السلكية الصادرة من الخادم
  static NotificationType fromWire(String? raw) {
    if (raw == null) return NotificationType.unknown;
    final trimmed = raw.trim();
    for (final type in NotificationType.values) {
      if (type.value == trimmed) return type;
    }
    return NotificationType.unknown;
  }

  /// متوافق مع الاستخدامات السابقة مع ضمان عدم إخفاء الحالات المجهولة
  static NotificationType fromString(String? raw) => fromWire(raw);

  bool get isKnown => this != NotificationType.unknown;

  String get defaultRoute {
    final isPos = WorkspaceService.instance.activeWorkspace == AppWorkspace.pos;

    switch (this) {
      case NotificationType.saleInvoiceCreated:
      case NotificationType.saleInvoiceCompleted:
      case NotificationType.saleInvoiceCancelled:
        return isPos ? AppRoutes.purchaseInvoices : AppRoutes.wholesaleInvoices;

      case NotificationType.voucherRequestCreated:
      case NotificationType.voucherRequestApproved:
      case NotificationType.voucherRequestRejected:
      case NotificationType.voucherRequestCancelled:
        return isPos
            ? AppRoutes.procurementOrders
            : AppRoutes.supplyRequestsReview;

      case NotificationType.walletDeposit:
      case NotificationType.walletWithdrawal:
      case NotificationType.walletTransfer:
        return isPos
            ? AppRoutes.posWalletStatement
            : AppRoutes.networkWalletStatement;

      case NotificationType.networkApproved:
      case NotificationType.networkRejected:
        return isPos
            ? AppRoutes.linkedNetworksCatalog
            : AppRoutes.networkWorkspace;

      case NotificationType.posApproved:
      case NotificationType.posRejected:
        return isPos ? AppRoutes.posWorkspace : AppRoutes.posDirectory;

      case NotificationType.securityLoginAlert:
      case NotificationType.securityDeviceBlocked:
      case NotificationType.securityPasswordChanged:
        return AppRoutes.activeSessions;

      case NotificationType.systemAnnouncement:
      case NotificationType.generalInfo:
      case NotificationType.supportTicketCreated:
      case NotificationType.supportTicketReplied:
      case NotificationType.supportTicketClosed:
      case NotificationType.unknown:
        return AppRoutes.notifications;
    }
  }
}
