class ReportExportJob {
  const ReportExportJob({
    required this.exportId,
    required this.status,
    this.statusUrl,
    this.downloadUrl,
    this.fileName,
  });

  final String exportId;
  final String status;
  final String? statusUrl;
  final String? downloadUrl;
  final String? fileName;

  bool get isReady => status.toUpperCase() == 'READY';
  bool get isFailed => status.toUpperCase() == 'FAILED';
}
