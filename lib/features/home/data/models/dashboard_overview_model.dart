import 'package:netsales/features/home/domain/entities/dashboard_overview_entity.dart';

/// ============================================================================
/// نموذج تسلسل بيانات لوحة القيادة الموحدة (DashboardOverviewModel)
/// ============================================================================
/// يرث إجبارياً من [DashboardOverviewEntity] وفق ميثاق الهندسة النظيفة.
class DashboardOverviewModel extends DashboardOverviewEntity {
  const DashboardOverviewModel({
    required super.roleKey,
    required super.roleLabel,
    required super.period,
    required super.context,
    required super.liquidity,
    required super.kpis,
    required super.alerts,
    required super.recentActivities,
    required super.telemetry,
  });

  factory DashboardOverviewModel.fromJson(Map<String, dynamic> json) {
    return DashboardOverviewModel(
      roleKey: (json['role_key'] as String?) ?? 'UNKNOWN',
      roleLabel: (json['role_label'] as String?) ?? '',
      period: (json['period'] as String?) ?? 'today',
      context: DashboardContextModel.fromJson(
        (json['context'] as Map<String, dynamic>?) ?? {},
      ),
      liquidity: DashboardLiquidityModel.fromJson(
        (json['liquidity'] as Map<String, dynamic>?) ?? {},
      ),
      kpis: (json['kpis'] as Map<String, dynamic>?) ?? {},
      alerts: ((json['alerts'] as List<dynamic>?) ?? [])
          .map((item) => DashboardAlertModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      recentActivities: ((json['recent_activities'] as List<dynamic>?) ?? [])
          .map((item) => DashboardActivityModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      telemetry: DashboardTelemetryModel.fromJson(
        (json['telemetry'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}

class DashboardContextModel extends DashboardContextEntity {
  const DashboardContextModel({
    super.networkId,
    super.networkName,
    super.networkCode,
    super.posId,
    super.posName,
    super.posCode,
    super.status,
    super.statusLabel,
  });

  factory DashboardContextModel.fromJson(Map<String, dynamic> json) {
    return DashboardContextModel(
      networkId: json['network_id'] as int?,
      networkName: json['network_name'] as String?,
      networkCode: json['network_code'] as String?,
      posId: json['pos_id'] as int?,
      posName: json['pos_name'] as String?,
      posCode: json['pos_code'] as String?,
      status: json['status'] as String?,
      statusLabel: json['status_label'] as String?,
    );
  }
}

class DashboardLiquidityModel extends DashboardLiquidityEntity {
  const DashboardLiquidityModel({
    required super.balance,
    required super.currency,
    required super.status,
    super.isOverdrawn = false,
    super.debitAmount = 0.0,
  });

  factory DashboardLiquidityModel.fromJson(Map<String, dynamic> json) {
    return DashboardLiquidityModel(
      balance: ((json['balance'] ?? 0.0) as num).toDouble(),
      currency: (json['currency'] as String?) ?? 'YER',
      status: (json['status'] as String?) ?? 'ACTIVE',
      isOverdrawn: (json['is_overdrawn'] as bool?) ?? false,
      debitAmount: ((json['debit_amount'] ?? 0.0) as num).toDouble(),
    );
  }
}

class DashboardAlertModel extends DashboardAlertEntity {
  const DashboardAlertModel({
    required super.id,
    required super.type,
    required super.severity,
    required super.title,
    required super.message,
    super.count = 0,
    super.actionUrl,
    super.actionLabel,
  });

  factory DashboardAlertModel.fromJson(Map<String, dynamic> json) {
    return DashboardAlertModel(
      id: (json['id'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'INFO',
      severity: (json['severity'] as String?) ?? 'INFO',
      title: (json['title'] as String?) ?? '',
      message: (json['message'] as String?) ?? '',
      count: ((json['count'] ?? 0) as num).toInt(),
      actionUrl: json['action_url'] as String?,
      actionLabel: json['action_label'] as String?,
    );
  }
}

class DashboardActivityModel extends DashboardActivityEntity {
  const DashboardActivityModel({
    required super.id,
    required super.uuid,
    required super.type,
    required super.title,
    required super.partyName,
    required super.amount,
    required super.status,
    required super.statusLabel,
    required super.saleType,
    super.createdAt,
  });

  factory DashboardActivityModel.fromJson(Map<String, dynamic> json) {
    return DashboardActivityModel(
      id: ((json['id'] ?? 0) as num).toInt(),
      uuid: (json['uuid'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      partyName: (json['party_name'] as String?) ?? '',
      amount: ((json['amount'] ?? 0.0) as num).toDouble(),
      status: (json['status'] as String?) ?? '',
      statusLabel: (json['status_label'] as String?) ?? '',
      saleType: (json['sale_type'] as String?) ?? 'CASH',
      createdAt: json['created_at'] as String?,
    );
  }
}

class DashboardTelemetryModel extends DashboardTelemetryEntity {
  const DashboardTelemetryModel({
    required super.syncedAt,
    required super.serverTime,
  });

  factory DashboardTelemetryModel.fromJson(Map<String, dynamic> json) {
    return DashboardTelemetryModel(
      syncedAt: (json['synced_at'] as String?) ?? '',
      serverTime: (json['server_time'] as String?) ?? '',
    );
  }
}
