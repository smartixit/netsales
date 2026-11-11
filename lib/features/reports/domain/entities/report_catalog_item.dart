class ReportCatalogItem {
  const ReportCatalogItem({
    required this.key,
    required this.title,
    required this.description,
    required this.definitionVersion,
    required this.artifactFormat,
    required this.filters,
    required this.maxRecords,
  });

  final String key;
  final String title;
  final String description;
  final String definitionVersion;
  final String artifactFormat;
  final Map<String, dynamic> filters;
  final int maxRecords;

  factory ReportCatalogItem.fromJson(Map<String, dynamic> json) =>
      ReportCatalogItem(
        key: json['key'] as String,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        definitionVersion: json['definition_version'] as String? ?? '1.0.0',
        artifactFormat: json['artifact_format'] as String? ?? 'JSON',
        filters: json['filters'] is Map
            ? Map<String, dynamic>.from(json['filters'] as Map)
            : const {},
        maxRecords: (json['max_records'] as num?)?.toInt() ?? 0,
      );
}
