import '../routing/app_routes.dart';

/// الأنواع والتصنيفات الدومينية الموحدة للإشعارات والتنبيهات (Enterprise Notification Type Enum).
///
/// يمثل المصدر الأوحد للحقيقة لتصنيف الإشعارات وتحديد مسارات التوجيه الذكي (Deep Linking)
/// مع الكيانات المرتبطة مطابقاً لـ NotificationType.php في الواجهة الخلفية.
enum NotificationType {
  // فواتير وعمليات بيع الكروت
  saleInvoiceCreated('SALE_INVOICE_CREATED'),
  saleInvoiceCompleted('SALE_INVOICE_COMPLETED'),
  saleInvoiceCancelled('SALE_INVOICE_CANCELLED'),

  // طلبات كروت الإنترنت
  voucherRequestCreated('VOUCHER_REQUEST_CREATED'),
  voucherRequestApproved('VOUCHER_REQUEST_APPROVED'),
  voucherRequestRejected('VOUCHER_REQUEST_REJECTED'),
  voucherRequestCancelled('VOUCHER_REQUEST_CANCELLED'),

  // المحافظ والحركات المالية
  walletDeposit('WALLET_DEPOSIT'),
  walletWithdrawal('WALLET_WITHDRAWAL'),
  walletTransfer('WALLET_TRANSFER'),

  // تذاكر ورسائل الدعم الفني
  supportTicketCreated('SUPPORT_TICKET_CREATED'),
  supportTicketReplied('SUPPORT_TICKET_REPLIED'),
  supportTicketClosed('SUPPORT_TICKET_CLOSED'),

  // اعتماد وحالات الشبكات ونقاط البيع
  networkApproved('NETWORK_APPROVED'),
  networkRejected('NETWORK_REJECTED'),
  posApproved('POS_APPROVED'),
  posRejected('POS_REJECTED'),

  // الأمان وحماية الأجهزة والحسابات
  securityLoginAlert('SECURITY_LOGIN_ALERT'),
  securityDeviceBlocked('SECURITY_DEVICE_BLOCKED'),
  securityPasswordChanged('SECURITY_PASSWORD_CHANGED'),

  // إعلانات النظام العامة
  systemAnnouncement('SYSTEM_ANNOUNCEMENT'),
  generalInfo('GENERAL_INFO');

  const NotificationType(this.value);

  final String value;

  /// تحويل آمن من النص القادم من API أو FCM Payload
  static NotificationType fromString(String? val) {
    if (val == null || val.isEmpty) return NotificationType.generalInfo;
    final upper = val.toUpperCase().trim();
    for (final type in NotificationType.values) {
      if (type.value == upper) {
        return type;
      }
    }
    return NotificationType.generalInfo;
  }

  /// الاسم والوصف المعرب المعياري لنوع الإشعار
  String get label {
    switch (this) {
      case NotificationType.saleInvoiceCreated:
        return 'فاتورة مبيعات جديدة';
      case NotificationType.saleInvoiceCompleted:
        return 'اكتمال فاتورة المبيعات';
      case NotificationType.saleInvoiceCancelled:
        return 'إلغاء فاتورة مبيعات';

      case NotificationType.voucherRequestCreated:
        return 'طلب كروت إنترنت جديد';
      case NotificationType.voucherRequestApproved:
        return 'تمت الموافقة على طلب الكروت';
      case NotificationType.voucherRequestRejected:
        return 'تم رفض طلب الكروت';
      case NotificationType.voucherRequestCancelled:
        return 'تم إلغاء طلب الكروت';

      case NotificationType.walletDeposit:
        return 'إيداع في المحفظة';
      case NotificationType.walletWithdrawal:
        return 'سحب من المحفظة';
      case NotificationType.walletTransfer:
        return 'تحويل رصيد محفظة';

      case NotificationType.supportTicketCreated:
        return 'تذكرة دعم فني جديدة';
      case NotificationType.supportTicketReplied:
        return 'رد جديد على تذكرة الدعم';
      case NotificationType.supportTicketClosed:
        return 'إغلاق تذكرة الدعم';

      case NotificationType.networkApproved:
        return 'اعتماد مزود الشبكة';
      case NotificationType.networkRejected:
        return 'رفض مزود الشبكة';
      case NotificationType.posApproved:
        return 'اعتماد نقطة البيع';
      case NotificationType.posRejected:
        return 'رفض نقطة البيع';

      case NotificationType.securityLoginAlert:
        return 'تنبيه تسجيل دخول';
      case NotificationType.securityDeviceBlocked:
        return 'حظر أو تعطيل جهاز';
      case NotificationType.securityPasswordChanged:
        return 'تغيير كلمة المرور';

      case NotificationType.systemAnnouncement:
        return 'إعلان إداري عام';
      case NotificationType.generalInfo:
        return 'إشعار توجيهي عام';
    }
  }

