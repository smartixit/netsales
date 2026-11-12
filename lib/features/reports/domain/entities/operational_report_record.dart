class OperationalReportRecord {
  const OperationalReportRecord(this.values);

  final Map<String, dynamic> values;

  dynamic valueAt(String path) {
    dynamic current = values;
    for (final segment in path.split('.')) {
      if (current is Map) {
        current = current[segment];
      } else if (current is List) {
        final index = int.tryParse(segment);
        if (index == null || index < 0 || index >= current.length) {
          return null;
        }
        current = current[index];
      } else {
        return null;
      }
    }
    return current;
  }

  String textAt(String path, {String fallback = '—'}) {
    final value = valueAt(path);
    if (value == null) return fallback;
    if (value is Map || value is List) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }
}
