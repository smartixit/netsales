class ReportRun {
  const ReportRun({
    required this.id,
    required this.uuid,
    required this.scope,
    required this.reportKey,
    required this.title,
    required this.status,
    required this.filters,
    this.downloadUrl,
    this.artifactFormat,
    this.recordsCount = 0,
    this.isTruncated = false,
    this.expiresAt,
    this.errorMessage,
  });

  final int id;
  final String uuid;
  final String scope;
  final String reportKey;
  final String title;
  final String status;
  final Map<String, dynamic> filters;
  final String? downloadUrl;
  final String? artifactFormat;
  final int recordsCount;
  final bool isTruncated;
  final DateTime? expiresAt;
  final String? errorMessage;

  bool get isCompleted => status.toUpperCase() == 'COMPLETED';
  bool get isFailed => status.toUpperCase() == 'FAILED';
  String get statusLabel => switch (status.toUpperCase()) {
    'QUEUED' => 'في قائمة الانتظار',
    'RUNNING' => 'قيد التنفيذ',
    'COMPLETED' => 'مكتمل',
    'FAILED' => 'فشل التنفيذ',
    'EXPIRED' => 'انتهت صلاحية الملف',
    _ => 'حالة غير معروفة',
  };

  factory ReportRun.fromJson(Map<String, dynamic> json) {
    final artifact = json['artifact'] is Map
        ? Map<String, dynamic>.from(json['artifact'] as Map)
        : const <String, dynamic>{};
    final error = json['error'] is Map
        ? Map<String, dynamic>.from(json['error'] as Map)
        : const <String, dynamic>{};
    return ReportRun(
      id: (json['report_run_id'] as num).toInt(),
      uuid: json['report_run_uuid'] as String? ?? '',
      scope: json['scope_type'] as String? ?? 'NETWORK',
      reportKey: json['report_key'] as String? ?? '',
      title: json['report_title'] as String? ?? '',
      status: json['status'] as String? ?? 'QUEUED',
      filters: json['filters'] is Map
          ? Map<String, dynamic>.from(json['filters'] as Map)
          : const {},
      downloadUrl: artifact['download_url'] as String?,
      artifactFormat: artifact['format'] as String?,
      recordsCount: (artifact['records_count'] as num?)?.toInt() ?? 0,
      isTruncated: artifact['is_truncated'] as bool? ?? false,
      expiresAt: artifact['expires_at'] is String
          ? DateTime.tryParse(artifact['expires_at'] as String)
          : null,
      errorMessage: error['message'] as String?,
    );
  }
}