  /// التصنيف العام لنوع الإشعار (Category Grouping)
  String get category {
    switch (this) {
      case NotificationType.saleInvoiceCreated:
      case NotificationType.saleInvoiceCompleted:
      case NotificationType.saleInvoiceCancelled:
      case NotificationType.walletDeposit:
      case NotificationType.walletWithdrawal:
      case NotificationType.walletTransfer:
        return 'FINANCIAL';

      case NotificationType.voucherRequestCreated:
      case NotificationType.voucherRequestApproved:
      case NotificationType.voucherRequestRejected:
      case NotificationType.voucherRequestCancelled:
      case NotificationType.networkApproved:
      case NotificationType.networkRejected:
      case NotificationType.posApproved:
      case NotificationType.posRejected:
        return 'OPERATIONAL';

      case NotificationType.supportTicketCreated:
      case NotificationType.supportTicketReplied:
      case NotificationType.supportTicketClosed:
        return 'SUPPORT';

      case NotificationType.securityLoginAlert:
      case NotificationType.securityDeviceBlocked:
      case NotificationType.securityPasswordChanged:
        return 'SECURITY';

      case NotificationType.systemAnnouncement:
      case NotificationType.generalInfo:
        return 'SYSTEM';
    }
  }

  /// مسار التوجيه الافتراضي في التطبيق عند النقر
  String get defaultRoute {
    switch (this) {
      case NotificationType.saleInvoiceCreated:
      case NotificationType.saleInvoiceCompleted:
      case NotificationType.saleInvoiceCancelled:
        return AppRoutes.saleInvoices;

      case NotificationType.voucherRequestCreated:
      case NotificationType.voucherRequestApproved:
      case NotificationType.voucherRequestRejected:
      case NotificationType.voucherRequestCancelled:
        return AppRoutes.requests;

      case NotificationType.walletDeposit:
      case NotificationType.walletWithdrawal:
      case NotificationType.walletTransfer:
        return AppRoutes.networkWallets;

      case NotificationType.supportTicketCreated:
      case NotificationType.supportTicketReplied:
      case NotificationType.supportTicketClosed:
        return AppRoutes.support;

      case NotificationType.networkApproved:
      case NotificationType.networkRejected:
        return AppRoutes.networks;

      case NotificationType.posApproved:
      case NotificationType.posRejected:
        return AppRoutes.pos;

      case NotificationType.securityLoginAlert:
      case NotificationType.securityDeviceBlocked:
      case NotificationType.securityPasswordChanged:
        return AppRoutes.notifications;

      case NotificationType.systemAnnouncement:
      case NotificationType.generalInfo:
        return AppRoutes.notifications;
    }
  }

  /// هل يرتبط الإشعار بكيان محدد (مثل رقم الفاتورة أو التذكرة)
  bool get requiresEntityId {
    switch (this) {
      case NotificationType.saleInvoiceCreated:
      case NotificationType.saleInvoiceCompleted:
      case NotificationType.saleInvoiceCancelled:
      case NotificationType.voucherRequestCreated:
      case NotificationType.voucherRequestApproved:
      case NotificationType.voucherRequestRejected:
      case NotificationType.voucherRequestCancelled:
      case NotificationType.walletDeposit:
      case NotificationType.walletWithdrawal:
      case NotificationType.walletTransfer:
      case NotificationType.supportTicketCreated:
      case NotificationType.supportTicketReplied:
      case NotificationType.supportTicketClosed:
      case NotificationType.networkApproved:
      case NotificationType.networkRejected:
      case NotificationType.posApproved:
      case NotificationType.posRejected:
        return true;
      default:
        return false;
    }
  }
}
