/// ============================================================================
/// الكيان الدوميني النقي لنظرة لوحة القيادة الموحدة (DashboardOverviewEntity)
/// ============================================================================
/// خالي تماماً من أي دوال تسلسل JSON أو اعتماديات على حزم خارجية.
class DashboardOverviewEntity {
  final String roleKey;
  final String roleLabel;
  final String period;
  final DashboardContextEntity context;
  final List<DashboardNetworkSummaryEntity> networks;
  final DashboardLiquidityEntity liquidity;
  final Map<String, dynamic> kpis;
  final List<DashboardAlertEntity> alerts;
  final List<DashboardActivityEntity> recentActivities;
  final DashboardTelemetryEntity telemetry;

  const DashboardOverviewEntity({
    required this.roleKey,
    required this.roleLabel,
    required this.period,
    required this.context,
    this.networks = const [],
    required this.liquidity,
    required this.kpis,
    required this.alerts,
    required this.recentActivities,
    required this.telemetry,
  });
}

/// ملخص الكيان الشبكي المستقل ضمن محفظة شبكات المزود أو الوكيل
class DashboardNetworkSummaryEntity {
  final int networkId;
  final String networkUuid;
  final String networkName;
  final String? networkProfileLogo;
  final String status;
  final double walletBalance;
  final String currency;
  final int activePosCount;
  final int pendingRequestsCount;

  const DashboardNetworkSummaryEntity({
    required this.networkId,
    required this.networkUuid,
    required this.networkName,
    this.networkProfileLogo,
    required this.status,
    required this.walletBalance,
    required this.currency,
    required this.activePosCount,
    required this.pendingRequestsCount,
  });

  String get networkCode => networkUuid;
}

/// سياق الكيان الحالي (شبكة أو نقطة بيع)
class DashboardContextEntity {
  final int? networkId;
  final String? networkUuid;
  final String? networkName;
  final int? posId;
  final String? posUuid;
  final String? posName;
  final String? status;
  final String? statusLabel;

  const DashboardContextEntity({
    this.networkId,
    this.networkUuid,
    this.networkName,
    this.posId,
    this.posUuid,
    this.posName,
    this.status,
    this.statusLabel,
  });

  String get displayName => networkName ?? posName ?? 'منظومة NetSales';
  String get displayCode => networkUuid ?? posUuid ?? '';
  bool get isNetwork => networkId != null;
  bool get isPos => posId != null;
}

/// بيانات السيولة والمركز المالي للمحفظة
class DashboardLiquidityEntity {
  final double balance;
  final String currency;
  final String status;
  final bool isOverdrawn;
  final double debitAmount;

  const DashboardLiquidityEntity({
    required this.balance,
    required this.currency,
    required this.status,
    this.isOverdrawn = false,
    this.debitAmount = 0.0,
  });
}

/// تنبيه تشغيلي أو إداري يتطلب إجراءً
class DashboardAlertEntity {
  final String id;
  final String type;
  final String severity; // INFO, WARNING, DANGER
  final String title;
  final String message;
  final int count;
  final String? actionUrl;
  final String? actionLabel;

  const DashboardAlertEntity({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    this.count = 0,
    this.actionUrl,
    this.actionLabel,
  });
}

/// حركة أو عملية من العمليات الأخيرة
class DashboardActivityEntity {
  final int id;
  final String uuid;
  final String type; // SALE_INVOICE, VOUCHER_REQUEST
  final String title;
  final String partyName;
  final double amount;
  final String status;
  final String statusLabel;
  final String saleType;
  final String? createdAt;

  const DashboardActivityEntity({
    required this.id,
    required this.uuid,
    required this.type,
    required this.title,
    required this.partyName,
    required this.amount,
    required this.status,
    required this.statusLabel,
    required this.saleType,
    this.createdAt,
  });

  bool get isInvoice => type == 'SALE_INVOICE';
  bool get isRequest => type == 'VOUCHER_REQUEST';
}

/// توقيت المزامنة وبيانات الاتصال
class DashboardTelemetryEntity {
  final String syncedAt;
  final String serverTime;

  const DashboardTelemetryEntity({
    required this.syncedAt,
    required this.serverTime,
  });
}
