import 'package:flutter/material.dart';
import 'package:netsales/core/enums/backup_status.dart';
import 'package:netsales/core/enums/device_type.dart';
import 'package:netsales/core/enums/invoice_payment_status.dart';
import 'package:netsales/core/enums/linking_challenge_status.dart';
import 'package:netsales/core/enums/membership_status.dart';
import 'package:netsales/core/enums/provider_subscription_status.dart';
import 'package:netsales/core/enums/request_status.dart';
import 'package:netsales/core/enums/role_key.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/enums/user_device_status.dart';
import 'package:netsales/core/enums/user_status.dart';
import 'package:netsales/core/enums/wallet_operation_type.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/features/commercial/domain/entities/network_status.dart';
import 'package:netsales/features/commercial/domain/entities/pos_status.dart';

/// السجل المركزي الموحد لتمثيل الـ Enums بصرياً (Centralized Enum Presentation Registry)
/// هو المرجع المعتمد والوحيد لكافة واجهات التطبيق في ترجمة حالات الـ Enums إلى معانٍ بصرية
class EnumPresentationRegistry {
  EnumPresentationRegistry._();

  // ──────────────────────────────────────────────────────────────────────────
  // 1. مزود الشبكة (NetworkStatus)
  // ──────────────────────────────────────────────────────────────────────────
  static EnumPresentation resolveNetworkStatus(
    NetworkStatus status, {
    String? serverLabel,
  }) {
    final label = _effectiveLabel(serverLabel, switch (status) {
      NetworkStatus.active => 'مفعّل',
      NetworkStatus.inactive => 'غير مفعّل',
      NetworkStatus.pending => 'قيد الانتظار',
      NetworkStatus.rejected => 'تم الرفض',
      NetworkStatus.banned => 'محظور',
      NetworkStatus.unknown => 'حالة غير معروفة',
    });

    return switch (status) {
      NetworkStatus.active => EnumPresentation(
        label: label,
        tone: SemanticTone.success,
        icon: Icons.check_circle_rounded,
      ),
      NetworkStatus.inactive => EnumPresentation(
        label: label,
        tone: SemanticTone.neutral,
        icon: Icons.pause_circle_rounded,
      ),
      NetworkStatus.pending => EnumPresentation(
        label: label,
        tone: SemanticTone.warning,
        icon: Icons.hourglass_top_rounded,
      ),
      NetworkStatus.rejected => EnumPresentation(
        label: label,
        tone: SemanticTone.danger,
        icon: Icons.cancel_rounded,
      ),
      NetworkStatus.banned => EnumPresentation(
        label: label,
        tone: SemanticTone.danger,
        icon: Icons.block_rounded,
      ),
      NetworkStatus.unknown => EnumPresentation.unknown(fallbackLabel: label),
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 2. نقطة البيع (PosStatus)
  // ──────────────────────────────────────────────────────────────────────────
  static EnumPresentation resolvePosStatus(
    PosStatus status, {
    String? serverLabel,
  }) {
    final label = _effectiveLabel(serverLabel, switch (status) {
      PosStatus.active => 'مفعّل',
      PosStatus.inactive => 'غير مفعّل',
      PosStatus.pending => 'قيد الانتظار',
      PosStatus.rejected => 'تم الرفض',
      PosStatus.banned => 'محظور',
      PosStatus.unknown => 'حالة غير معروفة',
    });

    return switch (status) {
      PosStatus.active => EnumPresentation(
        label: label,
        tone: SemanticTone.success,
        icon: Icons.check_circle_rounded,
      ),
      PosStatus.inactive => EnumPresentation(
        label: label,
        tone: SemanticTone.neutral,
        icon: Icons.pause_circle_rounded,
      ),
      PosStatus.pending => EnumPresentation(
        label: label,
        tone: SemanticTone.warning,
        icon: Icons.hourglass_top_rounded,
      ),
      PosStatus.rejected => EnumPresentation(
        label: label,
        tone: SemanticTone.danger,
        icon: Icons.cancel_rounded,
      ),
      PosStatus.banned => EnumPresentation(
        label: label,
        tone: SemanticTone.danger,
        icon: Icons.block_rounded,
      ),
      PosStatus.unknown => EnumPresentation.unknown(fallbackLabel: label),
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 3. حالة المستخدم (UserStatus)
  // ──────────────────────────────────────────────────────────────────────────
  static EnumPresentation resolveUserStatus(
    UserStatus status, {
    String? serverLabel,
  }) {
    final label = _effectiveLabel(serverLabel, switch (status) {
      UserStatus.active => 'مفعّل',
      UserStatus.inactive => 'غير مفعّل',
      UserStatus.pending => 'قيد الانتظار',
      UserStatus.banned => 'محظور',
      UserStatus.unknown => 'حالة غير معروفة',
    });

    return switch (status) {
      UserStatus.active => EnumPresentation(
        label: label,
        tone: SemanticTone.success,
        icon: Icons.check_circle_rounded,
      ),
      UserStatus.inactive => EnumPresentation(
        label: label,
        tone: SemanticTone.neutral,
        icon: Icons.pause_circle_rounded,
      ),
      UserStatus.pending => EnumPresentation(
        label: label,
        tone: SemanticTone.warning,
        icon: Icons.hourglass_top_rounded,
      ),
      UserStatus.banned => EnumPresentation(
        label: label,
        tone: SemanticTone.danger,
        icon: Icons.block_rounded,
      ),
      UserStatus.unknown => EnumPresentation.unknown(fallbackLabel: label),
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 4. جهاز المستخدم (UserDeviceStatus)
  // ──────────────────────────────────────────────────────────────────────────
  static EnumPresentation resolveUserDeviceStatus(
    UserDeviceStatus status, {
    String? serverLabel,
  }) {
    final label = _effectiveLabel(serverLabel, switch (status) {
      UserDeviceStatus.active => 'مفعّل',
      UserDeviceStatus.inactive => 'غير مفعّل',
      UserDeviceStatus.pending => 'قيد الانتظار',
      UserDeviceStatus.banned => 'محظور',
      UserDeviceStatus.unknown => 'حالة غير معروفة',
    });

    return switch (status) {
      UserDeviceStatus.active => EnumPresentation(
        label: label,
        tone: SemanticTone.success,
        icon: Icons.check_circle_rounded,
      ),
      UserDeviceStatus.inactive => EnumPresentation(
        label: label,
        tone: SemanticTone.neutral,
        icon: Icons.pause_circle_rounded,
      ),
      UserDeviceStatus.pending => EnumPresentation(
        label: label,
        tone: SemanticTone.warning,
        icon: Icons.hourglass_top_rounded,
      ),
      UserDeviceStatus.banned => EnumPresentation(
        label: label,
        tone: SemanticTone.danger,
        icon: Icons.block_rounded,
      ),
      UserDeviceStatus.unknown => EnumPresentation.unknown(
        fallbackLabel: label,
      ),
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 5. نوع الجهاز (DeviceType) — تصنيف حيادي دون ألوان تحذيرية
  // ──────────────────────────────────────────────────────────────────────────
  static EnumPresentation resolveDeviceType(
    DeviceType type, {
    String? serverLabel,
  }) {
    final label = _effectiveLabel(serverLabel, switch (type) {
      DeviceType.android => 'أندرويد',
      DeviceType.ios => 'آيفون',
      DeviceType.windows => 'ويندوز',
      DeviceType.linux => 'لينكس',
      DeviceType.mac => 'ماك',
      DeviceType.web => 'متصفح ويب',
      DeviceType.unknown => 'جهاز غير محدد',
    });

    return switch (type) {
      DeviceType.android => EnumPresentation(
        label: label,
        tone: SemanticTone.neutral,
        icon: Icons.phone_android_rounded,
      ),
      DeviceType.ios => EnumPresentation(
        label: label,
        tone: SemanticTone.neutral,
        icon: Icons.phone_iphone_rounded,
      ),
      DeviceType.windows => EnumPresentation(
        label: label,
        tone: SemanticTone.neutral,
        icon: Icons.desktop_windows_rounded,
      ),
      DeviceType.linux => EnumPresentation(
        label: label,
        tone: SemanticTone.neutral,
        icon: Icons.laptop_chromebook_rounded,
      ),
      DeviceType.mac => EnumPresentation(
        label: label,
        tone: SemanticTone.neutral,
        icon: Icons.laptop_mac_rounded,
      ),
      DeviceType.web => EnumPresentation(
        label: label,
        tone: SemanticTone.neutral,
        icon: Icons.language_rounded,
      ),
      DeviceType.unknown => EnumPresentation.unknown(fallbackLabel: label),
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 6. طلب التزويد (RequestStatus)
  // ──────────────────────────────────────────────────────────────────────────
  static EnumPresentation resolveRequestStatus(
    RequestStatus status, {
    String? serverLabel,
  }) {
    final label = _effectiveLabel(serverLabel, switch (status) {
      RequestStatus.pending => 'قيد الانتظار',
      RequestStatus.approved => 'تمت الموافقة',
      RequestStatus.rejected => 'تم الرفض',
      RequestStatus.cancelled => 'ملغي',
      RequestStatus.unknown => 'حالة غير معروفة',
    });

    return switch (status) {
      RequestStatus.pending => EnumPresentation(
        label: label,
        tone: SemanticTone.warning,
        icon: Icons.hourglass_top_rounded,
      ),
      RequestStatus.approved => EnumPresentation(
        label: label,
        tone: SemanticTone.success,
        icon: Icons.check_circle_rounded,
      ),
      RequestStatus.rejected => EnumPresentation(
        label: label,
        tone: SemanticTone.danger,
        icon: Icons.cancel_rounded,
      ),
      RequestStatus.cancelled => EnumPresentation(
        label: label,
        tone: SemanticTone.neutral,
        icon: Icons.highlight_off_rounded,
      ),
      RequestStatus.unknown => EnumPresentation.unknown(fallbackLabel: label),
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 7. سداد الفاتورة (InvoicePaymentStatus)
  // ──────────────────────────────────────────────────────────────────────────
  static EnumPresentation resolveInvoicePaymentStatus(
    InvoicePaymentStatus status, {
    String? serverLabel,
  }) {
    final label = _effectiveLabel(serverLabel, switch (status) {
      InvoicePaymentStatus.paid => 'مسدد بالكامل',
      InvoicePaymentStatus.partiallyPaid => 'سداد جزئي',
      InvoicePaymentStatus.unpaid => 'غير مسدد',
      InvoicePaymentStatus.unknown => 'حالة غير معروفة',
    });

    return switch (status) {
      InvoicePaymentStatus.paid => EnumPresentation(
        label: label,
        tone: SemanticTone.success,
        icon: Icons.check_circle_rounded,
      ),
      InvoicePaymentStatus.partiallyPaid => EnumPresentation(
        label: label,
        tone: SemanticTone.warning,
        icon: Icons.pie_chart_rounded,
      ),
      InvoicePaymentStatus.unpaid => EnumPresentation(
        label: label,
        tone: SemanticTone.danger,
        icon: Icons.error_outline_rounded,
      ),
      InvoicePaymentStatus.unknown => EnumPresentation.unknown(
        fallbackLabel: label,
      ),
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 8. نوع المعاملة (SaleType)
  // ──────────────────────────────────────────────────────────────────────────
  static EnumPresentation resolveSaleType(
    SaleType type, {
    String? serverLabel,
  }) {
    final label = _effectiveLabel(serverLabel, switch (type) {
      SaleType.cash => 'نقدي',
      SaleType.credit => 'آجل',
      SaleType.unknown => 'معاملة غير معروفة',
    });

    return switch (type) {
      SaleType.cash => EnumPresentation(
        label: label,
        tone: SemanticTone.info,
        icon: Icons.payments_outlined,
      ),
      SaleType.credit => EnumPresentation(
        label: label,
        tone: SemanticTone.warning,
        icon: Icons.credit_score_rounded,
      ),
      SaleType.unknown => EnumPresentation.unknown(fallbackLabel: label),
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 9. حركة المحفظة (WalletOperationType)
  // ──────────────────────────────────────────────────────────────────────────
  static EnumPresentation resolveWalletOperationType(
    WalletOperationType op, {
    String? serverLabel,
  }) {
    final label = _effectiveLabel(serverLabel, switch (op) {
      WalletOperationType.deposit => 'إيداع',
      WalletOperationType.withdraw => 'سحب',
      WalletOperationType.unknown => 'عملية غير محددة',
    });

    return switch (op) {
      WalletOperationType.deposit => EnumPresentation(
        label: label,
        tone: SemanticTone.success,
        icon: Icons.arrow_downward_rounded,
      ),
      WalletOperationType.withdraw => EnumPresentation(
        label: label,
        tone: SemanticTone.danger,
        icon: Icons.arrow_upward_rounded,
      ),
      WalletOperationType.unknown => EnumPresentation.unknown(
        fallbackLabel: label,
      ),
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 10. اشتراك المزود بالباقات (ProviderSubscriptionStatus)
  // ──────────────────────────────────────────────────────────────────────────
  static EnumPresentation resolveProviderSubscriptionStatus(
    ProviderSubscriptionStatus status, {
    String? serverLabel,
  }) {
    final label = _effectiveLabel(serverLabel, switch (status) {
      ProviderSubscriptionStatus.active => 'نشط',
      ProviderSubscriptionStatus.queued => 'قيد الانتظار',
      ProviderSubscriptionStatus.expired => 'منتهي',
      ProviderSubscriptionStatus.cancelled => 'ملغي',
      ProviderSubscriptionStatus.suspended => 'معلق',
      ProviderSubscriptionStatus.unknown => 'حالة غير معروفة',
    });

    return switch (status) {
      ProviderSubscriptionStatus.active => EnumPresentation(
        label: label,
        tone: SemanticTone.success,
        icon: Icons.verified_rounded,
      ),
      ProviderSubscriptionStatus.queued => EnumPresentation(
        label: label,
        tone: SemanticTone.info,
        icon: Icons.schedule_rounded,
      ),
      ProviderSubscriptionStatus.expired => EnumPresentation(
        label: label,
        tone: SemanticTone.neutral,
        icon: Icons.history_rounded,
      ),
      ProviderSubscriptionStatus.cancelled => EnumPresentation(
        label: label,
        tone: SemanticTone.neutral,
        icon: Icons.cancel_outlined,
      ),
      ProviderSubscriptionStatus.suspended => EnumPresentation(
        label: label,
        tone: SemanticTone.danger,
        icon: Icons.pause_circle_filled_rounded,
      ),
      ProviderSubscriptionStatus.unknown => EnumPresentation.unknown(
        fallbackLabel: label,
      ),
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 11. النسخ الاحتياطي (BackupStatus)
  // ──────────────────────────────────────────────────────────────────────────
  static EnumPresentation resolveBackupStatus(
    BackupStatus status, {
    String? serverLabel,
  }) {
    final label = _effectiveLabel(serverLabel, switch (status) {
      BackupStatus.queued => 'قيد الانتظار',
      BackupStatus.running => 'قيد التنفيذ',
      BackupStatus.success => 'تم بنجاح',
      BackupStatus.failed => 'فشل',
      BackupStatus.unknown => 'حالة غير معروفة',
    });

    return switch (status) {
      BackupStatus.queued => EnumPresentation(
        label: label,
        tone: SemanticTone.info,
        icon: Icons.schedule_rounded,
      ),
      BackupStatus.running => EnumPresentation(
        label: label,
        tone: SemanticTone.warning,
        icon: Icons.sync_rounded,
      ),
      BackupStatus.success => EnumPresentation(
        label: label,
        tone: SemanticTone.success,
        icon: Icons.check_circle_rounded,
      ),
      BackupStatus.failed => EnumPresentation(
        label: label,
        tone: SemanticTone.danger,
        icon: Icons.error_outline_rounded,
      ),
      BackupStatus.unknown => EnumPresentation.unknown(fallbackLabel: label),
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 12. مفتاح الدور (RoleKey)
  // ──────────────────────────────────────────────────────────────────────────
  static EnumPresentation resolveRoleKey(
    RoleKey roleKey, {
    String? serverLabel,
  }) {
    final label = _effectiveLabel(serverLabel, switch (roleKey) {
      RoleKey.superAdmin => 'مدير النظام',
      RoleKey.networkOwner => 'مالك الشبكة',
      RoleKey.networkUser => 'مستخدم الشبكة',
      RoleKey.posAgent => 'وكيل نقطة البيع',
      RoleKey.posUser => 'مستخدم نقطة البيع',
      RoleKey.supportAgent => 'وكيل الدعم الفني',
      RoleKey.accountant => 'محاسب عام',
      RoleKey.networkAccountant => 'محاسب الشبكة',
      RoleKey.posAccountant => 'محاسب نقطة البيع',
      RoleKey.unknown => 'دور غير محدد',
    });

    return EnumPresentation(
      label: label,
      tone: SemanticTone.neutral,
      icon: Icons.badge_outlined,
      isKnown: roleKey.isKnown,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 13. نطاق الدور (RoleScope)
  // ──────────────────────────────────────────────────────────────────────────
  static EnumPresentation resolveRoleScope(
    RoleScope scope, {
    String? serverLabel,
  }) {
    final label = _effectiveLabel(serverLabel, switch (scope) {
      RoleScope.platform => 'المنصة العامة',
      RoleScope.network => 'مزود الشبكة',
      RoleScope.pos => 'نقطة البيع',
      RoleScope.unknown => 'نطاق غير محدد',
    });

    return EnumPresentation(
      label: label,
      tone: SemanticTone.neutral,
      icon: Icons.domain_outlined,
      isKnown: scope.isKnown,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 14. رابط الشراكة المنطقي (Network–POS Boolean Link Status)
  // تمثيل لحقل Boolean صريح دون ابتداع Enum وهمي
  // ──────────────────────────────────────────────────────────────────────────
  static EnumPresentation resolveLinkStatus(
    bool isActive, {
    String? customLabel,
  }) {
    return EnumPresentation(
      label: customLabel ?? (isActive ? 'نشط' : 'معطل'),
      tone: isActive ? SemanticTone.success : SemanticTone.neutral,
      icon: isActive ? Icons.link_rounded : Icons.link_off_rounded,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 15. حالة دعوة ربط نقطة البيع (LinkingChallengeStatus)
  // ──────────────────────────────────────────────────────────────────────────
  static EnumPresentation resolveLinkingChallengeStatus(
    LinkingChallengeStatus status, {
    String? serverLabel,
  }) {
    final label = _effectiveLabel(serverLabel, switch (status) {
      LinkingChallengeStatus.pending => 'قيد الانتظار',
      LinkingChallengeStatus.consumed => 'مكتمل',
      LinkingChallengeStatus.expired => 'منتهي الصلاحية',
      LinkingChallengeStatus.revoked => 'ملغي',
      LinkingChallengeStatus.unknown => 'حالة غير معروفة',
    });

    return switch (status) {
      LinkingChallengeStatus.pending => EnumPresentation(
        label: label,
        tone: SemanticTone.warning,
        icon: Icons.hourglass_top_rounded,
      ),
      LinkingChallengeStatus.consumed => EnumPresentation(
        label: label,
        tone: SemanticTone.success,
        icon: Icons.check_circle_rounded,
      ),
      LinkingChallengeStatus.expired => EnumPresentation(
        label: label,
        tone: SemanticTone.neutral,
        icon: Icons.timer_off_outlined,
      ),
      LinkingChallengeStatus.revoked => EnumPresentation(
        label: label,
        tone: SemanticTone.danger,
        icon: Icons.cancel_outlined,
      ),
      LinkingChallengeStatus.unknown => EnumPresentation(
        label: label,
        tone: SemanticTone.neutral,
        icon: Icons.help_outline_rounded,
        isKnown: false,
      ),
    };
  }

  static EnumPresentation resolveMembershipStatus(
    MembershipStatus status, {
    String? serverLabel,
  }) {
    final label = _effectiveLabel(serverLabel, switch (status) {
      MembershipStatus.active => 'نشط',
      MembershipStatus.suspended => 'موقوف',
      MembershipStatus.invited => 'بانتظار التفعيل',
      MembershipStatus.unknown => 'حالة غير معروفة',
    });

    return switch (status) {
      MembershipStatus.active => EnumPresentation(label: label, tone: SemanticTone.success, icon: Icons.check_circle_rounded),
      MembershipStatus.suspended => EnumPresentation(label: label, tone: SemanticTone.warning, icon: Icons.pause_circle_outline_rounded),
      MembershipStatus.invited => EnumPresentation(label: label, tone: SemanticTone.info, icon: Icons.hourglass_top_rounded),
      MembershipStatus.unknown => EnumPresentation.unknown(fallbackLabel: label),
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // المساعدات الداخلية
  // ──────────────────────────────────────────────────────────────────────────
  static String _effectiveLabel(String? serverLabel, String fallback) {
    if (serverLabel != null && serverLabel.trim().isNotEmpty) {
      return serverLabel.trim();
    }
    return fallback;
  }
}
