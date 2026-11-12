class OperationalReportExport {
  const OperationalReportExport({
    required this.exportId,
    required this.status,
    this.statusLabel,
    this.recordCount,
    this.artifactSize,
    this.downloadUrl,
    this.failureCode,
  });

  final String exportId;
  final String status;
  final String? statusLabel;
  final int? recordCount;
  final int? artifactSize;
  final String? downloadUrl;
  final String? failureCode;

  bool get isReady => status.toUpperCase() == 'READY';
  bool get isFailed => status.toUpperCase() == 'FAILED';
  bool get isPending =>
      status.toUpperCase() == 'QUEUED' || status.toUpperCase() == 'PROCESSING';
}
