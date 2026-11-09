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
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('استجابة ملخص مساحة الشبكة ليست كائناً.');
    }

    final json = Map<String, dynamic>.from(raw);
    final network = json['network'];
    final period = json['period'];
    final metrics = json['metrics'];
    final recent = json['recent_pending_requests'];
    final timezone = json['timezone'];

    if (network is! Map<String, dynamic> ||
        period is! Map<String, dynamic> ||
        metrics is! Map<String, dynamic> ||
        recent is! List<dynamic> ||
        timezone is! String ||
        timezone.trim().isEmpty) {
      throw const FormatException('عقد ملخص مساحة الشبكة غير مكتمل.');
    }

    final networkId = network['network_id'];
    final networkName = network['network_name'];
    final generatedAt = json['generated_at'];
    final periodKey = period['key'];
    final periodDays = period['days'];
    final periodFrom = period['from'];
    final periodTo = period['to'];

    if (networkId is! num ||
        networkName is! String ||
        networkName.isEmpty ||
        generatedAt is! String ||
        generatedAt.isEmpty ||
        periodKey is! String ||
        periodKey.isEmpty ||
        periodDays is! num ||
        periodDays <= 0 ||
        periodFrom is! String ||
        periodFrom.isEmpty ||
        periodTo is! String ||
        periodTo.isEmpty) {
      throw const FormatException('حقول تعريف ملخص الشبكة غير صالحة.');
    }

    final normalizedMetrics = <String, dynamic>{};
    for (final entry in metrics.entries) {
      if (entry.value == null) {
        normalizedMetrics[entry.key] = null;
      } else if (entry.value is Map<String, dynamic>) {
        normalizedMetrics[entry.key] =
            Map<String, dynamic>.from(entry.value as Map);
      } else {
        throw FormatException('مجموعة المؤشرات غير صالحة: ${entry.key}.');
      }
    }

    final pending = recent.map((dynamic item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('عنصر طلب التوريد غير صالح.');
      }

      final request = Map<String, dynamic>.from(item);
      if (request['request_id'] is! num ||
          request['request_uuid'] is! String ||
          request['pos_id'] is! num ||
          request['pos_name'] is! String ||
          request['sale_type_label'] is! String ||
          request['request_date'] is! String ||
          request['request_total_amount'] is! String ||
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
