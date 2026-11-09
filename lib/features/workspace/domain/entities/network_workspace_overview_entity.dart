class NetworkWorkspaceOverviewEntity {
  const NetworkWorkspaceOverviewEntity({
    required this.networkId,
    required this.networkName,
    required this.generatedAt,
    required this.periodKey,
    required this.metrics,
    required this.recentPendingRequests,
  });

  final int networkId;
  final String networkName;
  final String generatedAt;
  final String periodKey;
  final Map<String, dynamic> metrics;
  final List<Map<String, dynamic>> recentPendingRequests;

  Map<String, dynamic>? metric(String group) {
    final value = metrics[group];
    return value is Map<String, dynamic> ? Map<String, dynamic>.from(value) : null;
  }

  String count(String group, String key) {
    final value = metric(group)?[key];
    if (value is! num) {
      throw FormatException('قيمة المؤشر $group.$key غير صالحة.');
    }
    return value.toInt().toString();
  }

  String amount(String group, String key) {
    final value = metric(group)?[key];
    if (value is! String) {
      throw FormatException('قيمة المبلغ $group.$key غير صالحة.');
    }
    return value;
  }
}
