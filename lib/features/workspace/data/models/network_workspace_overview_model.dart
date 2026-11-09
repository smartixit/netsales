import 'package:netsales/features/workspace/domain/entities/network_workspace_overview_entity.dart';

class NetworkWorkspaceOverviewModel extends NetworkWorkspaceOverviewEntity {
  const NetworkWorkspaceOverviewModel({
    required super.networkId,
    required super.networkName,
    required super.generatedAt,
    required super.periodKey,
    required super.metrics,
    required super.recentPendingRequests,
  });

  factory NetworkWorkspaceOverviewModel.fromJson(dynamic raw) {
    if (raw is! Map) {
      throw const FormatException('استجابة ملخص مساحة الشبكة ليست كائناً.');
    }
    final json = Map<String, dynamic>.from(raw);
    final network = json['network'];
    final period = json['period'];
    final metrics = json['metrics'];
    final recent = json['recent_pending_requests'];
    final timezone = json['timezone'];
    if (network is! Map ||
        period is! Map ||
        metrics is! Map ||
        recent is! List ||
        timezone is! String) {
      throw const FormatException('عقد ملخص مساحة الشبكة غير مكتمل.');
    }
    final networkMap = Map<String, dynamic>.from(network);
    final periodMap = Map<String, dynamic>.from(period);
    final networkId = networkMap['network_id'];
    final networkName = networkMap['network_name'];
    final generatedAt = json['generated_at'];
    final periodKey = periodMap['key'];
    final periodDays = periodMap['days'];
    final periodFrom = periodMap['from'];
    final periodTo = periodMap['to'];
    if (networkId is! num ||
        networkName is! String ||
        generatedAt is! String ||
        periodKey is! String ||
        periodDays is! num ||
        periodFrom is! String ||
        periodTo is! String ||
        timezone.isEmpty) {
      throw const FormatException('حقول تعريف ملخص الشبكة غير صالحة.');
    }
    final normalizedMetrics = <String, dynamic>{};
    for (final entry in Map<String, dynamic>.from(metrics).entries) {
      if (entry.value == null) {
        normalizedMetrics[entry.key] = null;
      } else if (entry.value is Map) {
        normalizedMetrics[entry.key] = Map<String, dynamic>.from(entry.value as Map);
      } else {
        throw FormatException('مجموعة المؤشرات ${entry.key} غير صالحة.');
      }
    }
    final pending = recent.map((item) {
      if (item is! Map) {
        throw const FormatException('عنصر طلب التوريد غير صالح.');
      }
      final request = Map<String, dynamic>.from(item);
      if (request['request_id'] is! num ||
          request['request_uuid'] is! String ||
          request['pos_id'] is! num ||
          request['pos_name'] is! String ||
          request['sale_type_label'] is! String ||
          request['status'] is! String ||
          request['status_label'] is! String) {
        throw const FormatException('عقد طلب التوريد المعلق غير مكتمل.');
      }
      return request;
    }).toList(growable: false);
    return NetworkWorkspaceOverviewModel(
      networkId: networkId.toInt(),
      networkName: networkName,
      generatedAt: generatedAt,
      periodKey: periodKey,
      metrics: normalizedMetrics,
      recentPendingRequests: pending,
    );
  }
}
